#!/usr/bin/env bash

channel="edge"

if [ "$BUILD_TARGET" == "release" ]; then
  channel="stable"
fi

if [ -e ".snap_skip_deploy" ]; then
  echo "No need to deploy the snap to $channel, use $SNAP_FORCE_DEPLOY to force"
  exit 0
fi

echo "Deploying snap to channel $channel..."
docker exec -i builder snapcraft push *.snap --release $channel
