/*
 * JS Bindings: https://github.com/zynga/jsbindings
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "jsb_config.h"
#import "jsb_core.h"

// NS
#import "jsb_NS_manual.h"

// cocos2d + chipmunk registration files
#import "jsb_cocos2d_registration.h"
#import "jsb_chipmunk_registration.h"
#import "jsb_system_registration.h"
#import "jsb_opengl_registration.h"

#include "jsdbgapi.h"
#include "jsb_dbg.h"

#pragma mark - Hash

typedef struct _hashJSObject
{
	JSObject			*jsObject;
	void				*proxy;
	UT_hash_handle		hh;
} tHashJSObject;

static tHashJSObject *hash = NULL;
static tHashJSObject *reverse_hash = NULL;

// Globals
char * JSB_association_proxy_key = NULL;

const char * JSB_version = "JSB v0.8";


static void its_finalize(JSFreeOp *fop, JSObject *obj)
{
	CCLOGINFO(@"Finalizing global class");
}

static JSClass global_class = {
	"__global", JSCLASS_GLOBAL_FLAGS,
	JS_PropertyStub, JS_PropertyStub,
	JS_PropertyStub, JS_StrictPropertyStub,
	JS_EnumerateStub, JS_ResolveStub,
	JS_ConvertStub, its_finalize,
	JSCLASS_NO_OPTIONAL_MEMBERS
};

#pragma mark JSBCore - Helper free functions
static void reportError(JSContext *cx, const char *message, JSErrorReport *report)
{
	js_DumpBacktrace(cx);
#if DEBUG
//	js_DumpStackFrame(cx);
#endif
	fprintf(stdout, "%s:%u:%u %s\n",
			report->filename ? report->filename : "(no filename)",
			(unsigned int)report->lineno,
			(unsigned int)report->column,
			message);
};

#pragma mark JSBCore - Free JS functions

JSBool JSB_core_log(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc > 0) {
		JSString *string = NULL;
		JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &string);
		if (string) {
			char *cstr = JS_EncodeString(cx, string);
			fprintf(stdout, "%s\n", cstr);
		}

		return JS_TRUE;
	}
	return JS_FALSE;
};

JSBool JSB_core_executeScript(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION2(argc==1, cx, JS_FALSE, "Invalid number of arguments in executeScript");

	JSBool ok = JS_FALSE;
	JSString *string;
	if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &string) == JS_TRUE) {
		ok = [[JSBCore sharedInstance] runScript: [NSString stringWithCString:JS_EncodeString(cx, string) encoding:NSUTF8StringEncoding] ];
	}

	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error executing script");

	return ok;
};

JSBool JSB_core_associateObjectWithNative(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION(argc==2, "Invalid number of arguments in associateObjectWithNative");


	jsval *argvp = JS_ARGV(cx,vp);
	JSObject *pureJSObj;
	JSObject *nativeJSObj;
	JSBool ok = JS_TRUE;
	ok &= JS_ValueToObject( cx, *argvp++, &pureJSObj );
	ok &= JS_ValueToObject( cx, *argvp++, &nativeJSObj );

	JSB_PRECONDITION2(ok && pureJSObj && nativeJSObj, cx, JS_FALSE, "Error parsing parameters");

	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject( nativeJSObj );
	JSB_set_proxy_for_jsobject( proxy, pureJSObj );
	[proxy setJsObj:pureJSObj];

	return JS_TRUE;
};

JSBool JSB_core_getAssociatedNative(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION2(argc==1, cx, JS_FALSE, "Invalid number of arguments in getAssociatedNative");

	jsval *argvp = JS_ARGV(cx,vp);
	JSObject *pureJSObj;
	JS_ValueToObject( cx, *argvp++, &pureJSObj );

	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject( pureJSObj );
	id native = [proxy realObj];

	JSObject * obj = JSB_get_or_create_jsobject_from_realobj(cx, native);
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(obj) );

	return JS_TRUE;
};


JSBool JSB_core_platform(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION2(argc==0, cx, JS_FALSE, "Invalid number of arguments in __getPlatform");

	JSString * platform;

// iOS is always 32 bits
#ifdef __CC_PLATFORM_IOS
	platform = JS_InternString(cx, "mobile");

// Mac can be 32 or 64 bits
#elif defined(__CC_PLATFORM_MAC)
	platform = JS_InternString(cx, "desktop");
#else // unknown platform
#error "Unsupported platform"
#endif
	jsval ret = STRING_TO_JSVAL(platform);

	JS_SET_RVAL(cx, vp, ret);

	return JS_TRUE;
};

JSBool JSB_core_version(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION2(argc==0, cx, JS_FALSE, "Invalid number of arguments in __getVersion");
	
	char version[256];
	snprintf(version, sizeof(version)-1, "%s - %s", cocos2d_version, JSB_version);
	JSString * js_version = JS_InternString(cx, version);
	
	jsval ret = STRING_TO_JSVAL(js_version);
	JS_SET_RVAL(cx, vp, ret);
	
	return JS_TRUE;
};

JSBool JSB_core_os(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION2(argc==0, cx, JS_FALSE, "Invalid number of arguments in __getOS");
	
	JSString * os;
	
	// iOS is always 32 bits
#ifdef __CC_PLATFORM_IOS
	os = JS_InternString(cx, "iOS");
#elif defined(__CC_PLATFORM_MAC)
	os = JS_InternString(cx, "OS X");
#endif
	
	jsval ret = STRING_TO_JSVAL(os);
	JS_SET_RVAL(cx, vp, ret);
	
	return JS_TRUE;
};


/* Register an object as a member of the GC's root set, preventing them from being GC'ed */
JSBool JSB_core_addRootJS(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION2(argc==1, cx, JS_FALSE, "Invalid number of arguments in addRootJS");

	JSObject *o = NULL;
	if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "o", &o) == JS_TRUE) {
		if (JS_AddObjectRoot(cx, &o) == JS_FALSE) {
			CCLOGWARN(@"something went wrong when setting an object to the root");
		}
	}

	return JS_TRUE;
};

