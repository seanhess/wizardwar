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


#import "jsapi.h"
#import "jsfriendapi.h"

#import "jsb_core.h"
#import "jsb_config.h"
#import "jsb_NS_manual.h"


#pragma mark - helpers

JSObject* JSB_create_jsobject_from_realobj( JSContext* context, Class klass, id realObj )
{
	NSString *proxied_class = [NSString stringWithFormat:@"JSB_%@", klass];
	Class newKlass = NSClassFromString(proxied_class);
	if( newKlass )
		return [newKlass createJSObjectWithRealObject:realObj context:context];

	CCLOGWARN(@"Proxied class not found: %@. Trying with parent class", proxied_class );
	return JSB_create_jsobject_from_realobj( context, [klass superclass], realObj  );
}

JSObject * JSB_get_or_create_jsobject_from_realobj( JSContext *cx, id realObj )
{
	if( ! realObj )
		return NULL;
		
	JSB_NSObject *proxy = objc_getAssociatedObject(realObj, &JSB_association_proxy_key );
	if( proxy )
		return [proxy jsObj];
	
	return JSB_create_jsobject_from_realobj( cx, [realObj class], realObj );
}

#pragma mark - jsval to native

JSBool JSB_jsval_is_NSObject( JSContext *cx, jsval vp, NSObject **ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	if( ! ok )
		return JS_FALSE;
	
	// root it
	vp = OBJECT_TO_JSVAL(jsobj);
	
	JSB_NSObject* proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsobj);
	if( ! proxy )
		return  JS_FALSE;

	if( ret )
		*ret = [proxy realObj];
	
	return JS_TRUE;
}

// Convert function
JSBool JSB_jsval_to_NSObject( JSContext *cx, jsval vp, NSObject **ret )
{
	// special case: jsval is null
	if( JSVAL_IS_NULL(vp) ) {
		*ret = [NSNull null];
		return JS_TRUE;
	}

	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to object");
	
	// root it
	vp = OBJECT_TO_JSVAL(jsobj);
	
	JSB_NSObject* proxy = (JSB_NSObject*) JSB_get_proxy_for_jsobject(jsobj);
	
	JSB_PRECONDITION2( proxy, cx, JS_FALSE, "Error obtaining proxy");

	*ret = [proxy realObj];
	
	return JS_TRUE;
}

JSBool JSB_jsval_is_NSString( JSContext *cx, jsval vp, NSString **ret )
{
	// IMPORTANT: Do not use vp.isString() because numbers can also be converted to strings
	JSString *jsstr = JS_ValueToString( cx, vp );
	if( ! jsstr )
		return JS_FALSE;

	const jschar *chars = JS_GetStringCharsZ(cx, jsstr);
	size_t l = JS_GetStringLength(jsstr);

	JSB_PRECONDITION2(chars, cx, JS_FALSE, "Error getting characters from string");

	NSString *tmp = [NSString stringWithCharacters:chars length:l];

	JSB_PRECONDITION2( tmp, cx, JS_FALSE, "Error creating string from UTF8");

	*ret = tmp;

	return JS_TRUE;
}

JSBool JSB_jsval_to_NSString( JSContext *cx, jsval vp, NSString **ret )
{
	// IMPORTANT: Do not use vp.isString() because numbers can also be converted to strings
	JSString *jsstr = JS_ValueToString( cx, vp );
	JSB_PRECONDITION2( jsstr, cx, JS_FALSE, "invalid string" );

	return JSB_JSString_to_NSString( cx, jsstr, ret );
}

JSBool JSB_JSString_to_NSString( JSContext *cx, JSString *jsstr, NSString **ret )
{
	const jschar *chars = JS_GetStringCharsZ(cx, jsstr);
	size_t l = JS_GetStringLength(jsstr);

	JSB_PRECONDITION2(chars, cx, JS_FALSE, "Error getting characters from string");
	
	NSString *tmp = [NSString stringWithCharacters:chars length:l];
	
	JSB_PRECONDITION2( tmp, cx, JS_FALSE, "Error creating string from UTF8");
	
	*ret = tmp;

	return JS_TRUE;
}

