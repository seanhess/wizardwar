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

#if JSB_INCLUDE_COCOS2D

#import "jsfriendapi.h"
#import "jsdbgapi.h"

#import "jsb_core.h"
#import "jsb_basic_conversions.h"
#import "jsb_cocos2d_classes.h"

#if __CC_PLATFORM_MAC
#import "jsb_cocos2d_mac_classes.h"
#elif __CC_PLATFORM_IOS
#import "jsb_cocos2d_ios_classes.h"
#endif

#pragma mark - GLNode Node


// Simple node that calls "draw" in JS
@interface GLNode : CCNode
@end

@implementation GLNode
-(void) draw
{
	JSB_CCNode *proxy = objc_getAssociatedObject(self, &JSB_association_proxy_key);
	if( proxy ) {
		JSObject *jsObj = [proxy jsObj];

		if (jsObj) {
			JSContext* cx = [[JSBCore sharedInstance] globalContext];
			JSBool found;
			JSB_ENSURE_AUTOCOMPARTMENT(cx, jsObj);
			JS_HasProperty(cx, jsObj, "draw", &found);
			if (found == JS_TRUE) {
				jsval rval, fval;
				jsval *argv = NULL; unsigned argc=0;

				JS_GetProperty(cx, jsObj, "draw", &fval);
				JS_CallFunctionValue(cx, jsObj, fval, argc, argv, &rval);
			}
		}
	}
}
@end

JSClass* JSB_GLNode_class = NULL;
JSObject* JSB_GLNode_object = NULL;

@interface JSB_GLNode : JSB_CCNode
@end

@implementation JSB_GLNode

+(JSObject*) createJSObjectWithRealObject:(id)realObj context:(JSContext*)cx
{
	JSObject *jsobj = JS_NewObject(cx, JSB_GLNode_class, JSB_GLNode_object, NULL);
	JSB_GLNode *proxy = [[JSB_GLNode alloc] initWithJSObject:jsobj class:[GLNode class]];
	[proxy setRealObj:realObj];

	if( realObj ) {
		objc_setAssociatedObject(realObj, &JSB_association_proxy_key, proxy, OBJC_ASSOCIATION_RETAIN);
		[proxy release];
	}

	[self swizzleMethods];

	return jsobj;
}
@end

// Constructor
JSBool JSB_GLNode_constructor(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject *jsobj = [JSB_GLNode createJSObjectWithRealObject:nil context:cx];
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	return JS_TRUE;
}

// Destructor
void JSB_GLNode_finalize(JSFreeOp *fop, JSObject *obj)
{
	CCLOGINFO(@"jsbindings: finalizing JS object %p (GLNode)", obj);
	//	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(obj);
	//	if (proxy) {
	//		[[proxy realObj] release];
	//	}
	JSB_del_proxy_for_jsobject( obj );
}

// 'ctor' method. Needed for subclassing native objects in JS
JSBool JSB_GLNode_ctor(JSContext *cx, uint32_t argc, jsval *vp) {

	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_PRECONDITION2( !JSB_get_proxy_for_jsobject(obj), cx, JS_FALSE, "Object already initialzied. error" );

	JSB_GLNode *proxy = [[JSB_GLNode alloc] initWithJSObject:obj class:[GLNode class]];
	[[proxy class] swizzleMethods];

	JS_SET_RVAL(cx, vp, JSVAL_TRUE);

	return JS_TRUE;
}

// Arguments:
// Ret value: GLNode* (o)
JSBool JSB_GLNode_node_static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION2( argc == 0, cx, JS_FALSE, "Invalid number of arguments" );
	GLNode* ret_val;
	ret_val = [GLNode node ];
	JS_SET_RVAL(cx, vp, JSB_jsval_from_NSObject(cx, ret_val));
	return JS_TRUE;
}

void JSB_GLNode_createClass(JSContext *cx, JSObject* globalObj, const char* name )
{
	JSB_GLNode_class = (JSClass *)calloc(1, sizeof(JSClass));
	JSB_GLNode_class->name = name;
	JSB_GLNode_class->addProperty = JS_PropertyStub;
	JSB_GLNode_class->delProperty = JS_PropertyStub;
	JSB_GLNode_class->getProperty = JS_PropertyStub;
	JSB_GLNode_class->setProperty = JS_StrictPropertyStub;
	JSB_GLNode_class->enumerate = JS_EnumerateStub;
	JSB_GLNode_class->resolve = JS_ResolveStub;
	JSB_GLNode_class->convert = JS_ConvertStub;
	JSB_GLNode_class->finalize = JSB_GLNode_finalize;
	JSB_GLNode_class->flags = 0;

	static JSPropertySpec properties[] = {
		{0, 0, 0, 0, 0}
	};
	static JSFunctionSpec funcs[] = {
		JS_FN("ctor", JSB_GLNode_ctor, 0, JSPROP_PERMANENT | JSPROP_ENUMERATE),
		JS_FS_END
	};
	static JSFunctionSpec st_funcs[] = {
		JS_FN("create", JSB_GLNode_node_static, 0, JSPROP_PERMANENT | JSPROP_ENUMERATE),
		JS_FS_END
	};

	JSB_GLNode_object = JS_InitClass(cx, globalObj, JSB_CCNode_object, JSB_GLNode_class, JSB_GLNode_constructor,0,properties,funcs,NULL,st_funcs);
	JSBool found;
	JS_SetPropertyAttributes(cx, globalObj, name, JSPROP_ENUMERATE | JSPROP_READONLY, &found);
}



#pragma mark - convertions

JSBool JSB_jsval_to_ccColor3B( JSContext *cx, jsval vp, ccColor3B *ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION( ok, "Error converting value to object");
	JSB_PRECONDITION( jsobj, "Not a valid JS object");

	jsval valr, valg, valb;
	ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "r", &valr);
	ok &= JS_GetProperty(cx, jsobj, "g", &valg);
	ok &= JS_GetProperty(cx, jsobj, "b", &valb);
	JSB_PRECONDITION( ok, "Error obtaining point properties");

	uint16_t r,g,b;
	ok &= JS_ValueToUint16(cx, valr, &r);
	ok &= JS_ValueToUint16(cx, valg, &g);
	ok &= JS_ValueToUint16(cx, valb, &b);
	JSB_PRECONDITION( ok, "Error converting value to numbers");

	ret->r = r;
	ret->g = g;
	ret->b = b;

	return JS_TRUE;
}

JSBool JSB_jsval_to_ccColor4B( JSContext *cx, jsval vp, ccColor4B *ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION( ok, "Error converting value to object");
	JSB_PRECONDITION( jsobj, "Not a valid JS object");

	jsval valr, valg, valb, vala;
	ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "r", &valr);
	ok &= JS_GetProperty(cx, jsobj, "g", &valg);
	ok &= JS_GetProperty(cx, jsobj, "b", &valb);
	ok &= JS_GetProperty(cx, jsobj, "a", &vala);
	JSB_PRECONDITION( ok, "Error obtaining point properties");

	uint16_t r,g,b,a;
	ok &= JS_ValueToUint16(cx, valr, &r);
	ok &= JS_ValueToUint16(cx, valg, &g);
	ok &= JS_ValueToUint16(cx, valb, &b);
	ok &= JS_ValueToUint16(cx, vala, &a);
	JSB_PRECONDITION( ok, "Error converting value to numbers");

	ret->r = r;
	ret->g = g;
	ret->b = b;
	ret->a = a;

	return JS_TRUE;
}

