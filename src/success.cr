module CrystaLXD
  struct Success(T)
    include JSON::Serializable

    enum Operation
      Async
      Sync
    end

    enum Code
      OperationCreated = 100
      Started          = 101
      Stopped          = 102
      Running          = 103
      Cancelling       = 104
      Pending          = 105
      Starting         = 106
      Stopping         = 107
      Aborting         = 108
      Freezing         = 109
      Frozen           = 110
      Thawed           = 111
      Success          = 200

      def self.from_json_object_key?(key : String)
        parse key
      end

      def to_json_object_key : String
        to_s
      end
    end

    getter type : Operation,
      status : String,
      status_code : Code,
      operation : String,
      error_code : Int32,
      error : String,
      metadata : T

    # Returns `self`. Used to only return a `Success` without an union with `Error`.
    def noerr!
      self
    end

    # Yields self. Useful in case of an union with `Error`.
    def success(&)
      yield self
    end
  end

  struct BackgroundOperation
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
end
