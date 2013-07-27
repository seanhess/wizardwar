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


#ifndef __JS_BINDINGS_CONFIG_H
#define __JS_BINDINGS_CONFIG_H


/** @def JSB_ASSERT_ON_FAIL
 Wheter or not to assert when the arguments or conversions are incorrect.
 It is recommened to turn it off in Release mode.
 */
#ifndef JSB_ASSERT_ON_FAIL
#define JSB_ASSERT_ON_FAIL 0
#endif


#if JSB_ASSERT_ON_FAIL
#define JSB_PRECONDITION( condition, error_msg) do { NSCAssert( condition, [NSString stringWithUTF8String:error_msg] ); } while(0)
#define JSB_PRECONDITION2( condition, context, ret_value, error_msg) do { NSCAssert( condition, [NSString stringWithUTF8String:error_msg] ); } while(0)
#define ASSERT( condition, error_msg) do { NSCAssert( condition, [NSString stringWithUTF8String:error_msg] ); } while(0)

#else
#define JSB_PRECONDITION( condition, error_msg) do {							\
	if( ! (condition) ) {														\
		JSContext* globalContext = [[JSBCore sharedInstance] globalContext];	\
		if( ! JS_IsExceptionPending( globalContext ) ) {						\
			printf("jsb: ERROR in %s: %s\n", __FUNCTION__, error_msg);			\
			JS_ReportError( globalContext, error_msg );							\
		} else {																\
			JS_ReportPendingException(globalContext);							\
		}																		\
		return JS_FALSE;														\
	}																			\
} while(0)
#define JSB_PRECONDITION2( condition, context, ret_value, error_msg) do {		\
	if( ! (condition) ) {														\
		printf("jsb: ERROR in %s: %s\n", __FUNCTION__, error_msg);				\
		if( ! JS_IsExceptionPending( context ) ) {								\
			printf("jsb: ERROR in %s: %s\n", __FUNCTION__, error_msg);			\
		} else {																\
			JS_ReportPendingException(context);									\
		}																		\
		return ret_value;														\
	}																			\
} while(0)
#define ASSERT( condition, error_msg) do {										\
	if( ! (condition) ) {														\
		printf("jsb: ERROR in %s: %s\n", __FUNCTION__, error_msg);				\
		return false;															\
	}																			\
	} while(0)
#endif



/** @def JSB_REPRESENT_LONGLONG_AS_STR
 When JSB_REPRESENT_LONGLONG_AS_STR is defined, the long long will be represented as JS strings.
 Otherwise they will be represented as an array of two intengers.
 It is needed to to use an special representation since there are no 64-bit integers in JS.
 Representing the long long as string could be a bit slower, but it is easier to debug from JS.
 Enabled by default.
 */
#ifndef JSB_REPRESENT_LONGLONG_AS_STR
#define JSB_REPRESENT_LONGLONG_AS_STR 1
#endif // JSB_REPRESENT_LONGLONG_AS_STR


/** @def JSB_INCLUDE_NS
 Whether or not it should include JS bindings for basic NS* / Cocoa / CocoaTouch objects.
 It should be enabled in order to support bindings for any objective-c projects.
 Not needed for pure C projects.
 Enabled by default.
 */
#ifndef JSB_INCLUDE_NS
#define JSB_INCLUDE_NS 1
#endif // JSB_INCLUDE_NS


/** @def JSB_INCLUDE_COCOS2D
 Whether or not it should include JS bindings for cocos2d.
 */
#ifndef JSB_INCLUDE_COCOS2D
#define JSB_INCLUDE_COCOS2D 1

#import "cocos2d.h"
#if defined(__CC_PLATFORM_IOS)
#define JSB_INCLUDE_COCOS2D_IOS 1
#elif defined(__CC_PLATFORM_MAC)
#define JSB_INCLUDE_COCOS2D_MAC 1
#endif

#endif // JSB_INCLUDE_COCOS2D


/** @def JSB_INCLUDE_CHIPMUNK
 Whether or not it should include JS bindings for Chipmunk
 */
#ifndef JSB_INCLUDE_CHIPMUNK
#define JSB_INCLUDE_CHIPMUNK 1
#endif // JSB_INCLUDE_CHIPMUNK


/** @def JSB_INCLUDE_COCOSBUILDERREADER
 Whether or not it should include JS bindings for CocosBuilder Reader
 */
#ifndef JSB_INCLUDE_COCOSBUILDERREADER
#define JSB_INCLUDE_COCOSBUILDERREADER 1
#endif // JSB_INCLUDE_COCOSBUILDERREADER

/** @def JSB_INCLUDE_COCOSDENSHION
 Whether or not it should include bindings for CocosDenshion (sound engine)
 */
#ifndef JSB_INCLUDE_COCOSDENSHION
#define JSB_INCLUDE_COCOSDENSHION 1
#endif // JSB_INCLUDE_COCOSDENSHION

/** @def JSB_INCLUDE_SYSTEM
 Whether or not it should include bindings for system components like LocalStorage
 */
#ifndef JSB_INCLUDE_SYSTEM
#define JSB_INCLUDE_SYSTEM 1
#endif // JSB_INCLUDE_SYSTEM

/** @def JSB_INCLUDE_OPENGL
 Whether or not it should include bindings for WebGL / OpenGL ES 2.0
 */
#ifndef JSB_INCLUDE_OPENGL
#define JSB_INCLUDE_OPENGL 1
#endif // JSB_INCLUDE_OPENGL

/** @def JSB_ENABLE_JSC_AUTOGENERATION
 Set this to 1 to enable auto "JS Encoded" (.jsc) files from JS (.js) files.
 - .jsc files load 15% faster than .js files.
 - Generating the .jsc files increases the "parsing" time in about %60 (it is done only once).
 - .jsc files could be used to protect the source code your JavaScript code.
 */
#ifndef JSB_ENABLE_JSC_AUTOGENERATION
#define JSB_ENABLE_JSC_AUTOGENERATION 0
#endif // JSB_ENABLE_JSC_AUTOGENERATION

/** @def JSB_ENABLE_DEBUGGER
 Set this to 1 to enable the debugger
 */
#ifndef JSB_ENABLE_DEBUGGER
#define JSB_ENABLE_DEBUGGER 0
#endif // JSB_ENABLE_DEBUGGER

/** @def JSB_DEBUGGER_OUTPUT_STDOUT
 Set this to 1 to send the debugger output to the stdout *and* to the socket
 */
#ifndef JSB_DEBUGGER_OUTPUT_STDOUT
#define JSB_DEBUGGER_OUTPUT_STDOUT 0
#endif // JSB_DEBUGGER_OUTPUT_STDOUT

/** @def JSB_DEBUGGER_PORT
 TCP port used to connect to the debugger
 */
#ifndef JSB_DEBUGGER_PORT
#define JSB_DEBUGGER_PORT 5086
#endif // JSB_DEBUGGER_PORT

#ifndef JSB_MAX_STACK_QUOTA
#ifdef DEBUG
#define JSB_MAX_STACK_QUOTA 5000000
#else
#define JSB_MAX_STACK_QUOTA 500000
#endif
#endif // JSB_MAX_STACK_QUOTA

#if JSB_ENABLE_DEBUGGER
#define JSB_ENSURE_AUTOCOMPARTMENT(cx, obj) \
JSAutoCompartment ac(cx, obj)
#else
#define JSB_ENSURE_AUTOCOMPARTMENT(cx, obj)
#endif

#endif // __JS_BINDINGS_CONFIG_H
