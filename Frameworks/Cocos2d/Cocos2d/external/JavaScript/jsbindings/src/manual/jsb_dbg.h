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

#ifndef __JSB_DBG__
#define __JSB_DBG__

#include <string>
#include <map>
#import "jsb_core.h"

@interface JSBCore (Debugger)
- (void)debugProcessInput:(NSString *)str;
- (void)enableDebugger;
@end

extern std::map<std::string, js::RootedScript*> __scripts;

#ifdef __cplusplus
extern "C" {
#endif

void debugProcessInput(std::string data);

JSBool JSBDebug_StartDebugger(JSContext* cx, unsigned argc, jsval* vp);
JSBool JSBDebug_BufferRead(JSContext* cx, unsigned argc, jsval* vp);
JSBool JSBDebug_BufferWrite(JSContext* cx, unsigned argc, jsval* vp);
JSBool JSBDebug_LockExecution(JSContext* cx, unsigned argc, jsval* vp);
JSBool JSBDebug_UnlockExecution(JSContext* cx, unsigned argc, jsval* vp);

#ifdef __cplusplus
}
#endif

#endif
