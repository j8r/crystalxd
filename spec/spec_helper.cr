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
    success = container.create(
      source: CrystaLXD::Container::Source::Image.new(
        alias: "alpine/edge",
        mode: :pull,
        protocol: :simplestreams,
        server: "https://images.linuxcontainers.org/"
      ),
      configuration: CrystaLXD::Container::Configuration.new(ephemeral: true)
    ).noerr!
    CLIENT.operation(success).wait.noerr!
    yield container
  ensure
    container.delete.noerr!
  end
end

Spec.after_suite do
  CLIENT.containers.success &.metadata.each do |container_name|
    if container_name.starts_with? SPEC_CONTAINER_PREFIX
      CLIENT.container(container_name).delete
    end
  end
end
