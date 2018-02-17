require "serverspec"
require "docker"

# Workaround needed for circleCI
if ENV["CIRCLECI"]
  class Docker::Container
    def remove(*); end
    alias_method :delete, :remove
  end
end

describe "Dockerfile" do
  before(:all) do
    image = Docker::Image.build_from_dir(".") do |v|
      matches = v.match(/{\"stream\":\"(Step[^\\"]*)/)
      if matches
        puts "=> #{matches.captures[0]}"
      end
    end

    set :os, family: :debian
    set :backend, :docker
    set :docker_image, image.id
  end

  it "ubuntu" do
    expect(os_version).to include("Ubuntu 18")
  end

  describe command("ruby -v") do
    its(:stdout) { should match /2\.5/ }
  end

  describe command("node --version") do
    its(:stdout) { should match /10\.8\.0/ }
  end

  describe command("yarn --version") do
    its(:stdout) { should match /1\.9\.4/ }
  end

  def os_version
    command("lsb_release -a").stdout
  end
end
