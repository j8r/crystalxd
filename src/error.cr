struct CrystaLXD::Error
  include JSON::Serializable

  enum Code
    Failure             = 400
    Cancelled           = 401
    Forbidden           = 403
    NotFound            = 404
    Conflict            = 409
    PreconditionFailed  = 412
    InternalServerError = 500

    def self.from_json_object_key?(key : String)
      parse key
    end

    def to_json_object_key : String
      to_s
    end
  end

  getter type : String,
    error : String,
    error_code : Code

  # Raises an error. Used to only return a `Success`, and raising when `Error`.
  def noerr!
    raise CrystaLXD::Exception.new "#{@error} (code: #{@error_code})"
  end

  # Do not yield. Useful in case of an union with `Success`.
  def success(&)
    self
  end
end
