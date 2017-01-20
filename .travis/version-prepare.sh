#!/usr/bin/env bash

REMMINA_GIT="https://github.com/FreeRDP/Remmina.git"

last_tag=$(git ls-remote --tags $REMMINA_GIT | cut -f2 | cut -f3 -d/ | sort -Vr | head -n1)
last_version=$(basename $last_tag | sed s/^v//)
channel="edge"

if [ "$BUILD_TARGET" ==  "release" ]; then
  git_ref=$last_tag
  snap_version=$last_version
  channel="$RELEASE_CHANNEL"
elif [ -n "$BUILD_TARGET" ]; then
  git_commit=$(git ls-remote --heads $REMMINA_GIT $BUILD_TARGET | cut -f1)
  git_ref="refs/heads/$BUILD_TARGET"
  snap_version=$last_version+git${git_commit:0:8}
fi

sed "s,^\(version:\)\([ ]*[0-9.a-z_-+]*\),\1 $snap_version," -i snapcraft.yaml
sed "s,^\( \+\)\(source-commit:\)\(.*\) \(# Remmina-commit\),\1\2 $git_ref \4," -i snapcraft.yaml

# Sometimes the arch isn't properly recognized by snapcraft
if [ -n "$ARCH" ]; then
  echo "architectures:
  - $ARCH" >> snapcraft.yaml
fi

echo "Snap version is $snap_version"
echo " - Building from git ref $git_ref"

if [ -z "$SNAP_FORCE_DEPLOY" ]; then
  arch="amd64"
  if [ -n "$ARCH" ]; then
    arch=$ARCH
  fi

  snap_history=$(docker exec -i builder snapcraft history remmina --arch=$arch | grep $channel)
  if (echo "$snap_history" | grep -Fq "$snap_version"); then
    echo "============"
    echo "Snap version $snap_version is already available in $channel:"
    echo "  $snap_history" | grep $snap_version | grep $channel | head -n1

    if [ "$BUILD_TARGET" ==  "release" ]; then
      echo "Skipping build, use '\$SNAP_FORCE_BUILD' to force"
      touch .snap_skip_build
    else
      echo "Skipping deploy, use '\$SNAP_FORCE_DEPLOY' to force"
    fi

    touch .snap_skip_deploy
  fi
fi

echo "============"
cat snapcraft.yaml
