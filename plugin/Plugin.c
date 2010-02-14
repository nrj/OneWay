/*
 *  Plugin.c
 *  OneWay
 *
 *  Created by nrj on 7/22/09.
 *  Copyright 2009. All rights reserved.
 *
 */

#define DEBUGSTR(s) DebugStr(s)

#if defined(__MWERKS__)
#include <CFPlugInCOM.h>
#include <ApplicationServices.h>
#include <Carbon.h>
#include <CoreServices.h>
#include <Menus.h>



// The Contextual Menu Manager will only load CFPlugIns of type kContextualMenuTypeID
#define kContextualMenuTypeID    (CFUUIDGetConstantUUIDWithBytes(NULL,	\
0x2F,0x65,0x22,0xE9,0x3E,0x66,0x11,0xD5,\
0x80,0xA7,0x00,0x30,0x65,0xB3,0x00,0xBC))
// 2F6522E9-3E66-11D5-80A7-003065B300BC



// Contextual Menu Plugins must implement this Contexual Menu Plugin Interface.
#define kContextualMenuInterfaceID ( CFUUIDGetConstantUUIDWithBytes( NULL,	\
0x32,0x99,0x7B,0x62,0x3E,0x66,0x11,0xD5,\
0xBE,0xAB,0x00,0x30,0x65,0xB3,0x00,0xBC))
// 32997B62-3E66-11D5-BEAB-003065B300BC



#define CM_IUNKNOWN_C_GUTS \
void *_reserved; \
SInt32 (*QueryInterface)(void *thisPointer, CFUUIDBytes iid, void ** ppv); \
UInt32 (*AddRef)(void *thisPointer); \
UInt32 (*Release)(void *thisPointer)



// The function table for the interface.
struct ContextualMenuInterfaceStruct
{
	CM_IUNKNOWN_C_GUTS;
	OSStatus ( *ExamineContext )(void * thisInstance,
								 const AEDesc * inContext,
								 AEDescList * outCommandPairs );
	OSStatus ( *HandleSelection )(void * thisInstance,
								  AEDesc * inContext,
								  SInt32 inCommandID );
	void ( *PostMenuCleanup )(void * thisInstance );
};
typedef struct ContextualMenuInterfaceStruct ContextualMenuInterfaceStruct;
//



#define malloc(s) NewPtr(s)
#define free(p) DisposePtr((Ptr) p)

#include <stdio.h>
#include <string.h>

#else

#include <CoreFoundation/CoreFoundation.h>
#include <CoreFoundation/CFPlugInCOM.h>
#include <ApplicationServices/ApplicationServices.h>
#include <Carbon/Carbon.h>
#include <CoreServices/CoreServices.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>

#endif

#include "AppleScript.h"



// The UUID for this plugin
#define kOneWayFactoryID ( CFUUIDGetConstantUUIDWithBytes( NULL, \
0x56, 0xD3, 0x1A, 0xCF, 0x5E, 0x5B, 0x40, 0x7A, \
0x9B, 0xE3, 0xE0, 0x12, 0x1A, 0xD0, 0xF4, 0xA0 ) )
// UUID "56D31ACF-5E5B-407A-9BE3-E0121AD0F4A0"



// The layout for an instance of OneWayType.
typedef struct OneWayType
{
	ContextualMenuInterfaceStruct	*cmInterface;
	CFUUIDRef						factoryID;
	UInt32							refCount;
} OneWayType;



static char* Copy_CFStringRefToCString(const CFStringRef pCFStringRef);

static HRESULT OneWayQueryInterface(void* thisInstance,REFIID iid,LPVOID* ppv);
static ULONG OneWayAddRef(void *thisInstance);
static ULONG OneWayRelease(void *thisInstance);

static OSStatus OneWayExamineContext(void* thisInstance,const AEDesc* inContext,AEDescList* outCommandPairs);
static OSStatus OneWayHandleSelection(void* thisInstance,AEDesc* inContext,SInt32 inCommandID);
static void OneWayPostMenuCleanup( void *thisInstance );



// -----------------------------------------------------------------------------
//	Copy_CFStringRefToCString
// -----------------------------------------------------------------------------
//	Function to convert a CFString to a C string.
//	
static char* Copy_CFStringRefToCString(const CFStringRef pCFStringRef)
{
    char* results = NULL;
	if (NULL != pCFStringRef)
	{
		CFIndex length = sizeof(UniChar) * CFStringGetLength(pCFStringRef) + 1;
		results = (char*) NewPtrClear(length);
		if (!CFStringGetCString(pCFStringRef,results,length,kCFStringEncodingASCII))
		{
			if (!CFStringGetCString(pCFStringRef,results,length,kCFStringEncodingUTF8))
			{
				DisposePtr(results);
				results = NULL;
			}
		}
	}
	return results;
}



