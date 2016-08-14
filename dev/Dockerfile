FROM perl:5.24

RUN apt-get update
RUN apt-get install -y build-essential libssl-dev cpanminus

RUN cpanm -n Dist::Zilla IO::All JSON MooseX::Types::URI Test::Pod XML::Simple YAML

COPY dist.ini /tmp
COPY install-deps.sh /usr/local/bin/install-deps.sh
COPY run-tests.sh /usr/local/bin/run-tests.sh

RUN chmod +x /usr/local/bin/install-deps.sh && \
    chmod +x /usr/local/bin/run-tests.sh && \
    cd /tmp && \
    /usr/local/bin/install-deps.sh && \
    rm /tmp/dist.ini

VOLUME /project
WORKDIR /project
