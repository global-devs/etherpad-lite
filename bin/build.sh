#!/bin/sh

set -x

PRODUCT_NAME=proofpad
PRODUCT_VER=1.8.0
PRODUCT_TAR=$PRODUCT_NAME-$PRODUCT_VER-win.tar

NODE_VERSION="10.20.1"

#Move to the folder where ep-lite is installed
cd $(dirname $0)

#Was this script started in the bin folder? if yes move out
if [ -d "../bin" ]; then
  cd "../"
fi

#Is wget installed?
hash wget > /dev/null 2>&1 || {
  echo "Please install wget" >&2
  exit 1
}

#Is tar installed?
hash tar > /dev/null 2>&1 || {
  echo "Please install tar" >&2
#  exit 1
}

#Is zip installed?
hash unzip > /dev/null 2>&1 || {
  echo "Please install unzip" >&2
#  exit 1
}
START_FOLDER=$(pwd);
# TMP_FOLDER=$(mktemp -d)
TARGET_FOLDER=$START_FOLDER/target/$PRODUCT_NAME-$PRODUCT_VER
DIST_FOLDER=$START_FOLDER/dist

rm -fr $TARGET_FOLDER $DIST_FOLDER/$PRODUCT_TAR
mkdir -p $TARGET_FOLDER $DIST_FOLDER

echo "create a clean environment in $TARGET_FOLDER..."
rsync -avq --progress ./ $TARGET_FOLDER --exclude target --exclude dist
# cp -ar . $TARGET_FOLDER
cd $TARGET_FOLDER
rm -rf node_modules

# setting NODE_ENV=production ensures that dev dependencies are not installed,
# making the windows package smaller
export NODE_ENV=production

echo "do a normal unix install first..."
bin/installDeps.sh || exit 1

echo "copy the windows settings template..."
cp settings.json.template settings.json

echo "resolve symbolic links..."
cp -rL node_modules node_modules_resolved
rm -rf node_modules
mv node_modules_resolved node_modules

echo "download windows node..."
cd bin
wget -q "https://nodejs.org/dist/v$NODE_VERSION/win-x86/node.exe" -O ../node.exe

echo "remove git history to reduce folder size"
rm -rf .git/objects

echo "remove windows jsdom-nocontextify/test folder"
rm -rf $TARGET_FOLDER/src/node_modules/wd/node_modules/request/node_modules/form-data/node_modules/combined-stream/test
rm -rf $TARGET_FOLDER/src/node_modules/nodemailer/node_modules/mailcomposer/node_modules/mimelib/node_modules/encoding/node_modules/iconv-lite/encodings/tables

# echo "create the zip..."
# cd $TARGET_FOLDER
# tar -cf $DIST_FOLDER/$PRODUCT_TAR ./*

# echo "Finished. You can find the zip in the Etherpad root folder, it's called dist/$PRODUCT_TAR"
echo "Finished. You can find the zip in the Etherpad root folder, it's called target/$PRODUCT_NAME-$PRODUCT_VER"