JSBool JSB_jsval_to_ccColor4F( JSContext *cx, jsval vp, ccColor4F *ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION( ok, "Error converting value to object");
	JSB_PRECONDITION( jsobj, "Not a valid JS object");

	jsval valr, valg, valb, vala;
	ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "r", &valr);
	ok &= JS_GetProperty(cx, jsobj, "g", &valg);
	ok &= JS_GetProperty(cx, jsobj, "b", &valb);
	ok &= JS_GetProperty(cx, jsobj, "a", &vala);
	JSB_PRECONDITION( ok, "Error obtaining point properties");

	double r,g,b,a;
	ok &= JS_ValueToNumber(cx, valr, &r);
	ok &= JS_ValueToNumber(cx, valg, &g);
	ok &= JS_ValueToNumber(cx, valb, &b);
	ok &= JS_ValueToNumber(cx, vala, &a);
	JSB_PRECONDITION( ok, "Error converting value to numbers");

	ret->r = r;
	ret->g = g;
	ret->b = b;
	ret->a = a;

	return JS_TRUE;
}

jsval JSB_jsval_from_ccColor3B( JSContext *cx, ccColor3B p )
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;

	if (!JS_DefineProperty(cx, object, "r", UINT_TO_JSVAL(p.r), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "g", UINT_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "b", UINT_TO_JSVAL(p.b), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;

	return OBJECT_TO_JSVAL(object);
}

jsval JSB_jsval_from_ccColor4B( JSContext *cx, ccColor4B p )
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;

	if (!JS_DefineProperty(cx, object, "r", UINT_TO_JSVAL(p.r), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "g", UINT_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "b", UINT_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "a", UINT_TO_JSVAL(p.b), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;

	return OBJECT_TO_JSVAL(object);
}

jsval JSB_jsval_from_ccColor4F( JSContext *cx, ccColor4F p )
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;

	if (!JS_DefineProperty(cx, object, "r", DOUBLE_TO_JSVAL(p.r), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "g", DOUBLE_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "b", DOUBLE_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "a", DOUBLE_TO_JSVAL(p.b), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;

	return OBJECT_TO_JSVAL(object);
}

JSBool JSB_jsval_to_array_of_CGPoint( JSContext *cx, jsval vp, CGPoint**points, int *numPoints)
{
	// Parsing sequence
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION2( jsobj && JS_IsArrayObject( cx, jsobj), cx, JS_FALSE, "Object must be an array");
	
	uint32_t len;
	JS_GetArrayLength(cx, jsobj, &len);

	CGPoint *array = (CGPoint*)malloc( sizeof(CGPoint) * len);

	for( uint32_t i=0; i< len;i++ ) {
		jsval valarg;
		JS_GetElement(cx, jsobj, i, &valarg);

		ok = JSB_jsval_to_CGPoint(cx, valarg, &array[i]);
		JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to CGPoint");
	}

	*numPoints = len;
	*points = array;

	return JS_TRUE;
}

ccColor3B getColorFromJSObject(JSContext *cx, JSObject *colorObject)
{
    jsval jsr;
    ccColor3B out;
    JS_GetProperty(cx, colorObject, "r", &jsr);
    double fontR = 0.0;
    JS_ValueToNumber(cx, jsr, &fontR);
    
    JS_GetProperty(cx, colorObject, "g", &jsr);
    double fontG = 0.0;
    JS_ValueToNumber(cx, jsr, &fontG);
    
    JS_GetProperty(cx, colorObject, "b", &jsr);
    double fontB = 0.0;
    JS_ValueToNumber(cx, jsr, &fontB);
    
    // the out
    out.r = (unsigned char)fontR;
    out.g = (unsigned char)fontG;
    out.b = (unsigned char)fontB;
    
    return out;
}

CGSize getSizeFromJSObject(JSContext *cx, JSObject *sizeObject)
{
    jsval jsr;
    CGSize out;
    JS_GetProperty(cx, sizeObject, "width", &jsr);
    double width = 0.0;
    JS_ValueToNumber(cx, jsr, &width);
    
    JS_GetProperty(cx, sizeObject, "height", &jsr);
    double height = 0.0;
    JS_ValueToNumber(cx, jsr, &height);
    
    
    // the out
    out.width  = width;
    out.height = height;
    
    return out;
}

JSBool JSB_jsval_to_CCFontDefinition( JSContext *cx, jsval vp, CCFontDefinition **out )
{
    JSObject *jsobj;
    
	if( ! JS_ValueToObject( cx, vp, &jsobj ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( jsobj, "Not a valid JS object");
    
    // defaul values
    const char *            defautlFontName         = "Arial";
    const int               defaultFontSize         = 32;
    CCTextAlignment         defaultTextAlignment    = kCCTextAlignmentLeft;
    CCVerticalTextAlignment defaultTextVAlignment   = kCCVerticalTextAlignmentTop;
    
    CCFontDefinition *ret = [[[CCFontDefinition alloc] init] autorelease];
    // by default shadow and stroke are off
    [ret enableShadow: false];
    [ret enableStroke: false];
    
    
    // white text by default
    ret.fontFillColor = ccWHITE;
    
    // font name
    jsval jsr;
    const jschar *chars = 0;
    size_t l            = 0;
    
    JS_GetProperty(cx, jsobj, "fontName", &jsr);
    JSString *jsstr = JS_ValueToString( cx, jsr );
	
    if( jsstr )
    {
        chars   = JS_GetStringCharsZ(cx, jsstr);
        l       = JS_GetStringLength(jsstr);
    }
	
    if ( (!chars) || (l<=0))
    {
        ret.fontName = [NSString stringWithUTF8String:defautlFontName];
    }
    else
    {
        ret.fontName = [NSString stringWithCharacters:chars length:l];
    }
    
    // font size
    JSBool hasProperty;
    JS_HasProperty(cx, jsobj, "fontSize", &hasProperty);
    if ( hasProperty )
    {
        JS_GetProperty(cx, jsobj, "fontSize", &jsr);
        double fontSize = 0.0;
        JS_ValueToNumber(cx, jsr, &fontSize);
        ret.fontSize  = fontSize;
    }
    else
    {
        ret.fontSize = defaultFontSize;
    }
    
    // font alignment horizontal
    JS_HasProperty(cx, jsobj, "fontAlignmentH", &hasProperty);
    if ( hasProperty )
    {
        JS_GetProperty(cx, jsobj, "fontAlignmentH", &jsr);
        double fontAlign = 0.0;
        JS_ValueToNumber(cx, jsr, &fontAlign);
        ret.alignment  = (CCTextAlignment)fontAlign;
    }
    else
    {
        ret.alignment  = defaultTextAlignment;
    }
    
    // font alignment vertical
    JS_HasProperty(cx, jsobj, "fontAlignmentV", &hasProperty);
    if ( hasProperty )
    {
        JS_GetProperty(cx, jsobj, "fontAlignmentV", &jsr);
        double fontAlign = 0.0;
        JS_ValueToNumber(cx, jsr, &fontAlign);
        ret.vertAlignment = (CCVerticalTextAlignment)fontAlign;
    }
    else
    {
        ret.vertAlignment  = defaultTextVAlignment;
    }
    
    // font fill color
    JS_HasProperty(cx, jsobj, "fontFillColor", &hasProperty);
    if ( hasProperty )
    {
        JS_GetProperty(cx, jsobj, "fontFillColor", &jsr);
        
        JSObject *jsobjColor;
        if( ! JS_ValueToObject( cx, jsr, &jsobjColor ) )
            return JS_FALSE;
        
        ret.fontFillColor = getColorFromJSObject(cx, jsobjColor);
    }
    
    // font rendering box dimensions
    JS_HasProperty(cx, jsobj, "fontDimensions", &hasProperty);
    if ( hasProperty )
    {
        JS_GetProperty(cx, jsobj, "fontDimensions", &jsr);
        
        JSObject *jsobjSize;
        if( ! JS_ValueToObject( cx, jsr, &jsobjSize ) )
            return JS_FALSE;
        
        ret.dimensions = getSizeFromJSObject(cx, jsobjSize);
    }
    
    // shadow
    JS_HasProperty(cx, jsobj, "shadowEnabled", &hasProperty);
    if ( hasProperty )
    {
        JS_GetProperty(cx, jsobj, "shadowEnabled", &jsr);
        [ret enableShadow: ToBoolean(jsr)];
        
        if( [ret shadowEnabled] )
        {
            // default shadow values
            CGSize shadowOffet;
            shadowOffet.width  = 5;
            shadowOffet.height = 5;
            
            [ret setShadowOffset:shadowOffet];
            [ret setShadowBlur:1.0f];
            
            
            // shado offset
            JS_HasProperty(cx, jsobj, "shadowOffset", &hasProperty);
            if ( hasProperty )
            {
                JS_GetProperty(cx, jsobj, "shadowOffset", &jsr);
                
                JSObject *jsobjShadowOffset;
                if( ! JS_ValueToObject( cx, jsr, &jsobjShadowOffset ) )
                    return JS_FALSE;
                
                [ret setShadowOffset: getSizeFromJSObject(cx, jsobjShadowOffset)];
            }
            
            // shadow blur
            JS_HasProperty(cx, jsobj, "shadowBlur", &hasProperty);
            if ( hasProperty )
            {
                JS_GetProperty(cx, jsobj, "shadowBlur", &jsr);
                double shadowBlur = 0.0;
                JS_ValueToNumber(cx, jsr, &shadowBlur);
                [ret setShadowBlur: shadowBlur];
            }
            
            // shadow intensity
            /* not supported yet
            JS_HasProperty(cx, jsobj, "shadowOpacity", &hasProperty);
            if ( hasProperty )
            {
                JS_GetProperty(cx, jsobj, "shadowOpacity", &jsr);
                double shadowOpacity = 0.0;
                JS_ValueToNumber(cx, jsr, &shadowOpacity);
            }
            */
        }
    }
    
    // stroke
    JS_HasProperty(cx, jsobj, "strokeEnabled", &hasProperty);
    if ( hasProperty )
    {
        JS_GetProperty(cx, jsobj, "strokeEnabled", &jsr);
        [ret enableStroke:ToBoolean(jsr)];
        
        if( [ret strokeEnabled] )
        {
            // default stroke values
            [ret setStrokeSize: 1];
            [ret setStrokeColor: ccBLUE];
            
            // stroke color
            JS_HasProperty(cx, jsobj, "strokeColor", &hasProperty);
            if ( hasProperty )
            {
                JS_GetProperty(cx, jsobj, "strokeColor", &jsr);
                
                JSObject *jsobjStrokeColor;
                if( ! JS_ValueToObject( cx, jsr, &jsobjStrokeColor ) )
                    return JS_FALSE;
                [ret setStrokeColor:getColorFromJSObject(cx, jsobjStrokeColor)];
            }
            
            // stroke size
            JS_HasProperty(cx, jsobj, "strokeSize", &hasProperty);
            if ( hasProperty )
            {
                JS_GetProperty(cx, jsobj, "strokeSize", &jsr);
                double strokeSize = 0.0;
                JS_ValueToNumber(cx, jsr, &strokeSize);
                [ret setStrokeSize: strokeSize];
            }
        }
    }
    
    *out = ret;
    // we are done here
	return JS_TRUE;
}

#pragma mark - Layer

@implementation JSB_CCLayer (Manual)

#if __CC_PLATFORM_MAC

-(BOOL) ccFlagsChanged:(NSEvent*)event
{
	BOOL ret;
	if (_jsObj) {
		JSContext* cx = [[JSBCore sharedInstance] globalContext];
		JSBool found;
		JS_HasProperty(cx, _jsObj, "onKeyFlagsChanged", &found);
		if (found == JS_TRUE) {
			jsval rval, fval;
			jsval argv;
			NSUInteger flags = [event modifierFlags];
			argv = UINT_TO_JSVAL((uint32_t)flags);

			JS_GetProperty(cx, _jsObj, "onKeyFlagsChanged", &fval);
			JS_CallFunctionValue(cx, _jsObj, fval, 1, &argv, &rval);
			JSBool jsbool; JS_ValueToBoolean(cx, rval, &jsbool);
			ret = jsbool;
		}
	}
	return ret;
}

-(BOOL) ccKeyUp:(NSEvent*)event
{
	BOOL ret;
	if (_jsObj) {
		JSContext* cx = [[JSBCore sharedInstance] globalContext];
		JSBool found;
		JS_HasProperty(cx, _jsObj, "onKeyUp", &found);
		if (found == JS_TRUE) {
			jsval rval, fval;
			jsval argv;
			unichar uchar = [[event characters] characterAtIndex:0];
			argv = UINT_TO_JSVAL(uchar);

			JS_GetProperty(cx, _jsObj, "onKeyUp", &fval);
			JS_CallFunctionValue(cx, _jsObj, fval, 1, &argv, &rval);
			JSBool jsbool; JS_ValueToBoolean(cx, rval, &jsbool);
			ret = jsbool;
		}
	}
	return ret;
}

-(BOOL) ccKeyDown:(NSEvent*)event
{
	BOOL ret;
	if (_jsObj) {
		JSContext* cx = [[JSBCore sharedInstance] globalContext];
		JSBool found;
		JS_HasProperty(cx, _jsObj, "onKeyDown", &found);
		if (found == JS_TRUE) {
			jsval rval, fval;
			jsval argv;
			unichar uchar = [[event characters] characterAtIndex:0];
			argv = UINT_TO_JSVAL(uchar);

			JS_GetProperty(cx, _jsObj, "onKeyDown", &fval);
			JS_CallFunctionValue(cx, _jsObj, fval, 1, &argv, &rval);
			JSBool jsbool; JS_ValueToBoolean(cx, rval, &jsbool);
			ret = jsbool;
		}
	}
	return ret;
}

#elif __CC_PLATFORM_IOS

-(void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	if (_jsObj) {
		JSContext* cx = [[JSBCore sharedInstance] globalContext];
		JSBool found;
		JSB_ENSURE_AUTOCOMPARTMENT(cx, _jsObj);
		JS_HasProperty(cx, _jsObj, "onAccelerometer", &found);
		if (found == JS_TRUE) {
			jsval rval, fval;

			NSTimeInterval time = acceleration.timestamp;
			UIAccelerationValue x = acceleration.x;
			UIAccelerationValue y = acceleration.y;
			UIAccelerationValue z = acceleration.z;

			// Create an JS object with x,y,z,timestamp as properties
			JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
			if( !object)
				return;

			if (!JS_DefineProperty(cx, object, "x", DOUBLE_TO_JSVAL(x), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
				!JS_DefineProperty(cx, object, "y", DOUBLE_TO_JSVAL(y), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
				!JS_DefineProperty(cx, object, "z", DOUBLE_TO_JSVAL(z), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
				!JS_DefineProperty(cx, object, "timestamp", DOUBLE_TO_JSVAL(time), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
				return;

			jsval argv = OBJECT_TO_JSVAL(object);

			JS_GetProperty(cx, _jsObj, "onAccelerometer", &fval);
			JS_CallFunctionValue(cx, _jsObj, fval, 1, &argv, &rval);
		}
	}
}
#endif // __CC_PLATFORM_IOS

@end

#pragma mark - MenuItem

// "setCallback" in JS
// item.setCallback( callback_fn, [this]);
JSBool JSB_CCMenuItem_setBlock_( JSContext *cx, uint32_t argc, jsval *vp ) {

	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsthis);

	JSB_PRECONDITION( proxy && [proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc==1 || argc==2, "Invalid number of arguments. Expecting 1 or 2 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	js_block js_func;
	// default value for js_this. Can't use NULL.
	JSObject *js_this = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSBool ok = JS_TRUE;

	if(argc==2) {
		ok &= JS_ValueToObject(cx, argvp[1], &js_this);
		ok &= JSB_set_reserved_slot(jsthis, 1, argvp[1] );
	}

	ok &= JSB_jsval_to_block_1( cx, argvp[0], js_this, &js_func );
	ok &= JSB_set_reserved_slot(jsthis, 0, argvp[0] );

	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error parsing arguments");
	
	CCMenuItem *real = (CCMenuItem*) [proxy realObj];

	[real setBlock:(void(^)(id sender))js_func];

	JS_SET_RVAL(cx, vp, JSVAL_VOID);

	return JS_TRUE;
}

#pragma mark - MenuItemFont

// "create" in JS
// cc.MenuItemFont.create( string, callback_fn, [this] );
JSBool JSB_CCMenuItemFont_itemWithString_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc >=1 && argc <= 3, "Invalid number of arguments. Expecting 1, 2 or 3 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString *normal;
	js_block js_func;
	// default value for js_this. Can't use NULL.
	JSObject *js_this = (JSObject *)JS_THIS_OBJECT(cx, vp);

	ok &= JSB_jsval_to_NSString( cx, argvp[0], &normal );
		
	if( argc >= 2 ) {
		
		if( argc == 3)
			ok &= JS_ValueToObject(cx, argvp[2], &js_this);

		// function
		ok &= JSB_jsval_to_block_1( cx, argvp[1], js_this, &js_func );
	}
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error parsing arguments");
	
	CCMenuItemFont *ret_val;

	if( argc == 1 )
		ret_val = [CCMenuItemFont itemWithString:normal];
	else
		ret_val = [CCMenuItemFont itemWithString:normal block:(void(^)(id sender))js_func];

	// XXX: This will be the default behavior on v2.2
	[ret_val setReleaseBlockAtCleanup:NO];

	JSObject *jsobj = JSB_get_or_create_jsobject_from_realobj( cx, ret_val );
	
	// "root" callback function
	if( argc >= 2 )
		JSB_set_reserved_slot(jsobj, 0, argvp[1] );
	
	// and also root 'jsthis'
	if( argc == 3)
		JSB_set_reserved_slot(jsobj, 1, argvp[2] );


	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));

	return JS_TRUE;
}

// "init" in JS
// item.init( string, callback_fn, [this] );
JSBool JSB_CCMenuItemFont_initWithString_block_(JSContext *cx, uint32_t argc, jsval *vp) {
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsthis);

	JSB_PRECONDITION( proxy && ![proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc >= 1 && argc <= 3, "Invalid number of arguments. Expecting 1, 2 or 3 args" );
	
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString *normal;
	js_block js_func;
	// default value for js_this. Can't use NULL.
	JSObject *js_this = (JSObject *)JS_THIS_OBJECT(cx, vp);

	ok &= JSB_jsval_to_NSString( cx, argvp[0], &normal );
	
	if( argc >= 2 ) {
		if( argc == 3) {
			// this
			ok &= JS_ValueToObject(cx, argvp[2], &js_this);
			JSB_set_reserved_slot(jsthis, 1, argvp[2] );
		}
		
		// function
		ok &= JSB_jsval_to_block_1( cx, argvp[1], js_this, &js_func );
		JSB_set_reserved_slot(jsthis, 0, argvp[1] );
	}
	
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error parsing arguments");
	
	CCMenuItemFont *real = nil;
	
	if( argc == 1 )
		real = [(CCMenuItemFont*)[proxy.klass alloc] initWithString:normal target:nil selector:nil];
	else if (argc >= 2 )
		real = [(CCMenuItemFont*)[proxy.klass alloc] initWithString:normal block:(void(^)(id sender))js_func];

	[proxy setRealObj: real];

	JS_SET_RVAL(cx, vp, JSVAL_VOID);
			
	return JS_TRUE;
}


#pragma mark - MenuItemLabel

// "create" in JS:
// cc.MenuItemLabel.create( label, callback_fn, [this] );
JSBool JSB_CCMenuItemLabel_itemWithLabel_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc >=1 && argc <= 3, "Invalid number of arguments. Expecting 1, 2 or 3 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CCNode<CCLabelProtocol, CCRGBAProtocol> *label;
	js_block js_func;
	// default value for js_this. Can't use NULL.
	JSObject *js_this = (JSObject *)JS_THIS_OBJECT(cx, vp);

	ok &= JSB_jsval_to_NSObject( cx, argvp[0], &label );
	
	if( argc >= 2 ) {
		if( argc==3)
			ok &= JS_ValueToObject(cx, argvp[2], &js_this);
		
		// function
		ok &= JSB_jsval_to_block_1( cx, argvp[1], js_this, &js_func );
	}
	
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error parsing arguments");

	CCMenuItemLabel *ret_val = nil;
	
	if( argc == 1 )
		ret_val = [CCMenuItemLabel itemWithLabel:label];
	else if (argc >= 2 )
		ret_val = [CCMenuItemLabel itemWithLabel:label block:(void(^)(id sender))js_func];

	// XXX: This will be the default behavior on v2.2
	[ret_val setReleaseBlockAtCleanup:NO];

	JSObject *jsobj = JSB_get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));

	// "root" object and function
	if( argc >=2  )
		JSB_set_reserved_slot(jsobj, 0, argvp[1] );
	
	if( argc == 3)
		JSB_set_reserved_slot(jsobj, 1, argvp[2] );
	
	return JS_TRUE;
}

// "init" in JS
// item.init( label, callback_fn, [this] );
JSBool JSB_CCMenuItemLabel_initWithLabel_block_(JSContext *cx, uint32_t argc, jsval *vp) {
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsthis);

	JSB_PRECONDITION( proxy && [proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc >=1 && argc <= 3, "Invalid number of arguments. Expecting 1, 2 or 3 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CCNode<CCLabelProtocol, CCRGBAProtocol> *label;
	js_block js_func;
	// default value for js_this. Can't use NULL.
	JSObject *js_this = (JSObject *)JS_THIS_OBJECT(cx, vp);

	ok &= JSB_jsval_to_NSObject( cx, argvp[0], &label );
	
	if( argc >= 2 ) {
		if( argc == 3) {
			ok &= JS_ValueToObject(cx, argvp[2], &js_this);
			JSB_set_reserved_slot(jsthis, 1, argvp[2] );
		}
		
		// function
		ok &= JSB_jsval_to_block_1( cx, argvp[1], js_this, &js_func );
		JSB_set_reserved_slot(jsthis, 0, argvp[1] );
	}
	
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error parsing arguments");
	
	CCMenuItemLabel *real = nil;
	if( argc == 1 )
		real = [(CCMenuItemLabel*)[proxy.klass alloc] initWithLabel:label target:nil selector:NULL];
	else if (argc >= 2 )
		real = [(CCMenuItemLabel*)[proxy.klass alloc] initWithLabel:label block:(void(^)(id sender))js_func];

	[proxy setRealObj:real];

	JS_SET_RVAL(cx, vp, JSVAL_VOID);
		
	return JS_TRUE;
}

#pragma mark - MenuItemImage

// "create" in JS
// cc.MenuItemImage.create( normalImage, selectedImage, [disabledImage], callback_fn, [this] 
JSBool JSB_CCMenuItemImage_itemWithNormalImage_selectedImage_disabledImage_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc >=2 && argc <= 5, "Invalid number of arguments. Expecting: 2 <= args <= 5" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString *normal, *selected, *disabled;
	js_block js_func;
	jsval valthis, valfn;
	// default value for js_this. Can't use NULL.
	JSObject *js_this = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSBool lastArgIsCallback = JS_FALSE;
	
	// 1st: Check if "this" is present
	JSObject *tmpobj;
	ok &= JS_ValueToObject(cx, argvp[argc-1], &tmpobj);
	if( JS_ObjectIsFunction(cx, tmpobj))
		lastArgIsCallback = JS_TRUE;
	else {
		js_this = tmpobj;
		valthis = argvp[argc-1];
	}
	
	
	// 1st and 2nd arguments must be a strings
	ok &= JSB_jsval_to_NSString( cx, *argvp++, &normal );
	ok &= JSB_jsval_to_NSString( cx, *argvp++, &selected );

	if( (argc==3 && !lastArgIsCallback) || argc == 5 || (argc==4 && lastArgIsCallback))
		ok &= JSB_jsval_to_NSString( cx, *argvp++, &disabled );

	// cannot merge with previous if() since argvp needs to be incremented
	if( argc >=4 || (argc==3 && lastArgIsCallback)  ) {
		
		// function
		valfn = *argvp;
		ok &= JSB_jsval_to_block_1( cx, *argvp++, js_this, &js_func );
	}

	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error parsing arguments");

	CCMenuItemImage *ret_val=nil;
		
	if( argc == 2 )
		ret_val = [CCMenuItemImage itemWithNormalImage:normal selectedImage:selected];
	else if (argc ==3 && !lastArgIsCallback)
		ret_val = [CCMenuItemImage itemWithNormalImage:normal selectedImage:selected disabledImage:disabled];
	else if (argc == 4 || (argc==3 && lastArgIsCallback))
		ret_val = [CCMenuItemImage itemWithNormalImage:normal selectedImage:selected block:(void(^)(id sender))js_func];
	else if (argc == 5 )
		ret_val = [CCMenuItemImage itemWithNormalImage:normal selectedImage:selected disabledImage:disabled block:(void(^)(id sender))js_func];

	// XXX: This will be the default behavior on v2.2
	[ret_val setReleaseBlockAtCleanup:NO];

	JSObject *jsobj = JSB_get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));

	// "root" object and function
	if( argc >= 4 || (argc >=3 && lastArgIsCallback) ) {
		JSB_set_reserved_slot(jsobj, 0, valfn );
		
		if( !lastArgIsCallback )
			JSB_set_reserved_slot(jsobj, 1, valthis );
	}

	return JS_TRUE;
}

// "init" in JS
// item.init( normalImage, selectedImage, [disabledImage], callback_fn, [this] 
JSBool JSB_CCMenuItemImage_initWithNormalImage_selectedImage_disabledImage_block_(JSContext *cx, uint32_t argc, jsval *vp) {
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsthis);

	JSB_PRECONDITION( proxy && [proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc >=2 && argc <= 5, "Invalid number of arguments. Expecting: 2 <= args <= 5" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString *normal, *selected, *disabled;
	jsval valthis, valfn;
	js_block js_func;
	// default value for js_this. Can't use NULL.
	JSObject *js_this = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSBool lastArgIsCallback = JS_FALSE;

	
	// 1st: Check if "this" is present
	JSObject *tmpobj;
	ok &= JS_ValueToObject(cx, argvp[argc-1], &tmpobj);
	if( JS_ObjectIsFunction(cx, tmpobj))
		lastArgIsCallback = JS_TRUE;
	else {
		js_this = tmpobj;
		valthis = argvp[argc-1];
	}
		
	// 1st and 2nd arguments must be a strings
	ok &= JSB_jsval_to_NSString( cx, *argvp++, &normal );
	ok &= JSB_jsval_to_NSString( cx, *argvp++, &selected );

	
	if( (argc==3 && !lastArgIsCallback) || argc == 5 || (argc==4 && lastArgIsCallback))
		ok &= JSB_jsval_to_NSString( cx, *argvp++, &disabled );
	
	// cannot merge with previous if() since argvp needs to be incremented
	if( argc >=4 || (argc==3 && lastArgIsCallback)  ) {
		
		// function
		valfn = *argvp;
		ok &= JSB_jsval_to_block_1( cx, *argvp++, js_this, &js_func );

		// root-them
		JSB_set_reserved_slot(jsthis, 0, valfn );
		if( ! lastArgIsCallback )
			JSB_set_reserved_slot(jsthis, 1, valthis );
	}
	
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error parsing arguments");
	
	CCMenuItemImage *real = nil;

	if( argc == 2 )
		real = [(CCMenuItemImage*)[proxy.klass alloc] initWithNormalImage:normal selectedImage:selected disabledImage:nil target:nil selector:NULL];
	else if (argc ==3 && !lastArgIsCallback )
		real = [(CCMenuItemImage*)[proxy.klass alloc] initWithNormalImage:normal selectedImage:selected disabledImage:disabled target:nil selector:NULL];
		else if (argc == 4 || (argc==3 && lastArgIsCallback))
		real = [(CCMenuItemImage*)[proxy.klass alloc] initWithNormalImage:normal selectedImage:selected disabledImage:nil block:(void(^)(id sender))js_func];
	else if (argc == 5 )
		real = [(CCMenuItemImage*)[proxy.klass alloc] initWithNormalImage:normal selectedImage:selected disabledImage:disabled block:(void(^)(id sender))js_func];

	[proxy setRealObj:real];

	JS_SET_RVAL(cx, vp, JSVAL_VOID);
		
	return JS_TRUE;
}


#pragma mark - MenuItemSprite

// "create" in JS
// cc.MenuItemSprite.create( normalSprite, selectedSprite, [disabledSprite], [callback_fn], [this]
JSBool JSB_CCMenuItemSprite_itemWithNormalSprite_selectedSprite_disabledSprite_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	
	
	JSB_PRECONDITION( argc >=2 && argc <= 5, "Invalid number of arguments. Expecting: 2 <= args <= 5" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CCSprite *normal, *selected, *disabled;
	js_block js_func;
	jsval valthis, valfn;
	// default value for js_this. Can't use NULL.
	JSObject *js_this = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSBool lastArgIsCallback = JS_FALSE;
	
	// 1st: Check if "this" is present
	if( argc >= 3) {
		JSObject *tmpobj;
		ok &= JS_ValueToObject(cx, argvp[argc-1], &tmpobj);
		if( JS_ObjectIsFunction(cx, tmpobj))
			lastArgIsCallback = JS_TRUE;
		else {
			js_this = tmpobj;
			valthis = argvp[argc-1];
		}
	}
	
	
	// 1st and 2nd to arguments must be sprites
	ok &= JSB_jsval_to_NSObject( cx, *argvp++, &normal );
	ok &= JSB_jsval_to_NSObject( cx, *argvp++, &selected );
	
	if( argc == 5 || (argc==4 && lastArgIsCallback))
		ok &= JSB_jsval_to_NSObject( cx, *argvp++, &disabled );
	
	// cannot merge with previous if() since argvp needs to be incremented
	if( argc >=3 ) {
		// function
		valfn = *argvp;
		ok &= JSB_jsval_to_block_1( cx, *argvp++, js_this, &js_func );
	}
	
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error parsing arguments");

	CCMenuItemSprite *ret_val=nil;

	if( argc == 2 )
		ret_val = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:selected];
	else if ( (argc == 4 && !lastArgIsCallback) || (argc==3 && lastArgIsCallback))
		ret_val = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:selected block:(void(^)(id sender))js_func];
	else if (argc == 5 || (argc==4 && lastArgIsCallback) )
		ret_val = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:selected disabledSprite:disabled block:(void(^)(id sender))js_func];

	// XXX: This will be the default behavior on v2.2
	[ret_val setReleaseBlockAtCleanup:NO];

	JSObject *jsobj = JSB_get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));

	// "root" object and function
	if( argc >= 3 ) {
		JSB_set_reserved_slot(jsobj, 0, valfn );

		if( !lastArgIsCallback )
			JSB_set_reserved_slot(jsobj, 1, valthis );
	}

	return JS_TRUE;
}

