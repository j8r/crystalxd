require "./*"
require "json"

module CrystaLXD
  class Exception < ::Exception
  end

  # Set of possible valid config types.
  alias Config = Hash(String, String | Bool | Int64)

  # Used for empty JSON responses.
  struct Empty
    include JSON::Serializable
  end
end
