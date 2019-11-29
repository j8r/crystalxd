# https://github.com/lxc/lxd/blob/master/doc/rest-api.md#10operations
struct CrystaLXD::Operation
  getter uuid : String
  @client : Client

  def initialize(@uuid : String, @client : Client)
    @client.api_path = @client.api_path + "/operations/"
  end

  # Wait for an operation to finish. Can take as arguments an UUID as a string, and a timeout in seconds.
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#get-optional-timeout30).
  def wait(timeout : Int32 = 30) : Success(BackgroundOperation) | Error
    @client.get BackgroundOperation, uuid + "/wait"
  end
end

struct CrystaLXD::BackgroundOperation
  include JSON::Serializable

  getter id : String,
    class : String,
    description : String,
    created_at : Time,
    updated_at : Time,
    status : String,
    status_code : Success::Code,
    resources : Resources,
    metadata : Nil,
    may_cancel : Bool,
    err : String,
    location : String

  struct Resources
    include JSON::Serializable
    getter containers : Array(String)
  end
end