// "init" in JS
JSBool JSB_CCMenuItemSprite_initWithNormalSprite_selectedSprite_disabledSprite_block_(JSContext *cx, uint32_t argc, jsval *vp) {
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsthis);

	JSB_PRECONDITION( proxy && [proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc >=2 && argc <= 5, "Invalid number of arguments. 2 <= args <= 5" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CCSprite *normal, *selected, *disabled;
	js_block js_func;
	jsval valthis, valfn;
	// default value for js_this. Can't use NULL.
	JSObject *js_this = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSBool lastArgIsCallback = JS_FALSE;
	
	// 1st: Check if "this" is present
	if( argc >= 3) {
		JSObject *tmpobj;
		ok &= JS_ValueToObject(cx, argvp[argc-1], &tmpobj);
		if( JS_ObjectIsFunction(cx, tmpobj))
			lastArgIsCallback = JS_TRUE;
		else {
			js_this = tmpobj;
			valthis = argvp[argc-1];
		}
	}
	
	ok &= JSB_jsval_to_NSObject( cx, *argvp++, &normal );
	ok &= JSB_jsval_to_NSObject( cx, *argvp++, &selected );
	
	if( argc == 5 || (argc==4 && lastArgIsCallback))
		ok &= JSB_jsval_to_NSObject( cx, *argvp++, &disabled );


	// cannot merge with previous if() since argvp needs to be incremented
	if( argc >=3 ) {
		// function
		valfn = *argvp;
		ok &= JSB_jsval_to_block_1( cx, *argvp++, js_this, &js_func );
		
		// "root" object and function
		JSB_set_reserved_slot(jsthis, 0, valfn );
		if( !lastArgIsCallback )
			JSB_set_reserved_slot(jsthis, 1, valthis );
	}
	
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error parsing arguments");

	CCMenuItemSprite *real = nil;

	if( argc == 2 )
		real = [(CCMenuItemSprite*)[proxy.klass alloc] initWithNormalSprite:normal selectedSprite:selected disabledSprite:nil target:nil selector:NULL];
	else if ( (argc == 4 && !lastArgIsCallback) || (argc==3 && lastArgIsCallback))
		real = [(CCMenuItemSprite*)[proxy.klass alloc] initWithNormalSprite:normal selectedSprite:selected disabledSprite:nil block:(void(^)(id sender))js_func];
	else if (argc == 5 || (argc==4 && lastArgIsCallback) )
		real = [(CCMenuItemSprite*)[proxy.klass alloc] initWithNormalSprite:normal selectedSprite:selected disabledSprite:disabled block:(void(^)(id sender))js_func];

	[proxy setRealObj:real];

	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	
	return JS_TRUE;
}

#pragma mark - CallFunc

// cc.CallFunc.create( func, this, [data])
// cc.CallFunc.create( func )
JSBool JSB_CCCallBlockN_actionWithBlock__static(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION( argc >= 1 || argc <= 3,  "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	js_block js_func;
	// default value for js_this. Can't use NULL.
	JSObject *js_this = (JSObject *)JS_THIS_OBJECT(cx, vp);
	jsval valthis, valfn;
	
	NSObject *ret_val;

	// get callback fn
	valfn = argvp[0];

	// get "this"
	if( argc >= 2) {
		valthis = argvp[1];
		ok &= JS_ValueToObject(cx, valthis, &js_this);
	}
		
	if( argc == 1 || argc==2 ) {
		ok &= JSB_jsval_to_block_1( cx, valfn, js_this, &js_func );
		ret_val = [CCCallBlockN actionWithBlock:js_func];
		
	} else if( argc == 3 ) {
		jsval arg =  argvp[2];
		ok &= JSB_jsval_to_block_2( cx, valfn, js_this, arg, &js_func );
		ret_val = [CCCallBlockN actionWithBlock:js_func];
	}

	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error parsing arguments");

	JSObject *jsobj = JSB_get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));

	// "root" object and function
	JSB_set_reserved_slot(jsobj, 0, valfn );
	if( argc >= 2)
		JSB_set_reserved_slot(jsobj, 1, valthis );

	return JS_TRUE;
}