JSBool JSB_jsval_to_NSDictionary( JSContext *cx, jsval vp, NSDictionary**ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to object");

	JSIdArray *keys = JS_Enumerate(cx, jsobj);
	int len = JS_IdArrayLength(cx, keys);

	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:len];

	for (int i = 0; i < len; i++) {
		jsid keyid = JS_IdArrayGet(cx, keys, i);
		jsval valarg;

		ok = JS_GetPropertyById(cx, jsobj, keyid, &valarg);
		JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error getting property");

		id real_obj;
		ok = JSB_jsval_to_unknown( cx, valarg, &real_obj );
		JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to nsobject");

		id key = nil;
		if (JSID_IS_STRING(keyid)) {
			ok = JSB_JSString_to_NSString(cx, JSID_TO_STRING(keyid), &key);
			JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting keyid");
		} else if (JSID_IS_INT(keyid)) {
			key = [NSNumber numberWithInt:JSID_TO_INT(keyid)];
		} else {
			JSB_PRECONDITION2( JS_FALSE, cx, JS_FALSE, "Error converting keyid");
		}

		// NSDictionary doesn't allow nil objects
		if (real_obj) {
			[dict setObject:real_obj forKey:key];
		}
	}

	*ret = dict;
	return JS_TRUE;
}

JSBool JSB_jsval_to_NSArray( JSContext *cx, jsval vp, NSArray**ret )
{
	// Parsing sequence
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to object");
	
	JSB_PRECONDITION2( jsobj && JS_IsArrayObject( cx, jsobj),  cx, JS_FALSE, "Object must be an array");

	
	uint32_t len;
	JS_GetArrayLength(cx, jsobj,&len);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:len];
	for( uint32_t i=0; i< len;i++ ) {		
		jsval valarg;
		JS_GetElement(cx, jsobj, i, &valarg);
		
		id real_obj;
		ok = JSB_jsval_to_unknown( cx, valarg, &real_obj );
		JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to nsobject");
		
		[array addObject:real_obj];
	}
	*ret = array;

	return JS_TRUE;
}

JSBool JSB_jsval_to_NSSet( JSContext *cx, jsval vp, NSSet** ret)
{
	// Parsing sequence
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to object");
	
	JSB_PRECONDITION2( jsobj && JS_IsArrayObject( cx, jsobj), cx, JS_FALSE, "Object must be an array");

	uint32_t len;
	JS_GetArrayLength(cx, jsobj,&len);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:len];
	for( uint32_t i=0; i< len;i++ ) {		
		jsval valarg;
		JS_GetElement(cx, jsobj, i, &valarg);
		
		// XXX: forcing them to be objects, but they could also be NSString, NSDictionary or NSArray
		id real_obj;
		ok = JSB_jsval_is_NSObject( cx, valarg, &real_obj );
		JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to nsobject");
		
		[array addObject:real_obj];
	}
	*ret = [NSSet setWithArray:array];;
	return JS_TRUE;
}

JSBool JSB_jsval_to_NSNumber( JSContext *cx, jsval vp, NSNumber** ret)
{
	JSBool ok = JSVAL_IS_NUMBER(vp);
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Object must be a number");

	*ret = [NSNumber numberWithDouble:JSVAL_TO_DOUBLE(vp)];
	return JS_TRUE;
}

JSBool JSB_jsval_to_unknown(JSContext *cx, jsval vp, id* ret)
{

	// Number
	if (JSVAL_IS_NUMBER(vp)) {
		// JSVAL_TO_DOUBLE was crashing... why???
		double number;
		if( JS_ValueToNumber(cx, vp, &number) ) {
			*ret = [NSNumber numberWithDouble:number];
			return JS_TRUE;
		}
		return JS_FALSE;
	}
	// Boolean
	else if (JSVAL_IS_BOOLEAN(vp)) {
		*ret = [NSNumber numberWithBool:JSVAL_TO_BOOLEAN(vp)];
		return JS_TRUE;
	}
	// String
	else if (JSVAL_IS_STRING(vp)) {
		return JSB_jsval_to_NSString( cx, vp, ret );
	}
	// Null
	else if (JSVAL_IS_NULL(vp)) {
		*ret = [NSNull null];
		return JS_TRUE;
	}
	// undefined
	else if (JSVAL_IS_VOID(vp)) {
		*ret = NULL;
		return JS_TRUE;
	}

	// Is Native Object ?
	if (JSB_jsval_is_NSObject( cx, vp, ret )) {
		return JS_TRUE;
	}

	JSObject *jsobj;
	if (JS_ValueToObject( cx, vp, &jsobj )) {

		// Array ?
		if (JS_IsArrayObject(cx, jsobj)) {
			return JSB_jsval_to_NSArray(cx, vp, ret);
		}

		// Default to dictionary
		return JSB_jsval_to_NSDictionary(cx, vp, ret);
	}

	return JS_FALSE;
}

