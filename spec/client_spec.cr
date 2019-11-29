require "./spec_helper"

describe CrystaLXD::Client do
  it "gets information" do
    CLIENT.information.noerr!
  end

  it "lists containers" do
    p CLIENT.containers.noerr!
  end

  it "lists operations" do
    p CLIENT.operations.noerr!
  end
end
