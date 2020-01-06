# https://github.com/lxc/lxd/blob/master/doc/rest-api.md#10operations
struct CrystaLXD::Operation
  getter uuid : String
  @client : Client

  def initialize(@client : Client, @uuid : String)
    @client.api_path = @client.api_path + "/operations/"
  end

  # Wait for an operation to finish, with an optional timeout in seconds
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#get-optional-timeout30).
  def wait(timeout : Int32? = nil) : Success(BackgroundOperation) | Error
    path = uuid + "/wait"
    path += "?timeout=#{timeout}" if timeout
    @client.get BackgroundOperation, path
  end
end