JSBool JSB_jsvals_variadic_to_NSArray( JSContext *cx, jsval *vp, int argc, NSArray**ret )
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:argc];
	
	for( int i=0; i < argc; i++ )
	{
		id obj = NULL;
		JSBool ok = JSB_jsval_to_unknown(cx, *vp, &obj);

		JSB_PRECONDITION2( ok && obj, cx, JS_FALSE, "Error converting variadic arguments");

		// next
		vp++;
		
		[array addObject:obj];
	}
	*ret = array;
	return JS_TRUE;
}

JSBool JSB_jsval_to_block_1( JSContext *cx, jsval vp, JSObject *jsthis, js_block *ret)
{
	// special case: jsval is null
	if( JSVAL_IS_NULL(vp) ) {
		*ret = NULL;
		return JS_TRUE;
	}

	JSFunction *func = JS_ValueToFunction(cx, vp );
	JSB_PRECONDITION2( func, cx, JS_FALSE, "Error converting value to function");

	JSB_Callback *cb = JSB_prepare_callback(cx, jsthis, vp);
	js_block block = ^(id sender) {
		jsval rval;
		jsval val = JSB_jsval_from_unknown(cx, sender);

		JSB_ENSURE_AUTOCOMPARTMENT(cx, jsthis);
		JSBool ok = JSB_execute_callback(cb, 1, &val, &rval);
		JSB_PRECONDITION2(ok, cx, , "Error calling callback (1)");
	};
	
	*ret = [[block copy] autorelease];
	return JS_TRUE;
}

JSBool JSB_jsval_to_block_2( JSContext *cx, jsval vp, JSObject *jsthis, jsval arg, js_block *ret)
{
	JSFunction *func = JS_ValueToFunction(cx, vp );
	JSB_PRECONDITION2( func, cx, JS_FALSE, "Error converting value to function");
		
	js_block block = ^(id sender) {
		
		jsval rval;
		jsval vals[2];
		
		vals[0] = JSB_jsval_from_NSObject(cx, sender);
		
		// arg NEEDS TO BE ROOTED! Potential crash
		vals[1] = arg;
		
		JSB_ENSURE_AUTOCOMPARTMENT(cx, jsthis);
		JSBool ok = JS_CallFunctionValue(cx, jsthis, vp, 2, vals, &rval);
		JSB_PRECONDITION2(ok, cx, , "Error calling callback (2)");
	};
	
	*ret = [[block copy] autorelease];
	return JS_TRUE;
}

JSBool JSB_jsval_to_CGPoint( JSContext *cx, jsval vp, CGPoint *ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION2( jsobj, cx, JS_FALSE, "Not a valid JS object");

	jsval valx, valy;
	ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "x", &valx);
	ok &= JS_GetProperty(cx, jsobj, "y", &valy);
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error obtaining point properties");
	
	double x, y;
	ok &= JS_ValueToNumber(cx, valx, &x);
	ok &= JS_ValueToNumber(cx, valy, &y);
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to numbers");

	ret->x = x;
	ret->y = y;

	return JS_TRUE;
}

JSBool JSB_jsval_to_CGSize( JSContext *cx, jsval vp, CGSize *ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION2( jsobj, cx, JS_FALSE, "Not a valid JS object");
	
	jsval valw, valh;
	ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "width", &valw);
	ok &= JS_GetProperty(cx, jsobj, "height", &valh);	
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error obtaining point properties");
	
	double w, h;
	ok &= JS_ValueToNumber(cx, valw, &w);
	ok &= JS_ValueToNumber(cx, valh, &h);	
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to numbers");
	
	ret->width = w;
	ret->height = h;
	
	return JS_TRUE;	
}

