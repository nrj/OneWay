#!/bin/sh

BUILD_DIR="$HOME/Code/Cocoa/oneway/build/"

if [ "$1" == "--build-files" ]; then
	echo "Removing Build Files ..."
	/bin/rm -rf "$BUILD_DIR"
fi

echo "Uninstalling OneWay.app ..."

/bin/rm -rf "$HOME/Library/Contextual Menu Items/OneWay.plugin"
/bin/rm -rf "$HOME/Library/OneWay"
/bin/rm -rf "/Applications/OneWay.app"

defaults delete com.onewayapp.OneWay
sleep 3
killall Finder