#!/usr/bin/env bash

set -e
l1chainid=1337
composeFile="docker-compose-v2.yml"

echo "====== Setup writable volumes ======"
# Don't let docker create these directories automatically,
# it will be not writeable by current user.
mkdir -p ./.deployment/local/volumes/config
mkdir -p ./.deployment/local/volumes/seq-data
mkdir -p ./.deployment/local/volumes/poster-data
mkdir -p ./.deployment/local/volumes/validator-data

echo "====== Generating L1 keys ======"
docker-compose -f $composeFile run testnode-scripts write-accounts
docker-compose -f $composeFile run --entrypoint sh geth -c "echo passphrase > /datadir/passphrase"
docker-compose -f $composeFile run --entrypoint sh geth -c "chown -R 1000:1000 /keystore"
docker-compose -f $composeFile run --entrypoint sh geth -c "chown -R 1000:1000 /config"

echo "====== Start L1 ======"
docker-compose -f $composeFile up -d geth

echo "====== Funding validator and sequencer ======"
docker-compose -f $composeFile run testnode-scripts send-l1 --ethamount 1000 --to validator --wait
docker-compose -f $composeFile run testnode-scripts send-l1 --ethamount 1000 --to sequencer --wait

echo "====== Create L1 traffic ======"
docker-compose -f $composeFile run testnode-scripts send-l1 --ethamount 1000 --to user_l1user --wait
docker-compose -f $composeFile run testnode-scripts send-l1 --ethamount 0.0001 --from user_l1user --to user_l1user_b --wait --delay 500 --times 500 >/dev/null &

echo "====== Deploying L2 contracts to L1 ======"
sequenceraddress=$(docker-compose -f $composeFile run testnode-scripts print-address --account sequencer | tail -n 1 | tr -d '\r\n')
docker-compose -f $composeFile run --entrypoint /usr/local/bin/deploy poster \
  --l1conn ws://geth:8546 \
  --l1keystore /home/user/l1keystore \
  --sequencerAddress $sequenceraddress \
  --ownerAddress $sequenceraddress \
  --l1DeployAccount $sequenceraddress \
  --l1deployment /config/deployment.json \
  --authorizevalidators 10 \
  --wasmrootpath /home/user/target/machines \
  --l1chainid=$l1chainid

echo "====== Writing configs ======"
docker-compose -f $composeFile run testnode-scripts write-config

echo "====== Initializing redis ======"
docker-compose -f $composeFile run testnode-scripts redis-init

echo "====== Start sequencer ======"
docker-compose -f $composeFile up -d sequencer

echo "====== Funding L2 funnel to inbox address ======"
docker-compose -f $composeFile run testnode-scripts bridge-funds --from funnel --ethamount 100000 --wait

echo "====== Start all sequencer poster validator ======"
docker-compose -f $composeFile up -d sequencer poster validator

echo "====== Start L1 & L2 block explorers ======"
docker-compose -f $composeFile up -d blockscout_l1 blockscout_l2
