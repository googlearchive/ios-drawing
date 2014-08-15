#!/bin/bash
set -o nounset
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SDK_DIR="$SCRIPT_DIR/sdk"

FIREBASE_SDK_URL="https://cdn.firebase.com/ObjC/Firebase.framework-LATEST.zip"
FIREBASE_SDK_ZIP_FILE="firebase-sdk.zip"
FIREBASE_SDK_DIR="$SCRIPT_DIR/sdk/Firebase.framework"

download_sdk() {
    FRAMEWORK_NAME="$1"
    SDK_URL="$2"
    SDK_ZIP_FILE="$3"
    if [ -f "$SDK_DIR/$SDK_ZIP_FILE" ]; then
        echo "$FRAMEWORK_NAME zip file already present. Skipping download..." 1>&2
    else
        echo "Downloading $FRAMEWORK_NAME ..." 1>&2
        curl -L "$SDK_URL" -o "$SDK_DIR/$SDK_ZIP_FILE"
    fi
    echo "Extracting $FRAMEWORK_NAME ..." 1>&2
    unzip -o -qq "$SDK_DIR/$SDK_ZIP_FILE" -d "$SDK_DIR"
}


echo "$SDK_DIR"

mkdir -p "$SDK_DIR"

download_sdk "Firebase SDK" "$FIREBASE_SDK_URL" "$FIREBASE_SDK_ZIP_FILE"

echo "All done..." 1>&2
