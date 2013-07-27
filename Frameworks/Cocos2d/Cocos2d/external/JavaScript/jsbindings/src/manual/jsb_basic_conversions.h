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

#ifndef __JSB_BASIC_CONVERSIONS_H
#define __JSB_BASIC_CONVERSIONS_H

#import <Foundation/Foundation.h>
#import "jsb_config.h"

#include "jsfriendapi.h"

typedef void (^js_block)(id sender);

/** Creates a JSObject, a ProxyObject and associates them with the real object */
JSObject* JSB_create_jsobject_from_realobj( JSContext* context, Class klass, id realObj );

/** Gets or Creates a JSObject, a ProxyObject and associates them with the real object */
JSObject * JSB_get_or_create_jsobject_from_realobj( JSContext *cx, id realObj);

/** Whether or not the jsval is an NSString. If ret is not null, it returns the converted object.
 Like JSB_jsval_to_NSString, but if it is not an NSString it does not report error.
 */
JSBool JSB_jsval_is_NSString( JSContext *cx, jsval vp, NSString **ret );

/** Whether or not the jsval is an NSObject. If ret is not null, it returns the converted object.
 Like JSB_jsval_to_NSObject, but if it is not an NSObject it does not report error.
 */
JSBool JSB_jsval_is_NSObject( JSContext *cx, jsval vp, NSObject **ret );

/** converts a jsval to a NSString */
JSBool JSB_jsval_to_NSString( JSContext *cx , jsval vp, NSString **out );

/** converts a jsval to a NSObject. If jsval is null it will return [NSNull null]. */
JSBool JSB_jsval_to_NSObject( JSContext *cx, jsval vp, NSObject **out );

/** converts a jsval to a NSDictionary */
JSBool JSB_jsval_to_NSDictionary( JSContext *cx , jsval vp, NSDictionary** out );

/** converts a jsval to a NSArray */
JSBool JSB_jsval_to_NSArray( JSContext *cx , jsval vp, NSArray **out );

/** converts a jsval to a NSSet */
JSBool JSB_jsval_to_NSSet( JSContext *cx , jsval vp, NSSet** out );

/** converts a jsval into the most approrate NSObject based on the value */
JSBool JSB_jsval_to_unknown(JSContext *cx, jsval vp, id* ret);

/** converts a JSString to a NSString */
JSBool JSB_JSString_to_NSString( JSContext *cx, JSString *jsstr, NSString **ret );

/** converts a variadic jsval to a NSArray */
JSBool JSB_jsvals_variadic_to_NSArray( JSContext *cx, jsval *vp, int argc, NSArray** out );
	
JSBool JSB_jsval_to_CGPoint( JSContext *cx, jsval vp, CGPoint *out );
JSBool JSB_jsval_to_CGSize( JSContext *cx, jsval vp, CGSize *out );
JSBool JSB_jsval_to_CGRect( JSContext *cx, jsval vp, CGRect *out );
/** converts a jsval to a 'handle'. Typically the handle is pointer to a struct */
JSBool JSB_jsval_to_opaque( JSContext *cx, jsval vp, void **out );
/** copies the contents of an array buffer view. */
JSBool JSB_jsval_to_struct( JSContext *cx, jsval vp, void *r, size_t size);
JSBool JSB_jsval_to_int32( JSContext *cx, jsval vp, int32_t *out);
JSBool JSB_jsval_to_uint32( JSContext *cx, jsval vp, uint32_t *ret );
JSBool JSB_jsval_to_uint16( JSContext *cx, jsval vp, uint16_t *ret );
JSBool JSB_jsval_to_long( JSContext *cx, jsval vp, long *out);
JSBool JSB_jsval_to_longlong( JSContext *cx, jsval vp, long long *out);
/** converts a jsval to a "handle" needed for Object Oriented C API */
JSBool JSB_jsval_to_c_class( JSContext *cx, jsval vp, void **r, struct jsb_c_proxy_s **out_proxy_optional);
/** converts a jsval to a block (1 == receives 1 argument (sender) ) */
JSBool JSB_jsval_to_block_1( JSContext *cx, jsval vp, JSObject *jsthis, js_block *out  );
/** converts a jsval to a block (2 == receives 2 argument (sender + custom) ) */
JSBool JSB_jsval_to_block_2( JSContext *cx, jsval vp, JSObject *jsthis, jsval arg, js_block *out  );
/** converts a jsval (JS string) into a char */
JSBool JSB_jsval_to_charptr( JSContext *cx, jsval vp, const char **out);
/** converts a typedarray-like sequence (typedarray or array of numbers) into a data pointer */
JSBool JSB_jsval_typedarray_to_dataptr( JSContext *cx, jsval vp, GLsizei *count, void **data, JSArrayBufferViewType t);
/** obtains the data pointer and size from an Array Buffer View (think of TypedArrays).*/
JSBool JSB_get_arraybufferview_dataptr( JSContext *cx, jsval vp, GLsizei *count, GLvoid **data );

