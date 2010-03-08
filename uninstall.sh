#!/bin/sh

echo "Uninstalling OneWay.app ..."

/bin/rm -rf "$HOME/Library/Contextual Menu Items/OneWay.plugin"
/bin/rm -rf "$HOME/Library/OneWay"
/bin/rm -rf "/Applications/OneWay.app"

defaults delete com.cocoaism.OneWay

sleep 3
killall Finder

echo "Done"