// -----------------------------------------------------------------------------
//	DeallocOneWayType
// -----------------------------------------------------------------------------
//	Utility function that deallocates the instance when
//	the refCount goes to zero.
//
static void DeallocOneWayType( OneWayType* thisInstance )
{
	CFUUIDRef	theFactoryID = thisInstance->factoryID;
	
	//DEBUGSTR("\p|DeallocOneWayType-I-Debug;g");
	
	free( thisInstance );
	if ( theFactoryID )
	{
		CFPlugInRemoveInstanceForFactory( theFactoryID );
		CFRelease( theFactoryID );
	}
}



// -----------------------------------------------------------------------------
//	testInterfaceFtbl	definition
// -----------------------------------------------------------------------------
//	The TestInterface function table.
//
static ContextualMenuInterfaceStruct testInterfaceFtbl =
{
// Required padding for COM
NULL,

// These three are the required COM functions
OneWayQueryInterface,
OneWayAddRef,
OneWayRelease,

// Interface implementation
OneWayExamineContext,
OneWayHandleSelection,
OneWayPostMenuCleanup
};



#if TARGET_RT_MAC_CFM

// -----------------------------------------------------------------------------
//	MachO<->CFM Kludge
// -----------------------------------------------------------------------------
//	This function allocates a block of CFM glue code which contains the instructions to call CFM routines
//
UInt32 _template[6] = {
	0x3D800000,	// 	lis		r12,0x0000			// load ms-word TVector -> r12
	0x618C0000,	//	ori		r12,r12,0x0000		// OR in ls-word TVector -> r12
	0x800C0000,	//	lwz		r0,0x0000(r12)		// get new PC from TVector
	0x804C0004,	//	lwz		RTOC,0x004(r12)		// get new RTOC from TVector
	0x7C0903A6,	//	mtctr	r0					// new PC -> control register
	0x4E800420	//	bctr						// branch to control register
};

static void *MachOFunctionPointerForCFMFunctionPointer( void *cfmfp )
{
    UInt32	*mfp = (UInt32*) NewPtr( sizeof(_template) );		//	Must later dispose of allocated memory
    mfp[0] = _template[0] | ((UInt32)cfmfp >> 16);
    mfp[1] = _template[1] | ((UInt32)cfmfp & 0xFFFF);
    mfp[2] = _template[2];
    mfp[3] = _template[3];
    mfp[4] = _template[4];
    mfp[5] = _template[5];
    MakeDataExecutable( mfp, sizeof(_template) );
	
    return (mfp);
}

#define GLUE(x) MachOFunctionPointerForCFMFunctionPointer(x)

extern OSErr MyCFragInitFunction(const CFragInitBlock * initBlock);
OSErr MyCFragInitFunction(const CFragInitBlock * initBlock)
{
	(initBlock);
	
	(void*) testInterfaceFtbl.QueryInterface = GLUE(OneWayQueryInterface);
	(void*) testInterfaceFtbl.AddRef = GLUE(OneWayAddRef);
	(void*) testInterfaceFtbl.Release = GLUE(OneWayRelease);
	(void*) testInterfaceFtbl.ExamineContext = GLUE(OneWayExamineContext);
	(void*) testInterfaceFtbl.HandleSelection = GLUE(OneWayHandleSelection);
	(void*) testInterfaceFtbl.PostMenuCleanup = GLUE(OneWayPostMenuCleanup);
	
	return noErr;
}

extern void MyCFragTermProcedure(void);
void MyCFragTermProcedure(void)
{
	if (NULL != testInterfaceFtbl.QueryInterface)
		DisposePtr((Ptr) testInterfaceFtbl.QueryInterface);
	if (NULL != testInterfaceFtbl.AddRef)
		DisposePtr((Ptr) testInterfaceFtbl.AddRef);
	if (NULL != testInterfaceFtbl.Release)
		DisposePtr((Ptr) testInterfaceFtbl.Release);
	if (NULL != testInterfaceFtbl.ExamineContext)
		DisposePtr((Ptr) testInterfaceFtbl.ExamineContext);
	if (NULL != testInterfaceFtbl.HandleSelection)
		DisposePtr((Ptr) testInterfaceFtbl.HandleSelection);
	if (NULL != testInterfaceFtbl.PostMenuCleanup)
		DisposePtr((Ptr) testInterfaceFtbl.PostMenuCleanup);
}

