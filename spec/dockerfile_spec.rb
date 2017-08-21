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
    its(:stdout) { should match /2\.3\.0p0/ }
  end

  describe command("node -v") do
    its(:stdout) { should match /6\.5\.0/ }
  end

  describe command("npm -v") do
    its(:stdout) { should match /3\.10\.3/ }
  end

  describe command("yarn --version") do
    its(:stdout) { should match /0\.19\.1/ }
  end

  def os_version
    command("lsb_release -a").stdout
  end
end