/*
 * removes an object from the GC's root, allowing them to be GC'ed if no
 * longer referenced.
 */
JSBool JSB_core_removeRootJS(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION2(argc==1, cx, JS_FALSE, "Invalid number of arguments in removeRootJS");

	JSObject *o = NULL;
	if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "o", &o) == JS_TRUE) {
		JS_RemoveObjectRoot(cx, &o);
	}
	return JS_TRUE;
};

/*
 * Dumps GC
 */
//static void dumpNamedRoot(const char *name, void *addr,  JSGCRootType type, void *data)
//{
//    printf("There is a root named '%s' at %p\n", name, addr);
//}

JSBool JSB_core_dumpRoot(JSContext *cx, uint32_t argc, jsval *vp)
{
	// JS_DumpNamedRoots is only available on DEBUG versions of SpiderMonkey.
	// Mac and Simulator versions were compiled with DEBUG.
#if DEBUG && (defined(__CC_PLATFORM_MAC) || TARGET_IPHONE_SIMULATOR )
//	JSRuntime *rt = [[JSBCore sharedInstance] runtime];
//	JS_DumpNamedRoots(rt, dumpNamedRoot, NULL);eff

//	JSRuntime *rt = [[JSBCore sharedInstance] runtime];
//	JS_DumpHeap(rt, stdout, NULL, JSTRACE_OBJECT, NULL, 2, NULL);

#endif
	return JS_TRUE;
};

/*
 * Force a cycle of GC
 */
JSBool JSB_core_forceGC(JSContext *cx, uint32_t argc, jsval *vp)
{
	JS_GC( [[JSBCore sharedInstance] runtime] );
	return JS_TRUE;
};

JSBool JSB_core_restartVM(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION2(argc==0, cx, JS_FALSE, "Invalid number of arguments in executeScript");

	[[JSBCore sharedInstance] restartRuntime];
	return JS_FALSE;
};


