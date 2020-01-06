require "json"
require "http/client"
require "./error"
require "./success"
require "./client/*"

# Raise an `Exception` on an error.
# ```
# CrystaLXD::Client.new(
#   tls: OpenSSL::SSL::Context::Client.from_hash({
#     "key"         => "certs/lxd.key",
#     "cert"        => "certs/lxd.crt",
#     "verify_mode" => "none",
#   })
# )
# ```
#
struct CrystaLXD::Client
  getter host : String,
    port : Int32,
    tls : OpenSSL::SSL::Context::Client

  protected property api_path : String

  def initialize(@tls : OpenSSL::SSL::Context::Client, @host : String = "[::1]", @port : Int32 = 8443, path : String = "/")
    @api_path = ""
    @api_path = get(Array(String), path).noerr!.metadata.last
  end

  def http_client(& : HTTP::Client ->)
    HTTP::Client.new @host, @port, @tls do |client|
      yield client
    end
  end

  def parse_response(klass : U.class, response) : Success(U) | Error forall U
    if response.status.success?
      Success(U).from_json response.body_io
    else
      Error.from_json response.body_io
    end
  end

  {% for method in %w(get post put patch delete) %}
  def {{method.id}}(klass : U.class, path : String = "", body = nil) : Success(U) | Error forall U
    http_client &.{{method.id}} path: @api_path + path, body: body do |response|
      parse_response U, response
    end
  end
  {% end %}

  struct Information
    include JSON::Serializable

    # List of API extensions added after the API was marked stable.
    getter api_extensions : Array(String)
    getter api_status : APIStatus
    # The API version as a string.
    getter api_version : String
    # Authentication state, one of "guest", "untrusted" or "trusted".
    getter auth : String
    # Host configuration
    getter config : Config
    # Whether the server should be treated as a public (read-only) remote by the client
    getter public : Bool
    getter auth_methods : Array(String)
    getter environment : Environment

    # API implementation status.
    enum APIStatus
      Deprecated
      Development
      Stable
    end

    # Various information about the host (OS, kernel, ...).
    struct Environment
      getter addresses : Array(String),
        architectures : Array(String),
        certificate : String,
        certificate_fingerprint : String,
        driver : String,
        driver_version : String,
        kernel : String,
        kernel_architecture,
        kernel_features : Hash(String, String),
        kernel_version : String,
        lxc_features : Hash(String, String),
        project : String,
        server : String,
        server_clustered : Bool,
        server_name : String,
        server_pid : Int64,
        server_version : String,
        storage : String,
        storage_version : String
      include JSON::Serializable
    end
  end

  # Server configuration and environment information
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#get-1).
  def information : Success(Information) | Error
    get Information
  end

  # Instantiates a new container wrapper.
  def container(name : String) : Container
    Container.new self, name
  end

  # List of containers, or URLs of containers, this server publishes
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#get-4).
  def containers(url : Bool = false) : Success(Array(String)) | Error
    get_last_element Array(String), "/containers", url
  end

  # Instantiates a new operation wrapper.
  def operation(operation_or_uuid : Success(BackgroundOperation) | Error | String) : Operation
    uuid = operation_or_uuid.is_a?(String) ? operation_or_uuid : operation_or_uuid.noerr!.metadata.id
    Operation.new self, uuid
  end

  # List of operations, or URLs of operations, that are currently going on/queued
  # https://github.com/lxc/lxd/blob/master/doc/rest-api.md#get-23
  def operations(url : Bool = false) : Success(Hash(Success::Code, Array(String))) | Error
    case response = get Hash(Success::Code, Array(String)), "/operations"
    when Success
      response.metadata.each_value &.map! &.rpartition('/').last if !url
      response
    else
      response
    end
  end

  private def get_last_element(klass, path, url : Bool)
    case response = get klass, path
    when Success
      response.metadata.map! &.rpartition('/').last if !url
      response
    else
      response
    end
  end
end