#endif TARGET_RT_MAC_CFM



// -----------------------------------------------------------------------------
//	AllocOneWayType
// -----------------------------------------------------------------------------
//	Utility function that allocates a new instance.
//
static OneWayType* AllocOneWayType(CFUUIDRef		inFactoryID )
{
	// Allocate memory for the new instance.
	OneWayType *theNewInstance;
	
	//DEBUGSTR("\p|AllocOneWayType-I-Debug;g");
	
	theNewInstance = (OneWayType*) malloc(sizeof( OneWayType ) );
	
	// Point to the function table
	theNewInstance->cmInterface = &testInterfaceFtbl;
	
	// Retain and keep an open instance refcount<
	// for each factory.
	theNewInstance->factoryID = CFRetain( inFactoryID );
	CFPlugInAddInstanceForFactory( inFactoryID );
	
	// This function returns the IUnknown interface
	// so set the refCount to one.
	theNewInstance->refCount = 1;
	return theNewInstance;
}



// -----------------------------------------------------------------------------
//	OneWayFactory
// -----------------------------------------------------------------------------
//	Implementation of the factory function for this type.
//
extern void* OneWayFactory(CFAllocatorRef allocator,CFUUIDRef typeID );
void* OneWayFactory(CFAllocatorRef allocator,CFUUIDRef typeID )
{
#pragma unused (allocator)
	
	//DEBUGSTR("\p|OneWayFactory-I-Debug;g");
	
	// If correct type is being requested, allocate an
	// instance of TestType and return the IUnknown interface.
	if ( CFEqual( typeID, kContextualMenuTypeID ) )
	{
		OneWayType *result;
		result = AllocOneWayType(kOneWayFactoryID);
		return result;
	}
	else
	{
		// If the requested type is incorrect, return NULL.
		return NULL;
	}
}



// -----------------------------------------------------------------------------
//	AddCommandToAEDescList
// -----------------------------------------------------------------------------
static OSStatus AddCommandToAEDescList(CFStringRef	inCommandCFStringRef,
									   SInt32		inCommandID,
									   AEDescList*	ioCommandList)
{
	OSStatus anErr = noErr;
	AERecord theCommandRecord = { typeNull, NULL };
	//	CFStringRef tCFStringRef = CFStringCreateWithFormat(kCFAllocatorDefault,NULL,
	//													 CFSTR("%@ - %ld (0x%.8lX)"),inCommandCFStringRef,inCommandID,inCommandID);
	CFStringRef tCFStringRef = inCommandCFStringRef;
	CFIndex length = CFStringGetLength(tCFStringRef);
    const UniChar* dataPtr = CFStringGetCharactersPtr(tCFStringRef);
	const UniChar* tempPtr = nil;
	
	//	printf("\nQuitCMI->AddCommandToAEDescList: Trying to add an item." );
	
    if (dataPtr == NULL)
	{
		tempPtr = (UniChar*) NewPtr(length * sizeof(UniChar));
		if (nil == tempPtr)
			goto AddCommandToAEDescList_fail;
		
		CFStringGetCharacters(tCFStringRef, CFRangeMake(0,length), (UniChar*) tempPtr);
		dataPtr = tempPtr;
	}
	if (nil == dataPtr)
		goto AddCommandToAEDescList_fail;
	
	// create an apple event record for our command
	anErr = AECreateList( NULL, 0, true, &theCommandRecord );
	require_noerr( anErr, AddCommandToAEDescList_fail );
	
	// stick the command text into the aerecord
	anErr = AEPutKeyPtr( &theCommandRecord, keyAEName, typeUnicodeText, dataPtr, length * sizeof(UniChar));
	require_noerr( anErr, AddCommandToAEDescList_fail );
	
	// stick the command ID into the AERecord
	anErr = AEPutKeyPtr( &theCommandRecord, keyContextualMenuCommandID,
						typeLongInteger, &inCommandID, sizeof( inCommandID ) );
	require_noerr( anErr, AddCommandToAEDescList_fail );
	
	// stick this record into the list of commands that we are
	// passing back to the CMM
	anErr = AEPutDesc(ioCommandList, 			// the list we're putting our command into
					  0, 						// stick this command onto the end of our list
					  &theCommandRecord );	// the command I'm putting into the list
	
AddCommandToAEDescList_fail:
	// clean up after ourself; dispose of the AERecord
	AEDisposeDesc( &theCommandRecord );
	
	if (nil != tempPtr)
		DisposePtr((Ptr) tempPtr);
	
    return anErr;	
} // AddCommandToAEDescList