#pragma mark - Texture2D

JSBool JSB_CCTexture2D_setTexParameters_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(obj);

	JSB_PRECONDITION( proxy && [proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc == 4, "Invalid number of arguments. Expecting 4 args" );

	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;

	GLint arg0, arg1, arg2, arg3;

	ok &= JS_ValueToInt32(cx, *argvp++, &arg0);
	ok &= JS_ValueToInt32(cx, *argvp++, &arg1);
	ok &= JS_ValueToInt32(cx, *argvp++, &arg2);
	ok &= JS_ValueToInt32(cx, *argvp++, &arg3);

	if( ! ok )
		return JS_FALSE;

	ccTexParams param = { (GLuint)arg0, (GLuint)arg1, (GLuint)arg2, (GLuint)arg3 };

	CCTexture2D *real = (CCTexture2D*) [proxy realObj];
	[real setTexParameters:&param];


	JS_SET_RVAL(cx, vp, JSVAL_VOID);

	return JS_TRUE;
}

#pragma mark - CCDrawNode

// Arguments: Array of points, fill color (ccc4f), width(float), border color (ccc4f)
// Ret value: void
JSBool JSB_CCDrawNode_drawPolyWithVerts_count_fillColor_borderWidth_borderColor_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(obj);
	
	JSB_PRECONDITION2( proxy && [proxy realObj], cx, JS_FALSE, "Invalid Proxy object");
	JSB_PRECONDITION2( argc == 4, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	JSObject *argArray; ccColor4F argFillColor; double argWidth; ccColor4F argBorderColor; 
	
	// Points
	ok &= JS_ValueToObject(cx, *argvp++, &argArray);
	JSB_PRECONDITION2( (argArray && JS_IsArrayObject(cx, argArray)) , cx, JS_FALSE, "Vertex should be anArray object");
	
	// Color 4F
	ok &= JSB_jsval_to_ccColor4F(cx, *argvp++, &argFillColor);

	// Width
	ok &= JS_ValueToNumber( cx, *argvp++, &argWidth );
	
	// Color Border (4F)
	ok &= JSB_jsval_to_ccColor4F(cx, *argvp++, &argBorderColor);

	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error parsing arguments");
	
	{
		uint32_t l;
		if( ! JS_GetArrayLength(cx, argArray, &l) )
			return JS_FALSE;

		CGPoint verts[ l ];
		CGPoint p;

		for( int i=0; i<l; i++ ) {
			jsval pointvp;
			if( ! JS_GetElement(cx, argArray, i, &pointvp) )
				return JS_FALSE;
			if( ! JSB_jsval_to_CGPoint(cx, pointvp, &p) )
				continue;

			verts[i] = p;
		}

		CCDrawNode *real = (CCDrawNode*) [proxy realObj];
		[real drawPolyWithVerts:verts count:l fillColor:argFillColor borderWidth:argWidth borderColor:argBorderColor];
	}
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

#pragma mark - CCNode

// func, delay
JSBool JSB_CCNode_scheduleOnce_delay_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsthis);

	JSB_PRECONDITION2( proxy && [proxy realObj], cx, JS_FALSE, "Invalid Proxy object");
	JSB_PRECONDITION2( argc == 2, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);

	CCNode *real = (CCNode*) [proxy realObj];
	CCScheduler *scheduler = [real scheduler];

	//
	// "function"
	//
	jsval funcval = *argvp++;
	JSFunction *func = JS_ValueToFunction(cx, funcval);
	JSB_PRECONDITION2( func, cx, JS_FALSE, "Cannot convert Value to Function");

	NSString *key = nil;
	JSString *funcname = JS_GetFunctionId(func);

	// named function
	if( funcname ) {
		char *key_c = JS_EncodeString(cx, funcname);
		key = [NSString stringWithUTF8String:key_c];
	} else {
		// anonymous function
		key = [NSString stringWithFormat:@"anonfunc at %p", func];
	}

	void (^block)(ccTime dt) = ^(ccTime dt) {

		jsval rval;
		jsval jsdt = DOUBLE_TO_JSVAL(dt);

		JSB_ENSURE_AUTOCOMPARTMENT(cx, jsthis);
		JSBool ok = JS_CallFunctionValue(cx, jsthis, funcval, 1, &jsdt, &rval);
		JSB_PRECONDITION2(ok, cx, ,"Error calling collision callback: schedule_interval_repeat_delay");
	};

	//
	// delay
	//
	double delay;
	JSBool ok = JS_ValueToNumber(cx, *argvp++, &delay );
	JSB_PRECONDITION2(ok, cx, JS_FALSE,"Error converting jsval to number");


	[scheduler scheduleBlockForKey:key target:real interval:0 repeat:0 delay:delay paused:![real isRunning] block:block];


	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