JSBool JSB_jsval_to_CGRect( JSContext *cx, jsval vp, CGRect *ret )
{	
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION2( jsobj, cx, JS_FALSE, "Not a valid JS object");
	
	jsval valx, valy, valw, valh;
	ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "x", &valx);
	ok &= JS_GetProperty(cx, jsobj, "y", &valy);
	ok &= JS_GetProperty(cx, jsobj, "width", &valw);
	ok &= JS_GetProperty(cx, jsobj, "height", &valh);
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error obtaining point properties");
	
	double x, y, w, h;
	ok &= JS_ValueToNumber(cx, valx, &x);
	ok &= JS_ValueToNumber(cx, valy, &y);
	ok &= JS_ValueToNumber(cx, valw, &w);
	ok &= JS_ValueToNumber(cx, valh, &h);
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to numbers");
	
	ret->origin.x = x;
	ret->origin.y = y;
	ret->size.width = w;
	ret->size.height = h;
	
	return JS_TRUE;	
}

JSBool JSB_jsval_to_opaque( JSContext *cx, jsval vp, void **r)
{
#ifdef __LP64__
	JSObject *tmp_arg;
	JSBool ok = JS_ValueToObject( cx, vp, &tmp_arg );
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION2( tmp_arg && JS_IsTypedArrayObject( tmp_arg ), cx, JS_FALSE, "Not a TypedArray object");
	JSB_PRECONDITION2( JS_GetTypedArrayByteLength( tmp_arg ) == sizeof(void*), cx, JS_FALSE, "Invalid Typed Array length");
	
	uint32_t* arg_array = (uint32_t*)JS_GetArrayBufferViewData( tmp_arg );
	uint64 ret =  arg_array[0];
	ret = ret << 32;
	ret |= arg_array[1];
	
#else
	NSCAssert( sizeof(int)==4, @"fatal!");
	int32_t ret;
	JSBool ok = JS_ValueToInt32(cx, vp, &ret );
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error converting value to int32");
#endif
	*r = (void*)ret;
	return JS_TRUE;
}

JSBool JSB_jsval_to_struct( JSContext *cx, jsval vp, void *r, size_t size)
{
	JSObject *tmp_arg;
	JSBool ok = JS_ValueToObject( cx, vp, &tmp_arg );
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION2( tmp_arg && JS_IsTypedArrayObject( tmp_arg ), cx, JS_FALSE, "Not a TypedArray object");
	JSB_PRECONDITION2( JS_GetTypedArrayByteLength( tmp_arg ) == size, cx, JS_FALSE, "Invalid Typed Array length");

	void *data = JS_GetArrayBufferViewData( tmp_arg );
	memcpy(r, data, size);
	return JS_TRUE;
}

JSBool JSB_jsval_to_c_class( JSContext *cx, jsval vp, void **out_native, struct jsb_c_proxy_s **out_proxy)
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject(cx, vp, &jsobj);
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error converting jsval to object");
	
	struct jsb_c_proxy_s *proxy = JSB_get_c_proxy_for_jsobject(jsobj);
	*out_native = proxy->handle;
	if( out_proxy )
		*out_proxy = proxy;
	return JS_TRUE;
}

JSBool JSB_jsval_to_int32( JSContext *cx, jsval vp, int32_t *outval )
{
	JSBool ret = JS_FALSE;
	double dp;
	if( (ret=JS_ValueToNumber(cx, vp, &dp)) ) {
		if( isnan(dp))
			return JS_FALSE;
		*outval = (int32_t)dp;
	}	
	return ret;
}

JSBool JSB_jsval_to_uint32( JSContext *cx, jsval vp, uint32_t *outval )
{
	JSBool ret = JS_FALSE;
	double dp;
	if( (ret=JS_ValueToNumber(cx, vp, &dp)) ) {
		if( isnan(dp))
			return JS_FALSE;
		*outval = (uint32_t)dp;
	}
	return ret;
}

JSBool JSB_jsval_to_uint16( JSContext *cx, jsval vp, uint16_t *outval )
{
	JSBool ret = JS_FALSE;
	double dp;
	if( (ret=JS_ValueToNumber(cx, vp, &dp)) ) {
		if( isnan(dp))
			return JS_FALSE;
		*outval = (uint16_t)dp;
	}
	return ret;
}


