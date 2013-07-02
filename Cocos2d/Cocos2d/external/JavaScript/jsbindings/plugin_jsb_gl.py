#!/usr/bin/python
# ----------------------------------------------------------------------------
# Plugin to generate OpenGL ES 2.0 / WebGL code for JSB
#
# Author: Ricardo Quesada
# Copyright 2013 (C) Zynga, Inc
#
# License: MIT
# ----------------------------------------------------------------------------
'''
Plugin to generate OpenGL ES 2.0 / WebGL code for JSB
'''

__docformat__ = 'restructuredtext'


# python modules
import re

# plugin modules
from generate_jsb import JSBGenerateFunctions


#
#
# OpenGL ES 2.0 / WebGL function plugin
#
#
class JSBGenerateFunctions_GL(JSBGenerateFunctions):

    def __init__(self, config):
        super(JSBGenerateFunctions_GL, self).__init__(config)

        # TypedArray ivars
        self._current_typedarray = None
        self._with_count = False
        self._typedarray_dt = ['TypedArray/Sequence', 'ArrayBufferView']

        # Extend supported types
        self.args_js_special_type_conversions['TypedArray'] = ['JSB_jsval_typedarray_to_dataptr', 'void*']
        self.args_js_special_type_conversions['ArrayBufferView'] = ['JSB_get_arraybufferview_dataptr', 'void*']

        # Other supported functions
        self.supported_functions_without_count = ['glReadPixels', 'glDrawElements', 'glTexImage2D', 'glTexSubImage2D', 'glCompressedTexImage2D', 'glCompressedTexSubImage2D']
        self.supported_functions_with_count = ['glBufferData', 'glBufferSubData']

        # Only valid when _with_count is enabled
        self.args_to_ignore_in_js = ['count', 'size']

        # Functions that should have an _ as prefix
        self.functions_with_underscore = [
            'glCreateShader', 'glCreateProgram',
            'glDeleteShader', 'glDeleteProgram',
            'glGetShaderInfoLog', 'glGetProgramInfoLog',
            'glAttachShader', 'glLinkProgram', 'glUseProgram', 'glCompileShader',
            'glGetAttribLocation', 'glGetUniformLocation', 'glGetShaderSource', 'glShaderSource',
            'glValidateProgram',
            'glGetActiveUniform', 'glGetActiveAttrib', 'glGetAttachedShaders',
            'glTexImage2D', 'glTexSubImage2D',
            ]

    #
    # Overriden methods
    #
    def convert_js_to_objc(self, js_type, objc_type):
        if js_type == 'TypedArray':
            if not self._current_typedarray:
                raise Exception("Logic error in GL plugin")
            js_convert = self.args_js_special_type_conversions[js_type][0]
            return js_convert + '( cx, %%(jsval)s, &count, %%(retval)s, %s)' % (self._current_typedarray)
        elif js_type == 'ArrayBufferView':
            if not self._current_typedarray:
                raise Exception("Logic error in GL plugin")
            js_convert = self.args_js_special_type_conversions[js_type][0]
            return js_convert + '( cx, %(jsval)s, &count, %(retval)s)'
        else:
            return super(JSBGenerateFunctions_GL, self).convert_js_to_objc(js_type, objc_type)

    def generate_argument(self, i, arg_js_type, arg_declared_type):
        template = super(JSBGenerateFunctions_GL, self).generate_argument(i, arg_js_type, arg_declared_type)
        if arg_js_type in ['TypedArray', 'ArrayBufferView']:
            template = '\tGLsizei count;\n' + template
        return template

    def generate_function_c_call_arg(self, i, dt):

        if re.match('glUniformMatrix[2-4][fi]v$', self._current_funcname) and i == 0:
            # special case for glUniformMatrix4fv since '1' needs to be added as a second argument
            return 'arg0, 1'

        if self._current_typedarray and dt in self._typedarray_dt:
            ret = ''
            if self._with_count:
                ret += ', count'
            ret += ', (%s*)arg%d ' % (self._current_cast, i)
            return ret
        return super(JSBGenerateFunctions_GL, self).generate_function_c_call_arg(i, dt)

    def convert_function_name_to_js(self, function_name):

        use_underscore = False
        # It is possible to add the "name" parameter in opengl_jsb.ini,
        # but it easier with a plugin

        if function_name in self.functions_with_underscore:
            use_underscore = True
        # elif re.match('gl\S+([1-4])([fi])v$', function_name):
        #     use_underscore = True
        elif re.match('glBind.*$', function_name):
            use_underscore = True

        if use_underscore:
            name = function_name[2].lower() + function_name[3:]
            return "_%s" % name
        return super(JSBGenerateFunctions_GL, self).convert_function_name_to_js(function_name)

    def validate_argument(self, arg):
        if self._current_typedarray:

            # Special case: JS UniformMatrix receives 3 args, while C receives 4. C 'count' should be replaced with '1'
            if re.match('glUniformMatrix[2-4][fi]v$', self._current_funcname) and 'name' in arg and arg['name'] == 'count':
                return (None, None)

            # Skip count, size: ivars for glUniformXXX, glBufferData, etc...
            if self._with_count and 'name' in arg and arg['name'] in self.args_to_ignore_in_js:
                return (None, None)

            # Vector thing
            if arg['type'] == '^i':
                return ('TypedArray', 'TypedArray/Sequence')
            elif arg['type'] == '^v':
                return ('ArrayBufferView', 'ArrayBufferView')
        else:
            # Special case: glVertexAttribPointer
            if self._current_funcname == 'glVertexAttribPointer' and arg['type'] == '^v':
                # Argument is an integer, but cast it as a void *
                return ('i', 'GLvoid*')
            elif self._current_funcname in ['glGetAttribLocation', 'glBindAttribLocation', 'glGetUniformLocation'] and arg['type'] == '*':
                return ('char*', 'char*')

        return super(JSBGenerateFunctions_GL, self).validate_argument(arg)

    def generate_function_binding(self, function):
        func_name = function['name']

        self._current_funcname = func_name
        self._current_typedarray = None
        self._current_cast = 'GLvoid'
        self._with_count = False

        t = None
        # Testing generic vector functions
        r = re.match('gl\S+([1-4])([fi])v$', func_name)
        if r:
            t = 'f32' if r.group(2) == 'f' else 'i32'
            #self._with_count = (re.match('glVertexAttrib[1-4][fi]v', func_name) == None)
        else:
            if func_name in self.supported_functions_without_count:
                t = 'v'
            elif func_name in self.supported_functions_with_count:
                t = 'v'
                self._with_count = True

        if t == 'f32':
            self._current_typedarray = 'js::ArrayBufferView::TYPE_FLOAT32'
            self._current_cast = 'GLfloat'
        elif t == 'i32':
            self._current_typedarray = 'js::ArrayBufferView::TYPE_INT32'
            self._current_cast = 'GLint'
        elif t == 'u8':
            self._current_typedarray = 'js::ArrayBufferView::TYPE_UINT8'
            self._current_cast = 'GLuint8'
        elif t == 'v':
            self._current_typedarray = 'void'
            self._current_cast = 'GLvoid'

        return super(JSBGenerateFunctions_GL, self).generate_function_binding(function)