jsval JSB_unknown_to_jsval( JSContext *cx, id obj);
/** Converts an NSObject into a jsval. It does not creates a new object if the NSObject has already been converted */
jsval JSB_jsval_from_NSObject( JSContext *cx, id object);
jsval JSB_jsval_from_NSString( JSContext *cx, NSString *str);
jsval JSB_jsval_from_NSNumber( JSContext *cx, NSNumber *number);
jsval JSB_jsval_from_NSDictionary( JSContext *cx, NSDictionary *dict);
jsval JSB_jsval_from_NSArray( JSContext *cx, NSArray *array);
jsval JSB_jsval_from_NSSet( JSContext *cx, NSSet *set);
jsval JSB_jsval_from_int32( JSContext *cx, int32_t l);
jsval JSB_jsval_from_uint32( JSContext *cx, uint32_t number );
jsval JSB_jsval_from_long( JSContext *cx, long l);
jsval JSB_jsval_from_longlong( JSContext *cx, long long l);
jsval JSB_jsval_from_CGPoint( JSContext *cx, CGPoint p );
jsval JSB_jsval_from_CGSize( JSContext *cx, CGSize s);
jsval JSB_jsval_from_CGRect( JSContext *cx, CGRect r);
/** Converts an C Structure (handle) into a jsval. It returns jsval that will be sued as a "pointer" to the C Structure */
jsval JSB_jsval_from_opaque( JSContext *cx, void* opaque);
/** Converts an C class (a structure) into a jsval. It does not creates a new object it the C class has already been converted */
jsval JSB_jsval_from_c_class( JSContext *cx, void* handle, JSObject* object, JSClass *klass, const char* optional_class_name);
/* Converts a char ptr into a jsval (using JS string) */
jsval JSB_jsval_from_charptr( JSContext *cx, const char *str);
jsval JSB_jsval_from_unknown( JSContext *cx, id obj);
jsval JSB_jsval_from_struct( JSContext *cx, GLsizei count, void *data, JSArrayBufferViewType t);

/** Adds GC roots for funcval and jsthis tied to the lifetime of a block */
@interface JSB_Callback : NSObject
{
}
@property (nonatomic, readonly, assign) JSContext *cx;
@property (nonatomic, readonly, assign) JSObject *jsthis;
@property (nonatomic, readonly, assign) jsval funcval;

- (id) initWithContext:(JSContext *)cx funcval:(jsval)funcval jsthis:(JSObject*)jsthis;

@end

JSB_Callback* JSB_prepare_callback( JSContext *cx, JSObject *jsthis, jsval funcval);
JSBool JSB_execute_callback( JSB_Callback *cb, unsigned argc, jsval *argv, jsval *rval);


#ifndef _UINT32
typedef uint32_t uint32;
#define _UINT32
#endif // _UINT32

#endif // __JSB_BASIC_CONVERSIONS_H
