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

#ifndef __JSB_CORE_H
#define __JSB_CORE_H

#import <objc/runtime.h>
#include "jsapi.h"

#import "cocos2d.h"
#import "chipmunk.h"
#import "SimpleAudioEngine.h"

// Globals
// one shared key for associations
extern char * JSB_association_proxy_key;

/**
 */
@interface JSBCore : NSObject
{
	JSRuntime	*_rt;
	JSContext	*_cx;
	js::RootedObject* _object;
	js::RootedObject* _debugObject;
}

/** return the global context */
@property (nonatomic, readonly) JSRuntime* runtime;

/** return the global context */
@property (nonatomic, readonly) JSContext* globalContext;

/** return the global container */
@property (nonatomic, readonly) js::RootedObject* globalObject;

/** return the debug container */
@property (nonatomic, readonly) js::RootedObject* debugObject;

/** returns the shared instance */
+(JSBCore*) sharedInstance;

/**
 * @param cx
 * @param message
 * @param report
 */
+(void) reportErrorWithContext:(JSContext*)cx message:(NSString*)message report:(JSErrorReport*)report;

/**
 * Log something using CCLog
 * @param cx
 * @param argc
 * @param vp
 */
+(JSBool) logWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp;

/**
 * run a script from script :)
 */
+(JSBool) executeScriptWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp;

/**
 * Register an object as a member of the GC's root set, preventing
 * them from being GC'ed
 */
+(JSBool) addRootJSWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp;

/**
 * removes an object from the GC's root, allowing them to be GC'ed if no
 * longer referenced.
 */
+(JSBool) removeRootJSWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp;

/**
 * Force a cycle of GC
 */
+(JSBool) forceGCWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp;

/** creates a new runtime */
-(void) createRuntime;

/** restarts the JS runtime.
 It will call `shutdown` and then it will call `createRuntime`.
 */
-(void) restartRuntime;

/** Shutdown the VM.
 All created objects are going to be destroyed, including the caches
 */
-(void) shutdown;

/** Purge the caches that mantains associations between native and JS objects
 */
-(void) purgeCache;

/**
 * will eval the specified string
 * @param string The string with the javascript code to be evaluated
 * @param outVal The jsval that will hold the return value of the evaluation.
 * Can be NULL.
 */
-(BOOL) evalString:(NSString*)string outVal:(jsval*)outVal;

/**
 * will run the specified script using the default container
 * @param filename The path of the script to be run
 */
-(JSBool) runScript:(NSString*)filename;

/**
 * will run the specified script
 * @param filename The path of the script to be run
 * @param global The path of the script to be run
 */
-(JSBool) runScript:(NSString*)filename withContainer:(JSObject *)global;

-(JSScript*) decodeScript:(NSString*)filename;

-(void) encodeScript:(JSScript *)script filename:(NSString*)filename;

-(NSString*) cachedFullpathForJSC:(NSString*)path;

@end

#ifdef __cplusplus
extern "C" {
#endif

enum {
	JSB_C_FLAG_CALL_FREE = 0,
	JSB_C_FLAG_DO_NOT_CALL_FREE =1,
};

// structure used by "Object Oriented Functions".
// handle is a pointer to the native object
// flags: flags for the object
struct jsb_c_proxy_s {
	unsigned long flags;	// Should it be removed at "destructor" time, or not ?
	void *handle;			// native object, like cpSpace, cpBody, etc.
	JSObject *jsobj;		// JS Object. Needed for rooting / unrooting
};

// Functions for setting / removing / getting the proxy used by the "C" Object Oriented API. Think of Chipmunk classes
struct jsb_c_proxy_s* JSB_get_c_proxy_for_jsobject( JSObject *jsobj );
void JSB_del_c_proxy_for_jsobject( JSObject *jsobj );
void JSB_set_c_proxy_for_jsobject( JSObject *jsobj, void *handle, unsigned long flags);

// JSObject -> proxy
/** gets a proxy for a given JSObject */
void* JSB_get_proxy_for_jsobject(JSObject *jsobj);
/** sets a proxy for a given JSObject */
void JSB_set_proxy_for_jsobject(void* proxy, JSObject *jsobj);
/** dels a proxy for a given JSObject */
void JSB_del_proxy_for_jsobject(JSObject *jsobj);

// reverse: proxy -> JSObject
/** gets a JSObject for a given proxy */
JSObject* JSB_get_jsobject_for_proxy(void *proxy);
/** sets a JSObject for a given proxy */
void JSB_set_jsobject_for_proxy(JSObject *jsobj, void* proxy);
/** delts a JSObject for a given proxy */
void JSB_del_jsobject_for_proxy(void* proxy);

JSBool JSB_set_reserved_slot(JSObject *obj, uint32_t idx, jsval value);


// needed for callbacks. It does nothing.
JSBool JSB_do_nothing(JSContext *cx, uint32_t argc, jsval *vp);


// logs a format string to the console
JSBool JSB_core_log(JSContext *cx, uint32_t argc, jsval *vp);

JSObject* JSB_NewGlobalObject(JSContext* cx, bool empty);

extern const char* JSB_version;

#ifdef __cplusplus
}
#endif

#endif // __JSB_CORE_H