// XXX: sizeof(long) == 8 in 64 bits on OS X... apparently on Windows it is 32 bits (???)
JSBool JSB_jsval_to_long( JSContext *cx, jsval vp, long *r )
{
#ifdef __LP64__
	// compatibility check
	NSCAssert( sizeof(long)==8, @"fatal! Compiler error ?");
	JSString *jsstr = JS_ValueToString(cx, vp);
	JSB_PRECONDITION2(jsstr, cx, JS_FALSE, "Error converting value to string");
	
	char *str = JS_EncodeString(cx, jsstr);
	JSB_PRECONDITION2(str, cx, JS_FALSE, "Error encoding string");
	
	char *endptr;
	long ret = strtol(str, &endptr, 10);
	
	*r = ret;
	return JS_TRUE;	
#else
	// compatibility check
	NSCAssert( sizeof(int)==4, @"fatal!, Compiler error ?");
	long ret = JSVAL_TO_INT(vp);
#endif
	
	*r = ret;
	return JS_TRUE;
}

JSBool JSB_jsval_to_longlong( JSContext *cx, jsval vp, long long *r )
{
#if JSB_REPRESENT_LONGLONG_AS_STR
	JSString *jsstr = JS_ValueToString(cx, vp);
	JSB_PRECONDITION2(jsstr, cx, JS_FALSE, "Error converting value to string");

	char *str = JS_EncodeString(cx, jsstr);
	JSB_PRECONDITION2(str, cx, JS_FALSE, "Error encoding string");

	char *endptr;
	long long ret = strtoll(str, &endptr, 10);
	
	*r = ret;
	return JS_TRUE;

#else

	JSObject *tmp_arg;
	JSBool ok = JS_ValueToObject( cx, vp, &tmp_arg );
	JSB_PRECONDITION2( ok, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION2( tmp_arg && JS_IsTypedArrayObject( tmp_arg, cx ), cx, JS_FALSE, "Not a TypedArray object");
	JSB_PRECONDITION2( JS_GetTypedArrayByteLength( tmp_arg, cx ) == sizeof(long long), cx, JS_FALSE, "Invalid Typed Array length");
	
	uint32_t* arg_array = (uint32_t*)JS_GetArrayBufferViewData( tmp_arg, cx );
	long long ret =  arg_array[0];
	ret = ret << 32;
	ret |= arg_array[1];
	
	*r = ret;
	return JS_TRUE;
#endif // JSB_REPRESENT_LONGLONG_AS_STR
}

JSBool JSB_jsval_to_charptr( JSContext *cx, jsval vp, const char **ret )
{
	JSString *jsstr = JS_ValueToString( cx, vp );
	JSB_PRECONDITION2( jsstr, cx, JS_FALSE, "invalid string" );
	
	// root it
	vp = STRING_TO_JSVAL(jsstr);
	
	char *ptr = JS_EncodeString(cx, jsstr);
	
	JSB_PRECONDITION2(ptr, cx, JS_FALSE, "Error encoding string");
	
	// XXX: It is converted to NSString and then back to char* to autorelease the created object.
	NSString *tmp = [NSString stringWithCString:ptr encoding:NSUTF8StringEncoding];
	
	JSB_PRECONDITION2( tmp, cx, JS_FALSE, "Error creating string from UTF8");
	
	*ret = [tmp UTF8String];
	JS_free( cx, ptr );
	
	return JS_TRUE;
}

JSBool JSB_jsval_typedarray_to_dataptr( JSContext *cx, jsval vp, GLsizei *count, void **data, JSArrayBufferViewType t)
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION2( ok && jsobj, cx, JS_FALSE, "Error converting value to object");

	// WebGL supports TypedArray and sequences for some of its APIs. So when converting a TypedArray, we should
	// also check for a possible non-Typed Array JS object, like a JS Array.

	if( JS_IsTypedArrayObject( jsobj ) ) {

		*count = JS_GetTypedArrayLength(jsobj);
		JSArrayBufferViewType type = JS_GetArrayBufferViewType(jsobj);
		JSB_PRECONDITION2(t==type, cx, JS_FALSE, "TypedArray type different than expected type");

		switch (t) {
			case js::ArrayBufferView::TYPE_INT8:
			case js::ArrayBufferView::TYPE_UINT8:
				*data = JS_GetUint8ArrayData(jsobj);
				break;

			case js::ArrayBufferView::TYPE_INT16:
			case js::ArrayBufferView::TYPE_UINT16:
				*data = JS_GetUint16ArrayData(jsobj);
				break;

			case js::ArrayBufferView::TYPE_INT32:
			case js::ArrayBufferView::TYPE_UINT32:
				*data = JS_GetUint32ArrayData(jsobj);
				break;

			case js::ArrayBufferView::TYPE_FLOAT32:
				*data = JS_GetFloat32ArrayData(jsobj);
				break;

			default:
				JSB_PRECONDITION2(NO, cx, JS_FALSE, "Unsupported typedarray type");
				break;
		}
	} else if( JS_IsArrayObject(cx, jsobj)) {
		// Slow... avoid it. Use TypedArray instead, but the spec says that it can receive
		// Sequence<> as well.
		uint32_t length;
		JS_GetArrayLength(cx, jsobj, &length);

		for( uint32_t i=0; i<length;i++ ) {

			jsval valarg;
			JS_GetElement(cx, jsobj, i, &valarg);

			switch(t) {
				case js::ArrayBufferView::TYPE_INT32:
				case js::ArrayBufferView::TYPE_UINT32:
				{
					uint32_t e = JSVAL_TO_INT(valarg);
					((uint32_t*)data)[i] = e;
					break;
				}
				case js::ArrayBufferView::TYPE_FLOAT32:
				{
					double e = JSVAL_TO_DOUBLE(valarg);
					((GLfloat*)data)[i] = (GLfloat)e;
					break;
				}
				default:
					JSB_PRECONDITION2(NO, cx, JS_FALSE, "Unsupported typedarray type");
					break;
			}
		}

	} else
		JSB_PRECONDITION2(NO, cx, JS_FALSE, "Object shall be a TypedArray or Sequence");

	return JS_TRUE;
}