// -----------------------------------------------------------------------------
//	CreateProcessSubmenu
// -----------------------------------------------------------------------------
static OSStatus CreateProcessSubmenu(Str255* theSupercommandText, AEDescList* ioCommandList, char* filename) 
{
	OSStatus	anErr = noErr;
	AEDescList	theSubmenuCommands = { typeNull, NULL };
	AERecord	theSupercommand = { typeNull, NULL };
	
	// the first thing we should do is create an AEDescList of subcommands, so set up the AEDescList
	anErr = AECreateList( NULL, 0, false, &theSubmenuCommands );
	require_noerr( anErr, CreateProcessSubmenu_Complete_fail );
	
	char c[255]; 
	FILE *file; 
		
	// Open the file containing the menuItems
	file = fopen(filename, "r"); 
	if(file!=NULL) 
	{
		CFStringRef str;
		int i = 0;
		while(fgets(c, 255, file)!=NULL) 
		{ 
			str = CFStringCreateWithCString(kCFAllocatorDefault,
											c,
											kCFStringEncodingMacRoman); 			
			AddCommandToAEDescList(str, i, &theSubmenuCommands);
			i++;
		}
		fclose(file);
	}
	
	AddCommandToAEDescList(CFSTR("New Location"), -1, &theSubmenuCommands);
	
	// create the supercommand which will "own" the subcommands.
	anErr = AECreateList( NULL, 0, true, &theSupercommand );
	require_noerr( anErr, CreateProcessSubmenu_fail );
	
	// stick the command text into the aerecord
	anErr = AEPutKeyPtr(&theSupercommand, keyAEName, typeChar, &((*theSupercommandText)[1]), (*theSupercommandText)[0]);
	require_noerr( anErr, CreateProcessSubmenu_fail );
	
	// stick the subcommands into into the AERecord
	anErr = AEPutKeyDesc(&theSupercommand, keyContextualMenuSubmenu,
						 &theSubmenuCommands);
	require_noerr( anErr, CreateProcessSubmenu_fail );
	
	// stick the supercommand into the list of commands that we are
	// passing back to the CMM
	anErr = AEPutDesc(
					  ioCommandList,		// the list we're putting our command into
					  0,					// stick this command onto the end of our list
					  &theSupercommand);	// the command I'm putting into the list
	
	// clean up after ourself
CreateProcessSubmenu_fail:
	AEDisposeDesc(&theSubmenuCommands);
	AEDisposeDesc(&theSupercommand);
CreateProcessSubmenu_Complete_fail:
	return anErr;
} // CreateProcessSubmenu



// -----------------------------------------------------------------------------
//	OneWayQueryInterface
// -----------------------------------------------------------------------------
//	Implementation of the IUnknown QueryInterface function.
//
static HRESULT OneWayQueryInterface(void* thisInstance,REFIID iid,LPVOID* ppv)
{
	// Create a CoreFoundation UUIDRef for the requested interface.
	CFUUIDRef	interfaceID = CFUUIDCreateFromUUIDBytes( NULL, iid );
	
	// Test the requested ID against the valid interfaces.
	if ( CFEqual( interfaceID, kContextualMenuInterfaceID ) )
	{
		// If the TestInterface was requested, bump the ref count,
		// set the ppv parameter equal to the instance, and
		// return good status.
		OneWayAddRef(thisInstance);
		
		*ppv = thisInstance;
		CFRelease( interfaceID );
		return S_OK;
	}
	else if ( CFEqual( interfaceID, IUnknownUUID ) )
	{
		// If the IUnknown interface was requested, same as above.
		OneWayAddRef(thisInstance);
		
		*ppv = thisInstance;
		CFRelease( interfaceID );
		return S_OK;
	}
	else
	{
		// Requested interface unknown, bail with error.
		*ppv = NULL;
		CFRelease( interfaceID );
		return E_NOINTERFACE;
	}
}