@implementation JSBCore

@synthesize globalObject = _object;
@synthesize globalContext = _cx;
@synthesize runtime = _rt;
@synthesize debugObject = _debugObject;

+ (id)sharedInstance
{
	static dispatch_once_t pred;
	static JSBCore *instance = nil;
	dispatch_once(&pred, ^{
		instance = [[self alloc] init];
	});
	return instance;
}

-(id) init
{
	self = [super init];
	if( self ) {

#if DEBUG
		printf("JavaScript Bindings - %s\n", JSB_version);

#if JSB_ENABLE_DEBUGGER
		printf("Debugger enabled. Listening on port: %d\n", JSB_DEBUGGER_PORT);
#endif //JSB_ENABLE_DEBUGGER
#endif // DEBUG

		// Must be called only once, and before creating a new runtime
		// XXX: Removed in SpiderMonkey 19.0
//		JS_SetCStringsAreUTF8();

		[self createRuntime];
	}

	return self;
}

JSPrincipals shellTrustedPrincipals = { 1 };

JSBool
CheckObjectAccess(JSContext *cx, js::HandleObject obj, js::HandleId id, JSAccessMode mode,
                  js::MutableHandleValue vp)
{
    return true;
}

JSSecurityCallbacks securityCallbacks = {
    CheckObjectAccess,
    NULL
};

-(void) createRuntime
{
	NSAssert(_rt == NULL && _cx==NULL, @"runtime already created. Reset it first");

	_rt = JS_NewRuntime(32L * 1024L * 1024L, JS_USE_HELPER_THREADS);
    JS_SetGCParameter(_rt, JSGC_MAX_BYTES, 0xffffffff);
	
    JS_SetTrustedPrincipals(_rt, &shellTrustedPrincipals);
    JS_SetSecurityCallbacks(_rt, &securityCallbacks);
	JS_SetNativeStackQuota(_rt, JSB_MAX_STACK_QUOTA);
	_cx = JS_NewContext( _rt, 8192);
	JS_SetVersion(_cx, JSVERSION_LATEST);
	JS_SetOptions(_cx, JSOPTION_VAROBJFIX | JSOPTION_TYPE_INFERENCE);
	JS_SetErrorReporter(_cx, reportError);
	_object = new js::RootedObject(_cx, JSB_NewGlobalObject(_cx, false));
#if JSB_ENABLE_DEBUGGER
	JS_SetDebugMode(_cx, JS_TRUE);
	[self enableDebugger];
#endif
}

+(void) reportErrorWithContext:(JSContext*)cx message:(NSString*)message report:(JSErrorReport*)report
{

}

+(JSBool) logWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;
}

+(JSBool) executeScriptWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;
}

+(JSBool) addRootJSWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;
}

+(JSBool) removeRootJSWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;
}

+(JSBool) forceGCWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;
}

-(void) purgeCache
{
    tHashJSObject *current, *tmp;
    HASH_ITER(hh, hash, current, tmp) {
		HASH_DEL(hash, current);
		JSB_NSObject *proxy = (JSB_NSObject*) current->proxy;
		[proxy unrootJSObject];
		free(current);
    }

	HASH_ITER(hh, reverse_hash, current, tmp) {
		HASH_DEL(reverse_hash, current);
		free(current);
    }
}

-(void) shutdown
{
	// clean cache
	[self purgeCache];

	JS_DestroyContext(_cx);
	JS_DestroyRuntime(_rt);
	_cx = NULL;
	_rt = NULL;
}

-(void) restartRuntime
{
	[self shutdown];
	[self createRuntime];
}

-(BOOL) evalString:(NSString*)string outVal:(jsval*)outVal
{
	jsval rval;
	JSString *str;
	JSBool ok;
	const char *filename = "noname";
	uint32_t lineno = 0;
	if (outVal == NULL) {
		outVal = &rval;
	}
	const char *cstr = [string UTF8String];
	ok = JS_EvaluateScript( _cx, _object->get(), cstr, (unsigned)strlen(cstr), filename, lineno, outVal);
	if (ok == JS_FALSE) {
		CCLOGWARN(@"error evaluating script:%@", string);
	}
	str = JS_ValueToString( _cx, rval);
	return ok;
}

