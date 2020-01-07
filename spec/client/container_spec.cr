require "../spec_helper"

describe CrystaLXD::Container do
  describe "creation" do
    it "pulls an image" do
      spec_with_container { }
    end
  end

  it "gets information" do
    spec_with_container do |container|
      container.information.noerr!
    end
  end

  describe "exec" do
    it "websocket" do
      spec_with_container do |container|
        CLIENT.operation(container.start).wait
        container.exec({"ls"}).noerr!
      end
    end
  end

  it "renames" do
    spec_with_container do |container|
      new_container_name = spec_container_name
      container.rename(new_container_name).noerr!
      CLIENT.container(new_container_name).rename(container.name).noerr!
    end
  end

  describe "config" do
    it "replaces" do
      spec_with_container do |container|
        CLIENT.operation(container.replace_config(CrystaLXD::Container::Configuration.new(instance_type: "c2.micro"))).wait.noerr!
      end
    end

    it "updates" do
      spec_with_container do |container|
        container.update_config(CrystaLXD::Container::Configuration.new(instance_type: "c2.micro")).noerr!
      end
    end
  end

  pending "restores a snapshot" do
  end

  it "deletes" do
    spec_with_container { }
  end

  describe "shows state" do
    it "stopped container" do
      spec_with_container do |container|
        container.state.noerr!
      end
    end

    it "running container" do
      spec_with_container do |container|
        CLIENT.operation(container.start).wait
        container.state.noerr!
      end
    end
  end

  describe "modify state" do
    it "restarts" do
      spec_with_container do |container|
        CLIENT.operation(container.start).wait
        assert_background_operation container.restart
      end
    end

    it "starts" do
      spec_with_container do |container|
        assert_background_operation container.start
      end
    end

    it "stops" do
      spec_with_container do |container|
        CLIENT.operation(container.start).wait
        assert_background_operation container.stop
      end
    end

    it "freezes" do
      spec_with_container do |container|
        CLIENT.operation(container.start).wait
        assert_background_operation container.freeze
      end
    end

    it "unfreezes" do
      spec_with_container do |container|
        CLIENT.operation(container.start).wait
        CLIENT.operation(container.freeze).wait
        assert_background_operation container.unfreeze
      end
    end
  end
end
