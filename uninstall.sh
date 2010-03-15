#!/bin/sh

echo "Uninstalling OneWay.app ..."

/bin/rm -rf $HOME/Library/Contextual Menu Items/OneWay.plugin
/bin/rm -rf $HOME/Library/Services/OneWay*workflow
/bin/rm -rf $HOME/Library/OneWay
/bin/rm -rf /Applications/OneWay.app

defaults delete com.cocoaism.OneWay

/System/Library/CoreServices/pbs

sleep 3
killall Finder

echo "Done"