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
    expect(os_version).to include("Ubuntu 16")
  end

  describe command("ruby -v") do
    its(:stdout) { should match /2\.3/ }
  end

  describe command("node --version") do
    its(:stdout) { should match /8\.9\.3/ }
  end

  describe command("npm -v") do
    its(:stdout) { should match /5\.5\.1/ }
  end

  describe command("yarn --version") do
    its(:stdout) { should match /1\.3\.2/ }
  end

  def os_version
    command("lsb_release -a").stdout
  end
end
