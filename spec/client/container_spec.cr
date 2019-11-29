require "../spec_helper"

describe CrystaLXD::Container do
  describe "container creation" do
    it "pulls an image" do
      spec_with_container { }
    end
  end

  it "gets information" do
    spec_with_container do |container|
      container.information.noerr!
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
        container.replace_config(CrystaLXD::Container::ConfigUpdate.new(instance_type: "c2.micro")).noerr!
      end
    end

    it "updates" do
      spec_with_container do |container|
        container.update_config(CrystaLXD::Container::ConfigUpdate.new(instance_type: "c2.micro")).noerr!
      end
    end
  end

  pending "restores a snapshot" do
  end

  it "deletes" do
    spec_with_container { }
  end
end
