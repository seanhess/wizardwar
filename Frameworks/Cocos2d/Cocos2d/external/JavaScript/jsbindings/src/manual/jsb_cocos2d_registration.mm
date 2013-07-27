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

#import "jsb_cocos2d_registration.h"

// cocos2d
#import "jsb_cocos2d_classes.h"
#import "jsb_cocos2d_functions.h"
#ifdef __CC_PLATFORM_IOS
#import "jsb_cocos2d_ios_classes.h"
#import "jsb_cocos2d_ios_functions.h"
#elif defined(__CC_PLATFORM_MAC)
#import "jsb_cocos2d_mac_classes.h"
#import "jsb_cocos2d_mac_functions.h"
#endif

// CocosDenshion
#import "jsb_CocosDenshion_classes.h"

// CocosBuilder reader
#import "jsb_CocosBuilderReader_classes.h"

// forward declarations
void JSB_GLNode_createClass(JSContext *cx, JSObject* globalObj, const char* name );
void JSB_register_cocos2d_config( JSContext *_cx, JSObject *cocos2d);

//

void JSB_register_cocos2d_config( JSContext *_cx, JSObject *cocos2d)
{
	JS_DefineFunction(_cx, cocos2d, "log", JSB_core_log, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
	
	JSB_NSObject_createClass(_cx, cocos2d, "Object");
#ifdef __CC_PLATFORM_MAC
	JSB_NSEvent_createClass(_cx, cocos2d, "Event");
#elif defined(__CC_PLATFORM_IOS)
	JSB_UITouch_createClass(_cx, cocos2d, "Touch");
	JSB_UIAccelerometer_createClass(_cx, cocos2d, "Accelerometer");
#endif	
}

void JSB_register_cocos2d( JSContext *_cx, JSObject *object)
{
	//
	// cocos2d
	//
	JSObject *cocos2d = JS_NewObject(_cx, NULL, NULL, NULL);
	jsval cocosVal = OBJECT_TO_JSVAL(cocos2d);
	JS_SetProperty(_cx, object, "cc", &cocosVal);
	

	// register "config" object
	JSB_register_cocos2d_config(_cx, cocos2d);

	
	// Register classes: base classes should be registered first

#import "jsb_cocos2d_classes_registration.h"
	// Manual GLNode registration
	JSB_GLNode_createClass(_cx, cocos2d, "GLNode");

#import "jsb_cocos2d_functions_registration.h"

#ifdef __CC_PLATFORM_IOS
	JSObject *cocos2d_ios = cocos2d;
#import "jsb_cocos2d_ios_classes_registration.h"
#import "jsb_cocos2d_ios_functions_registration.h"
#elif defined(__CC_PLATFORM_MAC)
	JSObject *cocos2d_mac = cocos2d;
#import "jsb_cocos2d_mac_classes_registration.h"
#import "jsb_cocos2d_mac_functions_registration.h"
#endif


	//
	// CocosDenshion
	//
	// Reuse "cc" namespace for CocosDenshion
	JSObject *CocosDenshion = cocos2d;
#import "jsb_CocosDenshion_classes_registration.h"

	//
	// CocosBuilderReader
	//
	// Reuse "cc" namespace for CocosBuilderReader
	JSObject *CocosBuilderReader = cocos2d;
#import "jsb_CocosBuilderReader_classes_registration.h"

}
