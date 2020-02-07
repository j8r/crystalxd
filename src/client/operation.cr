# https://github.com/lxc/lxd/blob/master/doc/rest-api.md#10operations
struct CrystaLXD::Operation
  getter uuid : String
  @client : Client

  def initialize(@client : Client, @uuid : String)
    @client.endpoint_path = "/operations/"
  end

  # Wait for an operation to finish, with an optional timeout in seconds
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#get-optional-timeout30).
  def wait(timeout : Int32? = nil) : Success(BackgroundOperation) | Error
    path = uuid + "/wait"
    path += "?timeout=#{timeout}" if timeout
    @client.get BackgroundOperation, path
  end

  # This connection is upgraded into a websocket connection speaking the protocol defined by the operation type.
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#get-secretsecret).
  def websocket(secret : String)
    @client.websocket uuid + "/websocket?secret=" + secret
  end

  # Returns the current state
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#get-24).
  def state : Success(BackgroundOperation) | Error
    @client.get BackgroundOperation, uuid
  end
end
