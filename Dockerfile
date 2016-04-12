FROM ubuntu:14.04
MAINTAINER Edwin van der Graaf <edwin@digitpaint.nl>

RUN apt-get update
RUN apt-get -y upgrade

RUN apt-get -y install build-essential zlib1g-dev libssl-dev \
               libreadline6-dev libyaml-dev git python-software-properties \
               fontconfig libjpeg8 libjpeg-turbo8 libicu52 zip yui-compressor curl

ENV RUBY_DOWNLOAD_SHA256 ba5ba60e5f1aa21b4ef8e9bf35b9ddb57286cb546aac4b5a28c71f459467e507
ADD https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz /tmp/

# Install ruby
RUN \
  cd /tmp && \
  echo "$RUBY_DOWNLOAD_SHA256 *ruby-2.3.0.tar.gz" | sha256sum -c - && \
  tar -xzf ruby-2.3.0.tar.gz && \
  cd ruby-2.3.0 && \
  ./configure && \
  make && \
  make install && \
  cd .. && \
  rm -rf ruby-2.3.0 && \
  rm -f ruby-2.3.0.tar.gz

RUN gem install bundler --no-ri --no-rdoc

# Install node
ENV NODEJS_DOWNLOAD_SHA256 c6e278b612b53c240ddf85521403e55abfd8f0201d2f2c7e3d2c21383054aacd
ADD https://nodejs.org/dist/v5.10.1/node-v5.10.1.tar.gz /tmp/

RUN \
  cd /tmp && \
  echo "$NODEJS_DOWNLOAD_SHA256 *node-v5.10.1.tar.gz" | sha256sum -c - && \
  tar xvzf node-v5.10.1.tar.gz && \
  rm -f node-v5.10.1.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  echo -e '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

# Download phantomjs build (see README)
RUN \
  cd /tmp && \
  git clone https://github.com/edwinvdgraaf/phantomjs-build.git && \
  cd phantomjs-build && \
  cp bin/phantomjs /usr/local/bin/ && \
  cd /tmp && \
  rm -rf /tmp/phantomjs-build