// func, [interval], [repeat], [delay]
JSBool JSB_CCNode_schedule_interval_repeat_delay_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION2( proxy && [proxy realObj], cx, JS_FALSE, "Invalid Proxy object");
	JSB_PRECONDITION2( argc >=1 && argc <=4, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);

	CCNode *real = (CCNode*) [proxy realObj];
	CCScheduler *scheduler = [real scheduler];

	//
	// "function"
	//
	jsval funcval = *argvp++;
	JSFunction *func = JS_ValueToFunction(cx, funcval);
	JSB_PRECONDITION2( func, cx, JS_FALSE, "Cannot convert Value to Function");

	NSString *key = nil;
	JSString *funcname = JS_GetFunctionId(func);

	// named function
	if( funcname ) {
		char *key_c = JS_EncodeString(cx, funcname);
		key = [NSString stringWithUTF8String:key_c];
	} else {
		// anonymous function
		key = [NSString stringWithFormat:@"anonfunc at %p", func];
	}

	void (^block)(ccTime dt) = ^(ccTime dt) {

		jsval rval;
		jsval jsdt = DOUBLE_TO_JSVAL(dt);

		JSB_ENSURE_AUTOCOMPARTMENT(cx, jsthis);
		JSBool ok = JS_CallFunctionValue(cx, jsthis, funcval, 1, &jsdt, &rval);
		JSB_PRECONDITION2(ok, cx, ,"Error calling collision callback: schedule_interval_repeat_delay");
	};

	JSBool ok = JS_TRUE;

	//
	// Interval
	//
	double interval;
	if( argc >= 2 )
		ok &= JS_ValueToNumber(cx, *argvp++, &interval );

	//
	// repeat
	//
	double repeat;
	if( argc >= 3 )
		ok &= JS_ValueToNumber(cx, *argvp++, &repeat );


	//
	// delay
	//
	double delay;
	if( argc >= 4 )
		ok &= JS_ValueToNumber(cx, *argvp++, &delay );
		
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error converting jsval to native");


	if( argc==1)
		[scheduler scheduleBlockForKey:key target:real interval:0 repeat:kCCRepeatForever delay:0 paused:![real isRunning] block:block];

	else if (argc == 2 )
		[scheduler scheduleBlockForKey:key target:real interval:interval repeat:kCCRepeatForever delay:0 paused:![real isRunning] block:block];

	else if (argc == 3 )
		[scheduler scheduleBlockForKey:key target:real interval:interval repeat:repeat delay:0 paused:![real isRunning] block:block];

	else if( argc == 4 )
		[scheduler scheduleBlockForKey:key target:real interval:interval repeat:repeat delay:delay paused:![real isRunning] block:block];

	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

