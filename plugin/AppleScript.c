/*
 *  AppleScript.c
 *  OneWay
 *
 *  Created by nrj on 7/22/09.
 *  Copyright 2009. All rights reserved.
 *
 */

#include "AppleScript.h"

static OSStatus LowRunAppleScript(const void* text, long textLength, AEDesc *resultData) 
{
	ComponentInstance theComponent;
	AEDesc scriptTextDesc;
	OSStatus err;
	OSAID scriptID, resultID;
	
	/* set up locals to a known state */
	theComponent = NULL;
	AECreateDesc(typeNull, NULL, 0, &scriptTextDesc);
	scriptID = kOSANullScript;
	resultID = kOSANullScript;
	
	/* open the scripting component */
	theComponent = OpenDefaultComponent(kOSAComponentType,
										typeAppleScript);
	if (theComponent == NULL) { err = paramErr; goto bail; }
	
	/* put the script text into an aedesc */
	err = AECreateDesc(typeChar, text, textLength, &scriptTextDesc);
	if (err != noErr) goto bail;
	
	/* compile the script */
	err = OSACompile(theComponent, &scriptTextDesc,
					 kOSAModeNull, &scriptID);
	if (err != noErr) goto bail;
	
	/* run the script */
	err = OSAExecute(theComponent, scriptID, kOSANullScript,
					 kOSAModeNull, &resultID);
	
	/* collect the results - if any */
	if (resultData != NULL) {
		AECreateDesc(typeNull, NULL, 0, resultData);
		if (err == errOSAScriptError) {
			OSAScriptError(theComponent, kOSAErrorMessage,
						   typeChar, resultData);
		} else if (err == noErr && resultID != kOSANullScript) {
			OSADisplay(theComponent, resultID, typeChar,
					   kOSAModeNull, resultData);
		}
	}
bail:
	AEDisposeDesc(&scriptTextDesc);
	if (scriptID != kOSANullScript) OSADispose(theComponent, scriptID);
	if (resultID != kOSANullScript) OSADispose(theComponent, resultID);
	if (theComponent != NULL) CloseComponent(theComponent);
	return err;
}

OSStatus SimpleRunAppleScript(const char* theScript) {
	return LowRunAppleScript(theScript, strlen(theScript), NULL);
}