JSBool JSB_get_arraybufferview_dataptr( JSContext *cx, jsval vp, GLsizei *count, GLvoid **data )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION2( ok && jsobj, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION2( JS_IsArrayBufferViewObject(jsobj), cx, JS_FALSE, "Not an ArrayBufferView object");

	*data = JS_GetArrayBufferViewData(jsobj);
	*count = JS_GetArrayBufferViewByteLength(jsobj);

	return JS_TRUE;
}


#pragma mark - native to jsval

jsval JSB_jsval_from_unknown( JSContext *cx, id obj)
{
	if( [obj isKindOfClass:[NSString class]] )
		return JSB_jsval_from_NSString(cx, obj);

	if( [obj isKindOfClass:[NSNumber class]] )
		return JSB_jsval_from_NSNumber(cx, obj);

	if( [obj isKindOfClass:[NSArray class]] )
		return JSB_jsval_from_NSArray(cx, obj);

	if( [obj isKindOfClass:[NSDictionary class]] )
		return JSB_jsval_from_NSDictionary(cx, obj);

	if( [obj isKindOfClass:[NSSet class]] )
		return JSB_jsval_from_NSSet(cx, obj);

    if ( [obj isKindOfClass:[NSNull class]] )
        return JSVAL_NULL;

	return JSB_jsval_from_NSObject(cx, obj);
}

jsval JSB_jsval_from_NSObject( JSContext *cx, id obj )
{
	jsval ret;
	if( ! obj )
		return JSVAL_NULL;
	
	JSB_NSObject *proxy = objc_getAssociatedObject(obj, &JSB_association_proxy_key );
	if( proxy )
		ret = OBJECT_TO_JSVAL([proxy jsObj]);
	
	else
		ret = OBJECT_TO_JSVAL( JSB_create_jsobject_from_realobj( cx, [obj class], obj ) );
	
	return ret;
}

jsval JSB_jsval_from_NSNumber( JSContext *cx, NSNumber *number)
{
	double ret_obj = [number doubleValue];
	return DOUBLE_TO_JSVAL(ret_obj);
}

jsval JSB_jsval_from_NSString( JSContext *cx, NSString *str)
{
	if( ! str )
		return JSVAL_NULL;
	
	size_t len = str.length;
	
	jschar *chars = (jschar *)malloc((len + 1) * sizeof(jschar));
	chars[len] = 0;
	[str getCharacters:chars range:NSMakeRange(0, len)];
	
	JSString *ret_obj = JS_NewUCString(cx, chars, len);
	return STRING_TO_JSVAL(ret_obj);
}

