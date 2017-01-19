#!/usr/bin/env bash

REMMINA_GIT="https://github.com/FreeRDP/Remmina.git"

last_tag=$(git ls-remote --tags $REMMINA_GIT | cut -f2 | cut -f3 -d/ | sort -Vr | head -n1)
last_version=$(basename $last_tag | sed s/^v//)

if [ "$BUILD_TARGET" ==  "release" ]; then
  git_ref=$last_tag
  snap_version=$last_version
elif [ -n "$BUILD_TARGET" ]; then
  git_commit=$(git ls-remote --heads $REMMINA_GIT $BUILD_TARGET | cut -f1)
  git_ref="refs/heads/$BUILD_TARGET"
  snap_version=$last_version+git${git_commit:0:8}
fi

sed "s,^\(version:\)\([ ]*[0-9.a-z_-+]*\),\1 $snap_version," -i snapcraft.yaml
sed "s,^\( \+\)\(source-commit:\)\(.*\) \(# Remmina-commit\),\1\2 $git_ref \4," snapcraft.yaml -i snapcraft.yaml

echo "Snap version is $snap_version"
echo " - Building from git ref $git_ref"
echo "============"
cat snapcraft.yaml
