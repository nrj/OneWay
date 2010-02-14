/*
 *  AppleScript.h
 *  OneWay
 *
 *  Created by nrj on 7/22/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>
#include <string.h>
#include <sys/stat.h>

static OSStatus LowRunAppleScript(const void* text, long textLength, AEDesc *resultData);

OSStatus SimpleRunAppleScript(const char* theScript);