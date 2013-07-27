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

#include "jsb_config.h"
#include "jsb_core.h"
#include "jsb_opengl_manual.h"


// system
#import "jsb_opengl_functions.h"

void JSB_register_opengl( JSContext *_cx, JSObject *object)
{
	//
	// gl
	//
	JSObject *opengl = JS_NewObject(_cx, NULL, NULL, NULL);
	jsval openglVal = OBJECT_TO_JSVAL(opengl);
	JS_SetProperty(_cx, object, "gl", &openglVal);


	// New WebGL functions, not present on OpenGL ES 2.0
	JS_DefineFunction(_cx, opengl, "getSupportedExtensions", JSB_glGetSupportedExtensions, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );



#import "jsb_opengl_functions_registration.h"
		
}

