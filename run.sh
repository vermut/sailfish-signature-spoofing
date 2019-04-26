#!/bin/bash
set -e
SYSTEM_PATH=system
API_VERSION=19

echo [**] 0. Validate the environment
if [[ -z "${SAILFISH}" ]]; then
    echo "ERROR: You need to supply SAILFISH environment var with your phone's IP address!"
    exit 1
fi

rsync \
    rsync://${SAILFISH}/alien/system/etc/aliendalvik-release \
    aliendalvik-release || true

if [[ ! -f aliendalvik-release ]]; then
    echo "Cannot find /opt/alient/system. Maybe you are on LXC environment?.. Let's check!"
    rsync \
        rsync://${SAILFISH}/alien/system.img \
        system.img || true

    if [[ -f system.img ]]; then
        echo "Seems like you are using this tool for older Android version. Please use yeoldegrove/sailfish-signature-spoofing-lxc"
        echo "https://github.com/yeoldegrove/sailfish-signature-spoofing-lxc"
    fi
    if [[ ! -f system.img ]]; then
        echo "ERROR: No idea what's going on. Better stop now."
    fi

    exit 1
fi

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