/*
 * This function works OK if it JS_SetCStringsAreUTF8() is called.
 */
-(JSBool) runScript:(NSString*)filename
{
	return [self runScript:filename withContainer:_object->get()];
}

- (JSBool)runScript:(NSString*)filename withContainer:(JSObject *)global
{
	JSBool ok = JS_FALSE;
	NSString *fullpathJSC = nil, *fullpathJS = nil;
	NSString *filenameJSC = nil;
	JSScript *script = NULL;

	CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];

	// a) check for .js on specified directory, and get .jsc filename
	fullpathJS = [fileUtils fullPathForFilenameIgnoringResolutions:filename];
	filenameJSC = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"jsc"];

	// b) No .js ? Check for .jsc on specified directory ?
	if( ! fullpathJS)
		fullpathJSC = [fileUtils fullPathForFilenameIgnoringResolutions:filenameJSC];

	// c) No .js and no .jsc ? -> error
	if( !fullpathJS && ! fullpathJSC) {
		char tmp[256];
		snprintf(tmp, sizeof(tmp)-1, "File not found: %s", [fullpathJS UTF8String]);
		JSB_PRECONDITION(fullpathJS || fullpathJSC, tmp);
	}

	// d) if .jsc on specified directory, get its script
	if( fullpathJSC)
		script = [self decodeScript:fullpathJSC];

#if	JSB_ENABLE_JSC_AUTOGENERATION
	else {
		// e) if not .jsc on specified directory, check for .jsc on cache directory
		NSString *cachedFullpathJSC = [self cachedFullpathForJSC:filenameJSC];

		// f) if .jsc on cache is newer than .js, execute cached file
		if( cachedFullpathJSC ) {
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSDictionary* attrs = [fileManager attributesOfItemAtPath:cachedFullpathJSC error:nil];
			NSDate *jscDate = [attrs fileCreationDate];

			// .js date
			NSDictionary* jsAttrs = [fileManager attributesOfItemAtPath:fullpathJS error:nil];
			NSDate *jsDate = [jsAttrs fileCreationDate];

			if( [jscDate compare:jsDate] == NSOrderedDescending) {

				script = [self decodeScript:cachedFullpathJSC];
			}
		}
	}
#endif // JSB_ENABLE_JSC_AUTOGENERATION


	js::RootedObject obj(_cx, global);

	// g) Failed to get encoded scripts ? Then execute .js file and create .jsc on cache
	if( ! script ) {
		JS::CompileOptions options(_cx);
		options.setUTF8(true)
				.setFileAndLine([fullpathJS UTF8String], 1);
		script = JS::Compile(_cx, obj, options, [fullpathJS UTF8String]);

#if JSB_ENABLE_JSC_AUTOGENERATION
		[self encodeScript:script filename:filenameJSC];
#endif // JSB_ENABLE_JSC_AUTOGENERATION
	}

	JSB_PRECONDITION(script, "Error compiling script");
	{
		JSB_ENSURE_AUTOCOMPARTMENT(_cx, obj);
		jsval result;
		ok = JS_ExecuteScript(_cx, obj, script, &result);
	}
	if (!ok) {
		char tmp[256];
		snprintf(tmp, sizeof(tmp)-1, "Error executing script: %s", [filename UTF8String]);
		JSB_PRECONDITION(ok, tmp);
	}


	// XXX: is this needed ?
	// add script to the global map
	const char* key = [filename UTF8String];
	if (__scripts[key]) {
		js::RootedScript* tmp = __scripts[key];
		__scripts.erase(key);
		delete tmp;
	}
	js::RootedScript* rootedScript = new js::RootedScript(_cx, script);
	__scripts[key] = rootedScript;

    return ok;
}

