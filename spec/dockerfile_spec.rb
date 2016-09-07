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
    expect(os_version).to include("Ubuntu 14")
  end

  # Zip and yiu-compressor for roger release
  %w{git zip yui-compressor}.each do |p|
    it "installs package #{p}" do
      expect(package(p)).to be_installed
    end
  end

  # PhantomJS runtime dependencies
  %w{fontconfig libjpeg8 libjpeg-turbo8 libicu52}.each do |p|
    it "installs package #{p}" do
      expect(package(p)).to be_installed
    end
  end

  describe command("ruby -v") do
    its(:stdout) { should match /2\.3\.0p0/ }
  end

  describe command("node -v") do
    its(:stdout) { should match /6\.5\.0/ }
  end

  describe command("npm -v") do
    its(:stdout) { should match /3\.8\.3/ }
  end

  describe command("phantomjs -v") do
    its(:stdout) { should match /2\.0\.0/ }
  end

  def os_version
    command("lsb_release -a").stdout
  end
end
