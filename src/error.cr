struct CrystaLXD::Error
  include JSON::Serializable

  getter type : String,
    error : String,
    error_code : Int32

  # Raises an error. Used to only return a `Success`, and raising when `Error`.
  def noerr!
    raise CrystaLXD::Exception.new "#{@error} (code: #{@error_code})"
  end

  def success(&)
    self
  end
end