- (NSString*) cachedFullpathForJSC:(NSString*)filename
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];

	NSString *fullpath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, filename];
	if( [[NSFileManager defaultManager] fileExistsAtPath:fullpath] )
		return fullpath;
	return nil;
}

- (JSScript*)decodeScript:(NSString*)filename
{
	NSData *data = [NSData dataWithContentsOfFile:filename];
	JSB_PRECONDITION(data, "Error running encoded script");

	return JS_DecodeScript(_cx, [data bytes], [data length], NULL, NULL);
}

-(void) encodeScript:(JSScript *)script filename:(NSString*)filename
{
	uint32_t len;
	void *bytes = JS_EncodeScript(_cx, script, &len);

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];

	NSString *fullpath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, filename];

	// create directory
	NSError *error = nil;
	NSString *p = [fullpath stringByDeletingLastPathComponent];
	[[NSFileManager defaultManager] createDirectoryAtPath:p
							  withIntermediateDirectories:YES
											   attributes:nil
													error:&error];

	NSData *data = [NSData dataWithBytes:bytes length:len];
	[data writeToFile:fullpath atomically:NO];
}

-(void) dealloc
{
	[super dealloc];

	if (_object) {
		delete _object;
	}
	if (_debugObject) {
		delete _debugObject;
	}

	JS_DestroyContext(_cx);
	JS_DestroyRuntime(_rt);
	JS_ShutDown();
}
@end


#pragma mark JSObject-> Proxy

// Hash of JSObject -> proxy
void* JSB_get_proxy_for_jsobject(JSObject *obj)
{
	tHashJSObject *element = NULL;
	HASH_FIND_INT(hash, &obj, element);

	if( element )
		return element->proxy;
	return nil;
}

void JSB_set_proxy_for_jsobject(void *proxy, JSObject *obj)
{
	NSCAssert( !JSB_get_proxy_for_jsobject(obj), @"Already added. abort");

//	printf("Setting proxy for: %p - %p (%s)\n", obj, proxy, [[proxy description] UTF8String] );

	tHashJSObject *element = (tHashJSObject*) malloc( sizeof( *element ) );

	// XXX: Do not retain it here.
//	[proxy retain];
	element->proxy = proxy;
	element->jsObject = obj;

	HASH_ADD_INT( hash, jsObject, element );
}

void JSB_del_proxy_for_jsobject(JSObject *obj)
{
	tHashJSObject *element = NULL;
	HASH_FIND_INT(hash, &obj, element);
	if( element ) {
		HASH_DEL(hash, element);
		free(element);
	}
}

#pragma mark Proxy -> JSObject

// Reverse hash: Proxy -> JSObject
JSObject* JSB_get_jsobject_for_proxy(void *proxy)
{
	tHashJSObject *element = NULL;
	HASH_FIND_INT(reverse_hash, &proxy, element);

	if( element )
		return element->jsObject;
	return NULL;
}

void JSB_set_jsobject_for_proxy(JSObject *jsobj, void* proxy)
{
	NSCAssert( !JSB_get_jsobject_for_proxy(proxy), @"Already added. abort");

	tHashJSObject *element = (tHashJSObject*) malloc( sizeof( *element ) );

	element->proxy = proxy;
	element->jsObject = jsobj;

	HASH_ADD_INT( reverse_hash, proxy, element );
}

void JSB_del_jsobject_for_proxy(void* proxy)
{
	tHashJSObject *element = NULL;
	HASH_FIND_INT(reverse_hash, &proxy, element);
	if( element ) {
		HASH_DEL(reverse_hash, element);
		free(element);
	}
}

#pragma mark


JSBool JSB_set_reserved_slot(JSObject *obj, uint32_t idx, jsval value)
{
	JSClass *klass = JS_GetClass(obj);
	NSUInteger slots = JSCLASS_RESERVED_SLOTS(klass);
	if( idx >= slots )
		return JS_FALSE;

	JS_SetReservedSlot(obj, idx, value);

	return JS_TRUE;
}

#pragma mark "C" proxy functions

