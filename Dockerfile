FROM ubuntu:16.04

WORKDIR /opt/insight

RUN apt-get update \
    && apt-get install -y build-essential curl jq git libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils libboost-all-dev software-properties-common \
    && add-apt-repository ppa:bitcoin/bitcoin \
    && apt-get update \
    && apt-get install -y libdb4.8-dev libdb4.8++-dev libminiupnpc-dev libzmq3-dev \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -y nodejs \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

# install zcoin
RUN mkdir -p /opt/zcoin \
    && curl -L $(curl "https://api.github.com/repos/zcoinofficial/zcoin/releases/latest" \
    | grep -Po '"browser_download_url": "\K.*.tar.gz?(?=")') \
    | tar -xvzf - --strip=1 --directory /opt/zcoin

# ADD . /opt/zcoin

# install bitcore-node-zcoin
RUN npm install -g https://github.com/zcoinofficial/bitcore-node-zcoin.git

# ADD . /opt/insight

# create testnet insight
RUN bitcore-node-zcoin create -t testnet \
    && cd testnet \
    && bitcore-node-zcoin install git://github.com/thisappio/insight-api-zcoin.git \
    && bitcore-node-zcoin install git://github.com/zcoinofficial/insight-ui-zcoin.git \
    && tmpjson=$(mktemp) \
    && jq '.servicesConfig.bitcoind.spawn.exec = "/opt/zcoin/bin/zcoind"' bitcore-node-zcoin.json > "$tmpjson" \
    && mv "$tmpjson" bitcore-node-zcoin.json

VOLUME /var/lib/insight

RUN chmod 755 run.sh

EXPOSE 3881
CMD ["./run.sh"]