//  func,
JSBool JSB_CCNode_unschedule_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION2( proxy && [proxy realObj], cx, JS_FALSE, "Invalid Proxy object");
	JSB_PRECONDITION2( argc == 1, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);

	CCNode *real = (CCNode*) [proxy realObj];
	CCScheduler *scheduler = [real scheduler];

	//
	// "function"
	//
	jsval funcval = *argvp++;
	JSFunction *func = JS_ValueToFunction(cx, funcval);
	JSB_PRECONDITION2( func, cx, JS_FALSE, "Cannot convert Value to Function");
	
	NSString *key = nil;
	JSString *funcname = JS_GetFunctionId(func);

	// named function
	if( funcname ) {
		char *key_c = JS_EncodeString(cx, funcname);
		key = [NSString stringWithUTF8String:key_c];
	} else {
		// anonymous function
		key = [NSString stringWithFormat:@"anonfunc at %p", func];
	}

	[scheduler unscheduleBlockForKey:key target:real];

	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

JSBool JSB_CCNode_setPosition_(JSContext *cx, uint32_t argc, jsval *vp) {

	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION2( proxy && [proxy realObj], cx, JS_FALSE, "Invalid Proxy object");
	JSB_PRECONDITION2( argc == 1 || argc == 2, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CGPoint arg0;

	if( argc == 1) {
		ok &= JSB_jsval_to_CGPoint( cx, *argvp++, (CGPoint*) &arg0 );
		JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error processing arguments");
	} else {
		double x, y;
		ok = JS_ValueToNumber(cx, *argvp++, &x);
		ok &= JS_ValueToNumber(cx, *argvp++, &y);
		JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error processing arguments");
		arg0 = ccp(x,y);
	}

	CCNode *real = (CCNode*) [proxy realObj];
	[real setPosition:(CGPoint)arg0  ];
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

#pragma mark - CCScheduler

// scheduler.scheduleCallbackForTarget(this, this.onSchedUpdate, interval, repeat, delay, paused);
JSBool JSB_CCScheduler_scheduleBlockForKey_target_interval_repeat_delay_paused_block_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION2( proxy && [proxy realObj], cx, JS_FALSE, "Invalid Proxy object");
	JSB_PRECONDITION2( argc >=2 && argc <=6, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);

	CCScheduler *scheduler = (CCScheduler*) [proxy realObj];

	JSBool ok = JS_TRUE;

	//
	// arg 0: target
	//
	// XXX: This must be rooted, right?
	JSObject *jstarget = JSVAL_TO_OBJECT(*argvp);
	id target;
	ok &= JSB_jsval_to_NSObject(cx, *argvp++, &target);

	//
	// arg 1: "function"
	//
	jsval funcval = *argvp++;
	JSFunction *func = JS_ValueToFunction(cx, funcval);
	JSB_PRECONDITION2( func, cx, JS_FALSE, "Cannot convert Value to Function");
	
	NSString *key = nil;
	JSString *funcname = JS_GetFunctionId(func);

	// named function
	if( funcname ) {
		char *key_c = JS_EncodeString(cx, funcname);
		key = [NSString stringWithUTF8String:key_c];
	} else {
		// anonymous function
		key = [NSString stringWithFormat:@"anonfunc at %p", func];
	}

	JSB_Callback *cb = JSB_prepare_callback(cx, jstarget, funcval);
	void (^block)(ccTime dt) = ^(ccTime dt) {

		jsval rval;
		jsval jsdt = DOUBLE_TO_JSVAL(dt);

		JSB_ENSURE_AUTOCOMPARTMENT(cx, jstarget);
		JSBool ok = JSB_execute_callback(cb, 1, &jsdt, &rval);
		JSB_PRECONDITION2(ok, cx, ,"Error calling collision callback: schedule_interval_repeat_delay");
	};

	//
	// arg 2: Interval
	//
	double interval = 0;
	if( argc >= 3 )
		ok &= JS_ValueToNumber(cx, *argvp++, &interval );

	//
	// arg 3: repeat
	//
	int32_t repeat = -1;
	if( argc >= 4 )
		ok &= JS_ValueToECMAInt32(cx, *argvp++, &repeat);
	// convert -1 to kCCRepeatForever
	if( repeat == -1)
		repeat = kCCRepeatForever;

	//
	// arg 4: delay
	//
	double delay = 0;
	if( argc >= 5 )
		ok &= JS_ValueToNumber(cx, *argvp++, &delay );

	//
	// arg 5: paused
	//
	JSBool paused = JS_FALSE;
	if( argc >= 6 )
		ok &= JS_ValueToBoolean(cx, *argvp++, &paused);

	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error converting jsval to native");
	
	
	[scheduler scheduleBlockForKey:key target:target interval:interval repeat:repeat delay:delay paused:paused block:block];

	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

#pragma mark - CCTMXLayer
JSBool JSB_CCTMXLayer_getTileFlagsAt(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION2( proxy && [proxy realObj], cx, JS_FALSE, "Invalid Proxy object");
	JSB_PRECONDITION2( argc == 1, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CGPoint arg0;

	ok &= JSB_jsval_to_CGPoint( cx, *argvp++, (CGPoint*) &arg0 );
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error processing arguments");
	
	CCTMXLayer *real = (CCTMXLayer*) [proxy realObj];
	ccTMXTileFlags flags;
	[real tileGIDAt:(CGPoint)arg0  withFlags:&flags];

	JS_SET_RVAL(cx, vp, UINT_TO_JSVAL((uint32_t)flags));
	return JS_TRUE;
}

#pragma mark - setBlendFunc friends

// setBlendFunc
JSBool JSB_CCParticleSystem_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsthis);

	JSB_PRECONDITION( proxy && [proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc==2, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);

	id real = (id) [proxy realObj];
	JSBool ok = JS_TRUE;

	GLenum src, dst;

	ok &= JS_ValueToInt32(cx, *argvp++, (int32_t*)&src);
	ok &= JS_ValueToInt32(cx, *argvp++, (int32_t*)&dst);

	if( ! ok )
		return JS_FALSE;

	[real setBlendFunc:(ccBlendFunc){src, dst}];

	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

JSBool JSB_CCSprite_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSB_CCSpriteBatchNode_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSB_CCMotionStreak_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSB_CCDrawNode_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSB_CCAtlasNode_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSB_CCParticleBatchNode_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSB_CCLayerColor_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

#pragma mark - Effects

JSBool JSB_CCLens3D_setPosition_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCNode_setPosition_(cx, argc, vp);
}
JSBool JSB_CCRipple3D_setPosition_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCNode_setPosition_(cx, argc, vp);
}
JSBool JSB_CCTwirl_setPosition_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCNode_setPosition_(cx, argc, vp);
}

