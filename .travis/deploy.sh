#!/usr/bin/env bash

SNAP="remmina"
snap_version=$(cat .snapversion)
arch="amd64"
channel="edge"

if [ -n "$ARCH" ]; then
  arch=$ARCH
fi

if [ "$BUILD_TARGET" == "release" ]; then
  channel="stable"
fi

echo "Deploying $SNAP version ${snap_version}_$arch to channel $channel"

if [ -n "$snap_version" ] && [ -z "$SNAP_FORCE_DEPLOY" ]; then
  snap_history=$(docker exec -i builder snapcraft history $SNAP --arch=$arch)
  if (echo "$snap_history" | grep -q $snap_version | grep -q $channel); then
    echo "Snap '$SNAP' version $snap_version is already available in $channel:"
    echo "  $snap_history" | grep $snap_version | grep $channel | head -n1
    echo " We don't need to push it again, force defining $SNAP_FORCE_DEPLOY"
    exit 0
  fi
fi

docker exec -i builder snapcraft push *.snap --release $channel