jsval JSB_jsval_from_NSArray( JSContext *cx, NSArray *array)
{
	JSObject *jsobj = JS_NewArrayObject(cx, 0, NULL);
	uint32_t index = 0;
	for( id obj in array ) {
        jsval val = JSB_jsval_from_unknown(cx, obj);
		JS_SetElement(cx, jsobj, index++, &val);
	}
	
	return OBJECT_TO_JSVAL(jsobj);
}

jsval JSB_jsval_from_NSDictionary( JSContext *cx, NSDictionary *dict)
{
	if (!dict) {
		return JSVAL_NULL;
	}

	__block JSObject *jsobj = JS_NewObject(cx, NULL, NULL, NULL);
	
	[dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		const char *k = NULL;
        	if([key isKindOfClass:[NSString class]]) {
           		k = [(NSString*)key UTF8String];
        	} else if([key isKindOfClass:[NSNumber class]]) {
            		k = [[(NSNumber*)key stringValue] UTF8String];
        	} 
        	if(k) {
			jsval val = JSB_jsval_from_unknown(cx, obj);
			JS_DefineProperty(cx, jsobj, k, val, NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT);
        	}
		*stop = NO;
	}];

	return OBJECT_TO_JSVAL(jsobj);
}


jsval JSB_jsval_from_NSSet( JSContext *cx, NSSet *set)
{
	JSObject *jsobj = JS_NewArrayObject(cx, 0, NULL);
	uint32_t index = 0;
	for( id obj in set ) {
        jsval val = JSB_jsval_from_unknown(cx, obj);
		JS_SetElement(cx, jsobj, index++, &val);
	}

	return OBJECT_TO_JSVAL(jsobj);
}

jsval JSB_jsval_from_CGPoint( JSContext *cx, CGPoint p)
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;

	if (!JS_DefineProperty(cx, object, "x", DOUBLE_TO_JSVAL(p.x), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "y", DOUBLE_TO_JSVAL(p.y), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);
}

jsval JSB_jsval_from_CGSize( JSContext *cx, CGSize s)
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;
	
	if (!JS_DefineProperty(cx, object, "width", DOUBLE_TO_JSVAL(s.width), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "height", DOUBLE_TO_JSVAL(s.height), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);	
}

jsval JSB_jsval_from_CGRect( JSContext *cx, CGRect rect)
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;
	
	if (!JS_DefineProperty(cx, object, "x", DOUBLE_TO_JSVAL(rect.origin.x), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "y", DOUBLE_TO_JSVAL(rect.origin.y), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "width", DOUBLE_TO_JSVAL(rect.size.width), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "height", DOUBLE_TO_JSVAL(rect.size.height), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);	
}

jsval JSB_jsval_from_opaque( JSContext *cx, void *opaque )
{
#ifdef __LP64__
	uint64_t number = (uint64_t)opaque;
	JSObject *typedArray = JS_NewUint32Array( cx, 2 );
	uint32_t *buffer = (uint32_t*)JS_GetArrayBufferViewData(typedArray);
	buffer[0] = number >> 32;
	buffer[1] = number & 0xffffffff;
	return OBJECT_TO_JSVAL(typedArray);		
#else
	NSCAssert( sizeof(int)==4, @"Error!");
	uint32_t number = (uint32_t) opaque;
	return INT_TO_JSVAL(number);
#endif
}

jsval JSB_jsval_from_c_class( JSContext *cx, void* handle, JSObject* object, JSClass *klass, const char* class_name)
{
	JSObject *jsobj;

	jsobj = JSB_get_jsobject_for_proxy(handle);
	if( !jsobj ) {
		jsobj = JS_NewObject(cx, klass, object, NULL);
		NSCAssert(jsobj, @"Invalid object");
		JSB_set_c_proxy_for_jsobject(jsobj, handle, JSB_C_FLAG_DO_NOT_CALL_FREE);
		JSB_set_jsobject_for_proxy(jsobj, handle);
	}

	return OBJECT_TO_JSVAL(jsobj);
}

jsval JSB_jsval_from_int32( JSContext *cx, int32_t number )
{
	return INT_TO_JSVAL(number);
}

jsval JSB_jsval_from_uint32( JSContext *cx, uint32_t number )
{
	return UINT_TO_JSVAL(number);
}