#pragma mark - Actions

JSBool JSB_CCBezierBy_actionWithDuration_bezier__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION2( argc == 2, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	double arg0;
	CGPoint *array;
	int numPoints;

	ok &= JS_ValueToNumber( cx, *argvp++, &arg0 );
	ok &= JSB_jsval_to_array_of_CGPoint(cx, *argvp++, &array, &numPoints);
	
	JSB_PRECONDITION2(ok && numPoints==3, cx, JS_FALSE, "Error processing arguments. Expending an array of 3 elements");
	
	CCBezierTo* ret_val;

	ccBezierConfig config;
	config.controlPoint_1 = array[0];
	config.controlPoint_2 = array[1];
	config.endPosition = array[2];
	free(array);

	ret_val = [CCBezierBy actionWithDuration:arg0 bezier:config];

	JS_SET_RVAL(cx, vp, JSB_jsval_from_NSObject(cx, ret_val));

	return JS_TRUE;
}

JSBool JSB_CCBezierTo_actionWithDuration_bezier__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION2( argc == 2, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	double arg0;
	CGPoint *array;
	int numPoints;

	ok &= JS_ValueToNumber( cx, *argvp++, &arg0 );
	ok &= JSB_jsval_to_array_of_CGPoint(cx, *argvp++, &array, &numPoints);
	
	JSB_PRECONDITION2(ok && numPoints==3, cx, JS_FALSE, "Error processing arguments. Expending an array of 3 elements");

	CCBezierTo* ret_val;

	ccBezierConfig config;
	config.controlPoint_1 = array[0];
	config.controlPoint_2 = array[1];
	config.endPosition = array[2];
	free(array);

	ret_val = [CCBezierTo actionWithDuration:arg0 bezier:config];

	JS_SET_RVAL(cx, vp, JSB_jsval_from_NSObject(cx, ret_val));

	return JS_TRUE;
}

