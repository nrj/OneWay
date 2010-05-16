/*
 *  AppleScript.h
 *  OneWay
 *
 *  Copyright 2010 Nick Jensen <http://goto11.net>
 *
 */

#include <Carbon/Carbon.h>
#include <string.h>
#include <sys/stat.h>

static OSStatus LowRunAppleScript(const void* text, long textLength, AEDesc *resultData);

OSStatus SimpleRunAppleScript(const char* theScript);