struct jsb_c_proxy_s* JSB_get_c_proxy_for_jsobject( JSObject *jsobj )
{
	struct jsb_c_proxy_s *proxy = (struct jsb_c_proxy_s *) JS_GetPrivate(jsobj);

	// DO not assert. This might be called from "finalize".
	// "finalize" could be called from a VM restart, and it is possible that no proxy was
	// associated with the jsobj yet
	if( ! proxy )
		CCLOGWARN(@"Could you find proxy for jsboject: %p ", jsobj);

	return proxy;
}

void JSB_del_c_proxy_for_jsobject( JSObject *jsobj )
{
	struct jsb_c_proxy_s *proxy = (struct jsb_c_proxy_s *) JS_GetPrivate(jsobj);
	NSCAssert(proxy, @"Invalid proxy for JSObject");
	JS_SetPrivate(jsobj, NULL);

	free(proxy);
}

void JSB_set_c_proxy_for_jsobject( JSObject *jsobj, void *handle, unsigned long flags)
{
	struct jsb_c_proxy_s *proxy = (struct jsb_c_proxy_s*) malloc(sizeof(*proxy));
	NSCAssert(proxy, @"No memory for proxy");

	proxy->handle = handle;
	proxy->flags = flags;
	proxy->jsobj = jsobj;

	JS_SetPrivate(jsobj, proxy);
}

JSObject* JSB_NewGlobalObject(JSContext* cx, bool empty)
{
	JSObject* glob = JS_NewGlobalObject(cx, &global_class, NULL);
	if (!glob)
		return NULL;

	{
		JSB_ENSURE_AUTOCOMPARTMENT(cx, glob);
		JSBool ok = JS_TRUE;
		ok = JS_InitStandardClasses(cx, glob);
		if (ok)
			JS_InitReflect(cx, glob);
		if (ok)
			ok = JS_DefineDebuggerObject(cx, glob);
		if (!ok)
			return NULL;
		
		if (empty) {
			JS_WrapObject(cx, &glob);
			return glob;
		}
		
		//
		// globals
		//
		JS_DefineFunction(cx, glob, "require", JSB_core_executeScript, 1, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(cx, glob, "__associateObjWithNative", JSB_core_associateObjectWithNative, 2, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(cx, glob, "__getAssociatedNative", JSB_core_getAssociatedNative, 2, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(cx, glob, "__getPlatform", JSB_core_platform, 0, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(cx, glob, "__getOS", JSB_core_os, 0, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(cx, glob, "__getVersion", JSB_core_version, 0, JSPROP_READONLY | JSPROP_PERMANENT);
		
		JS_DefineFunction(cx, glob, "__garbageCollect", JSB_core_forceGC, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(cx, glob, "__dumpRoot", JSB_core_dumpRoot, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(cx, glob, "__executeScript", JSB_core_executeScript, 1, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(cx, glob, "__restartVM", JSB_core_restartVM, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		
		//
		// 3rd party developer ?
		// Add here your own classes registration
		//
		
		// registers cocos2d, cocosdenshion and cocosbuilder reader bindings
#if JSB_INCLUDE_COCOS2D
		JSB_register_cocos2d(cx, glob);
#endif // JSB_INCLUDE_COCOS2D
		
		// registers chipmunk bindings
#if JSB_INCLUDE_CHIPMUNK
		JSB_register_chipmunk(cx, glob);
#endif // JSB_INCLUDE_CHIPMUNK
		
		// registers sys bindings
#if JSB_INCLUDE_SYSTEM
		JSB_register_system(cx, glob);
#endif // JSB_INCLUDE_SYSTEM
		
		// registers opengl bindings
#if JSB_INCLUDE_OPENGL
		JSB_register_opengl(cx, glob);
#endif // JSB_INCLUDE_OPENGL
		
	}
	JS_WrapObject(cx, &glob);
    return glob;
}

#pragma mark Do Nothing - Callbacks

JSBool JSB_do_nothing(JSContext *cx, uint32_t argc, jsval *vp)
{
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}
