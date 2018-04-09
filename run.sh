#!/bin/bash
set -e
SYSTEM_PATH=system
API_VERSION=19

echo [**] 1. Fetch files via RSYNC
rsync -va --delete \
    rsync://${SAILFISH}/alien/${SYSTEM_PATH}/framework \
    rsync://${SAILFISH}/alien/${SYSTEM_PATH}/app       \
    rsync://${SAILFISH}/alien/${SYSTEM_PATH}/priv-app  \
    sailfish

echo [**] 2. Deodex the files
/simple-deodexer/deodex.sh -l ${API_VERSION} -d /sailfish

echo [**] 3. Apply the patch
/haystack/patch-fileset /haystack/patches/sigspoof-hook-4.1-6.0 ${API_VERSION} /sailfish/framework /hook
/haystack/patch-fileset /haystack/patches/sigspoof-core ${API_VERSION} /hook /hook_core

echo [**] 4. Merge back the results
mv -v /hook_core/* /sailfish/framework/

echo [**] 5. Upload results back
rsync -va --delete-after -b --backup-dir=../framework.pre_haystack  \
    /sailfish/framework/                                            \
    rsync://${SAILFISH}/alien/${SYSTEM_PATH}/framework

rsync -va --delete-after -b --backup-dir=../app.pre_haystack  \
    /sailfish/app/                                            \
    rsync://${SAILFISH}/alien/${SYSTEM_PATH}/app

rsync -va --delete-after -b --backup-dir=../priv-app.pre_haystack  \
    /sailfish/priv-app/                                            \
    rsync://${SAILFISH}/alien/${SYSTEM_PATH}/priv-app
