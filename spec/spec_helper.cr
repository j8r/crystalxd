require "spec"
require "../src/crystalxd"

CLIENT = CrystaLXD::Client.new(
  tls: OpenSSL::SSL::Context::Client.from_hash({
    "key"         => "certs/lxd.key",
    "cert"        => "certs/lxd.crt",
    "verify_mode" => "none",
  })
)
SPEC_CONTAINER_PREFIX = "crystalxd-test"

def spec_container_name : String
  File.tempname prefix: SPEC_CONTAINER_PREFIX, suffix: nil, dir: ""
end

def spec_with_container(& : CrystaLXD::Container ->) : Nil
  container = CLIENT.container spec_container_name
  begin
    operation = container.create(
      source: CrystaLXD::Container::Source::Image.new(
        alias: "alpine/edge",
        mode: :pull,
        protocol: :simplestreams,
        server: "https://images.linuxcontainers.org/"
      ),
      configuration: CrystaLXD::Container::Configuration.new(ephemeral: true)
    )
    CLIENT.operation(operation).wait.noerr!
    yield container
  ensure
    container.stop
    container.delete
  end
end

def assert_background_operation(operation : CrystaLXD::Success(CrystaLXD::BackgroundOperation) | CrystaLXD::Error)
  result = CLIENT.operation(operation).wait.noerr!
  result.metadata.status_code.success?.should be_true
end

# Using `Spec.after_suite` returns:
# Error running at_exit handler: not found (code: NotFound)
at_exit do
  CLIENT.containers.success &.metadata.each do |container_name|
    if container_name.starts_with? SPEC_CONTAINER_PREFIX
      CLIENT.container(container_name).stop
      CLIENT.container(container_name).delete.noerr!
    end
  end
end
