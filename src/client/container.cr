# https://github.com/lxc/lxd/blob/master/doc/rest-api.md#10containers
struct CrystaLXD::Container
  # 64 chars max, ASCII, no slash, no colon and no comma.
  getter name : String
  @client : Client

  def initialize(@name : String, @client : Client)
    @client.api_path = @client.api_path + "/containers"
  end

  # Creates a new container
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#post-optional-targetmember).
  def create(
    source : Source::Image | Source::Copy | Source::Migration | Source::None,
    configuration : Configuration = Configuration.new
  ) : Success(BackgroundOperation) | Error
    container = {
      name:          @name,
      source:        source,
      architecture:  configuration.architecture,
      config:        configuration.config,
      devices:       configuration.devices,
      ephemeral:     configuration.ephemeral,
      instance_type: configuration.instance_type,
      profiles:      configuration.profiles,
    }
    @client.post BackgroundOperation, "", container.to_json
  end

  # Returns container configuration and current state
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#get-5).
  def information : Success(Information) | Error
    @client.get Information, '/' + @name
  end

  # Replaces container configuration
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#put-etag-supported-2).
  def replace_config(configuration : Configuration) : Success(BackgroundOperation) | Error
    @client.put BackgroundOperation, '/' + name, configuration.to_json
  end

  # Updates container configuration
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#patch-etag-supported-2).
  def update_config(configuration : Configuration) : Success(Empty) | Error
    @client.patch Empty, '/' + name, configuration.to_json
  end

  # Renames a container
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#post-optional-targetmember-1).
  def rename(new_name : String) : Success(BackgroundOperation) | Error
    @client.post BackgroundOperation, '/' + @name, %({"name": "#{new_name}"})
  end

  # Restores a snapshot
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#put-etag-supported-2).
  def restore_snapshot(snapshot_name : String) : Success(BackgroundOperation) | Error
    @client.put BackgroundOperation, '/' + @name, %({"restore": "#{snapshot_name}"})
  end

  # Removes the container
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#delete-1).
  def delete : Success(BackgroundOperation) | Error
    @client.delete BackgroundOperation, '/' + @name
  end

  # Restarts the container
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#put-1).
  def restart(force : Bool = true, timeout : Int32? = nil) : Success(BackgroundOperation) | Error
    handle_action Action.new "restart", timeout: timeout, force: force
  end

  # Starts the container
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#put-1).
  def start(stateful : Bool = false, timeout : Int32? = nil) : Success(BackgroundOperation) | Error
    handle_action Action.new "start", timeout: timeout, stateful: stateful
  end

  # Stops the container
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#put-1).
  def stop(force : Bool = true, stateful : Bool = false, timeout : Int32? = nil) : Success(BackgroundOperation) | Error
    handle_action Action.new "stop", timeout: timeout, force: force, stateful: stateful
  end

  # Freezes the container
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#put-1).
  def freeze(timeout : Int32? = nil) : Success(BackgroundOperation) | Error
    handle_action Action.new "freeze", timeout
  end

  # Unfreezes the container
  # (https://github.com/lxc/lxd/blob/master/doc/rest-api.md#put-1).
  def unfreeze(timeout : Int32? = nil) : Success(BackgroundOperation) | Error
    handle_action Action.new "unfreeze", timeout
  end

  private def handle_action(action : Action)
    @client.put BackgroundOperation, '/' + @name + "/state", action.to_json
  end

  private record Action, action : String, timeout : Int32? = nil, force : Bool? = nil, stateful : Bool? = nil do
    include JSON::Serializable
  end

  module Base
    macro included
      include JSON::Serializable

      # Whether to destroy the container on shutdown.
      getter ephemeral : Bool

      getter architecture : String
      # Config override.
      getter config : Config?
      # Optional list of devices the container should have.
      getter devices : Hash(String, Hash(String, String))?
      # An optional instance type to use as basis for limits.
      getter instance_type : String?
      # List of profiles.
      getter profiles : Array(String)
    end
  end

  struct Configuration
    include Base

    def initialize(
      @architecture : String = "x86_64",
      @config : Config? = nil,
      @devices : Hash(String, Hash(String, String))? = nil,
      @ephemeral : Bool = false,
      @instance_type : String? = nil,
      @profiles : Array(String) = ["default"]
    )
    end
  end

  struct Information
    include Base

    getter created_at : Time
    # The result of expanding profiles and adding the container's local config.
    getter expanded_config : Config
    # The result of expanding profiles and adding the container's local devices.
    getter expanded_devices : Hash(String, Hash(String, String))
    getter last_used : Time?
    getter name : String
    # If true, indicates that the container has some stored state that can be restored on startup.
    getter stateful : Bool
    getter status : String
    getter status_code : Success::Code
  end

  module Source
    struct Image
      include JSON::Serializable
      @type = "image"

      # Name of the alias.
      getter alias : String
      # "local" is the default if not specified.
      getter mode : Mode
      # Secret to use to retrieve the image (pull mode only).
      getter secret : String?
      # Remote server (pull mode only).
      getter server : String?
      # Optional PEM certificate. If not mentioned, system CA is used.
      getter certificate : String?
      # Protocol.
      getter protocol : Protocol
      # Fingerprint.
      getter fingerprint : String?
      # Container based on most recent match based on image properties.
      getter properties : Hash(String, String)?

      def initialize(
        @alias : String,
        @certificate : String? = nil,
        @fingerprint : String? = nil,
        @mode : Mode = Mode::Local,
        @properties : Hash(String, String)? = nil,
        @protocol : Protocol = Protocol::Lxd,
        @secrets : String? = nil,
        @server : String? = nil
      )
      end

      enum Mode
        Local
        Pull

        def to_json(builder : JSON::Builder)
          builder.string self.to_s.downcase
        end
      end

      enum Protocol
        Lxd
        Simplestreams

        def to_json(builder : JSON::Builder)
          builder.string self.to_s.downcase
        end
      end
    end

    struct Migration
      include JSON::Serializable
      @type = "migration"

      getter mode : Mode
      @[JSON::Field(key: "base-image")]
      # Optional, the base image the container was created from.
      getter base_image : String?
      # Whether to migrate only the container without snapshots.
      getter container_only : Bool
      # Whether migration is performed live.
      getter live : Bool
      # Full URL to the remote operation (pull mode only).
      getter operation : String?
      # Optional PEM certificate. If not mentioned, system CA is used.
      getter certificate : String?
      getter secrets : Secrets

      # Secrets to use when talking to the migration source.
      record Secrets, control : String, criu : String, fs : String do
        include JSON::Serializable
      end

      def initialize(
        @mode : Mode,
        @container_only : Bool,
        @live : Bool,
        @secrets : Secrets,
        @operation : String? = nil,
        @base_image : String? = nil,
        @certificate : String? = nil
      )
      end

      enum Mode
        Pull
        Push

        def to_json(builder : JSON::Builder)
          builder.string self.to_s.downcase
        end
      end
    end

    struct Copy
      include JSON::Serializable

      @type = "copy"

      # Whether to copy only the container without snapshots.
      getter container_only : Bool
      # Name of the source container.
      getter source : String

      def initialize(
        @container_only : Bool,
        @source : String
      )
      end
    end

    # Can be used for a container without a pre-populated rootfs, useful when attaching to an existing one.
    struct None
      include JSON::Serializable

      @type = "none"
    end
  end
end
