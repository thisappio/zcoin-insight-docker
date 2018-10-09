#!/usr/bin/env bash

# copy testnet conf
if [ ! -d /var/lib/insight/testnet ]; then
    cp -r /opt/insight/testnet /var/lib/insight
    cp -r /opt/insight/node_modules /var/lib/insight/testnet
fi

# run insight
cd /var/lib/insight/testnet
bitcore-node-zcoin start | tee -a testnet.log

