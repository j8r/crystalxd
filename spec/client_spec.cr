require "./spec_helper"

describe CrystaLXD::Client do
  it "gets information" do
    CLIENT.information.noerr!
  end

  it "lists containers" do
    CLIENT.containers.noerr!
  end

  it "lists operations" do
    CLIENT.operations.noerr!
  end
end