jsval JSB_jsval_from_long( JSContext *cx, long number )
{
#ifdef __LP64__
	NSCAssert( sizeof(long)==8, @"Error!");

	char chr[128];
	snprintf(chr, sizeof(chr)-1, "%ld", number);
	JSString *ret_obj = JS_NewStringCopyZ(cx, chr);
	return STRING_TO_JSVAL(ret_obj);
#else
	NSCAssert( sizeof(int)==4, @"Error!");
	return INT_TO_JSVAL(number);
#endif
}

jsval JSB_jsval_from_longlong( JSContext *cx, long long number )
{
#if JSB_REPRESENT_LONGLONG_AS_STR
	char chr[128];
	snprintf(chr, sizeof(chr)-1, "%lld", number);
	JSString *ret_obj = JS_NewStringCopyZ(cx, chr);
	return STRING_TO_JSVAL(ret_obj);

#else
	NSCAssert( sizeof(long long)==8, @"Error!");
	JSObject *typedArray = JS_NewUint32Array( cx, 2 );
	uint32_t *buffer = (uint32_t*)JS_GetArrayBufferViewData(typedArray, cx);
	buffer[0] = number >> 32;
	buffer[1] = number & 0xffffffff;
	return OBJECT_TO_JSVAL(typedArray);
#endif
}

jsval JSB_jsval_from_charptr( JSContext *cx, const char *str)
{
	JSString *ret_obj = JS_NewStringCopyZ(cx, str);
	return STRING_TO_JSVAL(ret_obj);
}

jsval JSB_jsval_from_struct( JSContext *cx, GLsizei count, void *data, JSArrayBufferViewType t)
{
	JSObject *typedArray;
	switch (t) {
		case js::ArrayBufferView::TYPE_INT8:
			typedArray = JS_NewInt8Array(cx, count);
			break;
		case js::ArrayBufferView::TYPE_UINT8:
			typedArray = JS_NewUint8Array(cx, count);
			break;
		case js::ArrayBufferView::TYPE_INT16:
			typedArray = JS_NewInt16Array(cx, count);
			break;
		case js::ArrayBufferView::TYPE_UINT16:
			typedArray = JS_NewUint16Array(cx, count);
			break;
		case js::ArrayBufferView::TYPE_INT32:
			typedArray = JS_NewInt32Array(cx, count);
			break;
		case js::ArrayBufferView::TYPE_UINT32:
			typedArray = JS_NewUint32Array(cx, count);
			break;
		case js::ArrayBufferView::TYPE_FLOAT32:
			typedArray = JS_NewFloat32Array(cx, count);
			break;
		case js::ArrayBufferView::TYPE_FLOAT64:
			typedArray = JS_NewFloat64Array(cx, count);
			break;
		default:
			JSB_PRECONDITION2(NO, cx, JSVAL_NULL, "Unsupported typedarray type");
			break;
	}
	
	memcpy(JS_GetArrayBufferViewData(typedArray), data, JS_GetArrayBufferViewByteLength(typedArray));
	return OBJECT_TO_JSVAL(typedArray);
}

JSB_Callback* JSB_prepare_callback( JSContext *cx, JSObject *jsthis, jsval funcval)
{
	return [[[JSB_Callback alloc] initWithContext:cx funcval:funcval jsthis:jsthis] autorelease];
}

JSBool JSB_execute_callback( JSB_Callback *cb, unsigned argc, jsval *argv, jsval *rval)
{
	JSContext *cx = cb.cx;
	JSObject *jsthis = cb.jsthis;
	jsval funcval = cb.funcval;

	return JS_CallFunctionValue(cx, jsthis, funcval, argc, argv, rval);
}

@implementation JSB_Callback

- (id) initWithContext:(JSContext *)cx funcval:(jsval)funcval jsthis:(JSObject*)jsthis
{
	if (self = [super init]) {
		_cx = cx;
		_funcval = funcval;
		_jsthis = jsthis;

		JS_AddValueRoot(cx, &_funcval);
		JS_AddObjectRoot(cx, &_jsthis);
	}
	return self;
}

- (void) dealloc
{
	JS_RemoveValueRoot(_cx, &_funcval);
	JS_RemoveObjectRoot(_cx, &_jsthis);
	[super dealloc];
}

@end
