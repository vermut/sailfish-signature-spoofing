#!/bin/bash

set -e
SYSTEM_PATH=system

echo [**] 1. Fetch files via RSYNC
rsync -va \
    rsync://${SAILFISH}/alien/system.img \
    /tmp/system.img

echo [**] 1.1 unpack the squashfs
cd /tmp && unsquashfs system.img

echo [**] 1.2 get files to patch
mkdir /sailfish
rsync -va /tmp/squashfs-root/${SYSTEM_PATH}/{framework,app,priv-app} \
  /sailfish

echo [**] 2. Deodex the vdex and dex files
cd /vdexExtractor/bin && ./vdexExtractor -i /sailfish --ignore-crc-error
echo [**] 2. add classes.dex to services.jar
cp /sailfish/framework/oat/arm/services_classes.dex /tmp/classes.dex
zip -j /sailfish/framework/services.jar /tmp/classes.dex

echo [**] 3. Apply the patch
API_VERSION=27
rm -rf /hook
/haystack/patch-fileset /haystack/patches/sigspoof-hook-7.0-9.0 ${API_VERSION} /sailfish/framework /hook
rm -rf /hook_core
/haystack/patch-fileset /haystack/patches/sigspoof-core ${API_VERSION} /hook /hook_core

echo [**] 4. Merge back the results
mv -v /hook_core/* /sailfish/framework/

echo [**] 5.1 Merge results back
rsync -va \
    /sailfish/framework/ \
    /tmp/squashfs-root/${SYSTEM_PATH}/framework/
# rsync -va \
#     /sailfish/app/ \
#     /tmp/squashfs-root/${SYSTEM_PATH}/app/
# rsync -va \
#     /sailfish/priv-app/ \
#     /tmp/squashfs-root/${SYSTEM_PATH}/priv-app/

 echo [**] 5.2 rebuild squashfs
 cd /tmp && mksquashfs squashfs-root system.img.haystack -comp lz4 -Xhc -noappend -no-exports -no-duplicates -no-fragments

 echo [**] 5. Upload results back
 rsync -va --delete-after -b --suffix=".pre_haystack" \
     /tmp/system.img.haystack \
     rsync://${SAILFISH}/alien/system.img