JSBool JSB_CCCardinalSplineBy_actionWithDuration_points_tension__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION2( argc == 3, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	double arg0; double arg2;
	CGPoint *array;
	int numPoints;

	ok &= JS_ValueToNumber( cx, *argvp++, &arg0 );
	ok &= JSB_jsval_to_array_of_CGPoint(cx, *argvp++, &array, &numPoints);
	ok &= JS_ValueToNumber( cx, *argvp++, &arg2 );
	
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error processing arguments");
	CCCardinalSplineTo* ret_val;

	CCPointArray *points = [CCPointArray arrayWithCapacity:numPoints];
	for( int i=0; i<numPoints;i++)
		[points addControlPoint:array[i]];
	free(array);

	ret_val = [CCCardinalSplineBy actionWithDuration:(ccTime)arg0 points:points tension:(CGFloat)arg2  ];

	JS_SET_RVAL(cx, vp, JSB_jsval_from_NSObject(cx, ret_val));

	return JS_TRUE;
}

// Arguments: ccTime, CCPointArray*, CGFloat
// Ret value: CCCardinalSplineTo* (o)
JSBool JSB_CCCardinalSplineTo_actionWithDuration_points_tension__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION2( argc == 3, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	double arg0; double arg2;
	CGPoint *array;
	int numPoints;

	ok &= JS_ValueToNumber( cx, *argvp++, &arg0 );
	ok &= JSB_jsval_to_array_of_CGPoint(cx, *argvp++, &array, &numPoints);
	ok &= JS_ValueToNumber( cx, *argvp++, &arg2 );
		
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error processing arguments");
	CCCardinalSplineTo* ret_val;

	CCPointArray *points = [CCPointArray arrayWithCapacity:numPoints];
	for( int i=0; i<numPoints;i++)
		[points addControlPoint:array[i]];
	free(array);

	ret_val = [CCCardinalSplineTo actionWithDuration:(ccTime)arg0 points:points tension:(CGFloat)arg2  ];

	JS_SET_RVAL(cx, vp, JSB_jsval_from_NSObject(cx, ret_val));

	return JS_TRUE;
}

// Arguments: ccTime, CCPointArray*
// Ret value: CCCatmullRomBy* (o)
JSBool JSB_CCCatmullRomBy_actionWithDuration_points__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION2( argc == 2, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	double arg0;
	CGPoint *array;
	int numPoints;

	ok &= JS_ValueToNumber( cx, *argvp++, &arg0 );
	ok &= JSB_jsval_to_array_of_CGPoint(cx, *argvp++, &array, &numPoints);
	
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error processing arguments");
	CCCatmullRomTo* ret_val;

	CCPointArray *points = [CCPointArray arrayWithCapacity:numPoints];
	for( int i=0; i<numPoints;i++)
		[points addControlPoint:array[i]];
	free(array);

	ret_val = [CCCatmullRomBy actionWithDuration:(ccTime)arg0 points:points  ];

	JS_SET_RVAL(cx, vp, JSB_jsval_from_NSObject(cx, ret_val));

	return JS_TRUE;
}

// Arguments: ccTime, CCPointArray*
// Ret value: CCCatmullRomTo* (o)
JSBool JSB_CCCatmullRomTo_actionWithDuration_points__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION2( argc == 2, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	double arg0;
	CGPoint *array;
	int numPoints;

	ok &= JS_ValueToNumber( cx, *argvp++, &arg0 );
	ok &= JSB_jsval_to_array_of_CGPoint(cx, *argvp++, &array, &numPoints);

	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error processing arguments");
	CCCatmullRomTo* ret_val;

	CCPointArray *points = [CCPointArray arrayWithCapacity:numPoints];
	for( int i=0; i<numPoints;i++)
		[points addControlPoint:array[i]];
	free(array);

	ret_val = [CCCatmullRomTo actionWithDuration:(ccTime)arg0 points:points  ];

	JS_SET_RVAL(cx, vp, JSB_jsval_from_NSObject(cx, ret_val));

	return JS_TRUE;
}

#endif // JSB_INCLUDE_COCOS2D
