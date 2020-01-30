#!/bin/bash -u

# while :; do sleep 10; done

export WORK_DIR=elements-testing-dockerfile

cd /root
if [ ! -d ${WORK_DIR} ]; then
  mkdir ${WORK_DIR}
fi

cd /root/${WORK_DIR}/
rm -rf bitcoind_datadir
rm -rf elementsd_datadir

mkdir bitcoind_datadir
chmod 777 bitcoind_datadir
# cp /root/.bitcoin/bitcoin.conf bitcoind_datadir/
cp ./fixtures/bitcoin.conf bitcoind_datadir/
mkdir elementsd_datadir
chmod 777 elementsd_datadir
# cp /root/.elements/elements.conf elementsd_datadir/
cp ./fixtures/elements.conf elementsd_datadir/

# boot daemon
bitcoind --regtest -datadir=/root/wallet-test/bitcoind_datadir
bitcoin-cli --regtest -datadir=/root/wallet-test/bitcoind_datadir ping > /dev/null 2>&1
while [ $? -ne 0 ]
do
  bitcoin-cli --regtest -datadir=/root/wallet-test/bitcoind_datadir ping > /dev/null 2>&1
done

echo "start bitcoin node"

elementsd -chain=liquidregtest -datadir=/root/wallet-test/elementsd_datadir
elements-cli -chain=liquidregtest -datadir=/root/wallet-test/elementsd_datadir ping > /dev/null 2>&1
while [ $? -ne 0 ]
do
  elements-cli -chain=liquidregtest -datadir=/root/wallet-test/elementsd_datadir ping > /dev/null 2>&1
done

echo "start elements node"

set -e

# replace to call test.