// -----------------------------------------------------------------------------
//	OneWayAddRef
// -----------------------------------------------------------------------------
//	Implementation of reference counting for this type. Whenever an interface
//	is requested, bump the refCount for the instance. NOTE: returning the
//	refcount is a convention but is not required so don't rely on it.
//
static ULONG OneWayAddRef( void *thisInstance )
{
	//DEBUGSTR("\p|OneWayAddRef-I-Debug;g");
	
	( ( OneWayType* ) thisInstance )->refCount += 1;
	return ( ( OneWayType* ) thisInstance)->refCount;
}



// -----------------------------------------------------------------------------
// OneWayRelease
// -----------------------------------------------------------------------------
//	When an interface is released, decrement the refCount.
//	If the refCount goes to zero, deallocate the instance.
//
static ULONG OneWayRelease( void *thisInstance )
{
	//DEBUGSTR("\p|OneWayRelease-I-Debug;g");
	
	((OneWayType*) thisInstance )->refCount -= 1;
	if (((OneWayType*) thisInstance)->refCount == 0)
	{
		DeallocOneWayType((OneWayType*) thisInstance);
		return 0;
	}
	else
	{
		return ((OneWayType*) thisInstance)->refCount;
	}
}



// -----------------------------------------------------------------------------
//	OneWayExamineContext
// -----------------------------------------------------------------------------
//	The implementation of the ExamineContext test interface function.
//
static OSStatus OneWayExamineContext( void* thisInstance, const AEDesc* inContext, AEDescList* outCommandPairs) 
{
	CFStringRef bundleCFStringRef = CFSTR("com.OneWay.plugin");
	CFBundleRef myCFBundleRef = CFBundleGetBundleWithIdentifier(bundleCFStringRef);
	ProcessInfoRec procInfo;
	ProcessSerialNumber curProcess;
	FSSpec appFSSpec;
	Str255 procName;
	Boolean isFinder = FALSE;
	
	if ( inContext != NULL ) {
		//AEDesc theAEDesc = { typeNull, NULL };
		CFStringRef	tempCFStringRef;
		/* Add the name of the Bundle to the menu */
		if (NULL != myCFBundleRef) {
			tempCFStringRef = CFBundleGetValueForInfoDictionaryKey(myCFBundleRef, CFSTR("CFBundleName"));
			tempCFStringRef = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@"), tempCFStringRef);
			if (NULL != tempCFStringRef) {
				
				CFRelease(tempCFStringRef);
			}
		}
		
		// Is this the Finder? Let's find out
		procInfo.processInfoLength = sizeof(ProcessInfoRec);
		procInfo.processName = procName;
		procInfo.processAppSpec = &appFSSpec;
		
		GetFrontProcess( &curProcess);
		
		if (noErr == GetProcessInformation(&curProcess, &procInfo)) {
			tempCFStringRef = CFStringCreateWithPascalString( NULL, (ConstStr255Param) &procName, kCFStringEncodingMacRoman);
			if (CFStringCompare( tempCFStringRef, CFSTR("Finder"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
				isFinder = TRUE;
			}
			CFRelease(tempCFStringRef);
		}
		
		if (isFinder) 
		{
//			struct	stat	statbuf;
			char			*menuItemFile;
			int				menuItemLength;
			
			/* 
			 Check for "~/Library/OneWay/.menuItems" 
			 */
			menuItemLength = strlen(getenv("HOME")) + 1;
			menuItemFile = malloc(menuItemLength + strlen("/Library/OneWay/.menuItems") + 1);
			strncpy(menuItemFile, getenv("HOME"), menuItemLength);
			strncat(menuItemFile, "/Library/OneWay/.menuItems", 34);
//			if (lstat(menuItemFile, &statbuf) == 0) 
//			{
				// File Exists, Create the SCP Submenu
				Str255 menuName = "\pOneWay";
				CreateProcessSubmenu(&menuName, outCommandPairs, menuItemFile);
//			}
		}
	}
	
	return noErr;
}



// -----------------------------------------------------------------------------
//	HandleFileSubmenu
// -----------------------------------------------------------------------------
static OSStatus HandleFileSubmenu(const AEDesc* inContext,const SInt32 inCommandID)
{
	long	index,numItems;
	OSStatus	anErr = noErr;
	
	anErr = AECountItems(inContext,&numItems);
	if (noErr == anErr) 
	{
		// Array of files to act on
		//
		CFMutableArrayRef fileList = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
		//
		for (index = 1;index <= numItems;index++) 
		{
			AEKeyword	theAEKeyword;
			AEDesc		theAEDesc;
			
			anErr = AEGetNthDesc(inContext,index,typeAlias,&theAEKeyword,&theAEDesc);
			if (noErr != anErr) continue;
			
			if (theAEDesc.descriptorType == typeAlias) 
			{
				FSRef tFSRef;
				Size dataSize = AEGetDescDataSize(&theAEDesc);
				AliasHandle tAliasHdl = (AliasHandle) NewHandle(dataSize);
				
				if (nil != tAliasHdl) 
				{
					Boolean wasChanged;
					
					anErr = AEGetDescData(&theAEDesc,*tAliasHdl,dataSize);
					if (noErr == anErr) 
					{
						anErr = FSResolveAlias(NULL,tAliasHdl,&tFSRef,&wasChanged);
						if (noErr == anErr) 
						{
							
							CFURLRef tCFURLRef = CFURLCreateFromFSRef(kCFAllocatorDefault, &tFSRef);
							CFStringRef theFilename = CFURLCopyFileSystemPath(tCFURLRef,kCFURLPOSIXPathStyle);
							CFRelease(tCFURLRef);
							
							if (NULL != theFilename) 
							{
								// Add the queue command to our array
								CFStringRef quotedFilename = CFStringCreateWithFormat(NULL, NULL, CFSTR("\"%@\""), theFilename);
								CFArrayAppendValue(fileList, quotedFilename);
								CFRelease(theFilename);
								CFRelease(quotedFilename);
								//
							}
						}
					}
					DisposeHandle((Handle) tAliasHdl);
				}
			}
			AEDisposeDesc(&theAEDesc);
		}
		
		
		CFStringRef joinedFiles = CFStringCreateByCombiningStrings(kCFAllocatorDefault, fileList, CFSTR(", "));
		
		char * joinedFilesCString = Copy_CFStringRefToCString(joinedFiles);
		char * scriptBuffer = malloc(strlen(joinedFilesCString) + 99);
		
		/*
		 
		 tell application "OneWay"
			set x to location 0
			queue transfer x with files {"file1", "file2"}
			queue new transfer {"file1", "file2"}
		 end tell
		 
		 */
		int locationNumber = (int)inCommandID;
		
		if (locationNumber == -1)
		{
			sprintf(scriptBuffer,  "tell application \"OneWay\"\n queue new transfer {%s}\nend tell", joinedFilesCString);	
		}
		else
		{
			sprintf(scriptBuffer,  "tell application \"OneWay\"\n set x to location %i\n queue transfer x with files {%s}\nend tell", locationNumber + 1, joinedFilesCString);
		}
		
		SimpleRunAppleScript(scriptBuffer);
		
		CFRelease(fileList);
		CFRelease(joinedFiles);
		free(joinedFilesCString);
		free(scriptBuffer);
		
	}
	
	return anErr;
} // HandleFileSubmenu



// -----------------------------------------------------------------------------
//	HandleSelection
// -----------------------------------------------------------------------------
//	The implementation of the HandleSelection test interface function.
//
static OSStatus OneWayHandleSelection(void* thisInstance, AEDesc* inContext, SInt32 inCommandID ) 
{
	// make sure the descriptor isn't null
	if ( inContext != NULL )
	{
		AEDesc theAEDesc = { typeNull, NULL };
		
		if (inContext->descriptorType == typeAEList)
		{
			HandleFileSubmenu( inContext, inCommandID );
		}
		else if (inContext->descriptorType == typeAlias)
		{
			if ( AECoerceDesc( inContext, typeAEList, &theAEDesc ) == noErr )
			{
				HandleFileSubmenu( &theAEDesc, inCommandID );
				AEDisposeDesc( &theAEDesc );
			}
			else
			{
				printf("OneWayHandleSelection: Unable to coerce to list.\n" );
			}
		}
	}
	else
	{
		// we have a null descriptor
	}
	
	return noErr;
}



// -----------------------------------------------------------------------------
//	PostMenuCleanup
// -----------------------------------------------------------------------------
//	The implementation of the PostMenuCleanup test interface function.
//
static void OneWayPostMenuCleanup( void *thisInstance )
{
	//DEBUGSTR("\p|OneWayPostMenuCleanup-I-Debug;g");
	
	//printf("\nOneWay->OneWayPostMenuCleanup(instance: 0x%x)",
	//	( unsigned ) thisInstance );
	
	// No need to clean up.  We are a tidy folk.
}
