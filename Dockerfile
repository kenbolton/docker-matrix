# baseimage is ubuntu precise (LTS)
FROM ubuntu:precise

# Maintainer
MAINTAINER Silvio Fricke <silvio.fricke@gmail.com>

# set debian/ubuntu config environment to noninteractive
ENV DEBIAN_FRONTEND noninteractive

# here we should setup the initsystem problem
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

# update and upgrade
RUN apt-get update -y && apt-get upgrade -y

# development base installation
RUN apt-get install -y build-essential python2.7-dev libffi-dev python-pip \
		       python-setuptools sqlite3 libssl-dev python-virtualenv \
		       libjpeg-dev git-core \
		       subversion libevent-dev libsqlite3-dev pwgen

# clean up
RUN apt-get clean

# install/upgrade pip
RUN pip install --upgrade pip

# install env template
RUN pip install envtpl


# install homerserver template
ADD adds/start.sh /start.sh
RUN chmod a+x /start.sh

# ssh and startup configuration
ENTRYPOINT ["/start.sh"]
CMD ["start"]
EXPOSE 8448

# install synapse homeserver
RUN git clone https://github.com/matrix-org/synapse /tmp-synapse
# the "git clone" is cached, we need to invalidate the docker cache here
ADD http://www.random.org/strings/?num=1&len=10&digits=on&upperalpha=on&loweralpha=on&unique=on&format=plain&rnd=new uuid
RUN cd /tmp-synapse && \
    git pull && \
    git describe --always --long | tee /synapse.version
RUN pip install --process-dependency-links /tmp-synapse

# install turn-server
RUN svn co http://coturn.googlecode.com/svn/trunk coturn && \
    cd coturn && \
    ./configure && \
    make && \
    make install

