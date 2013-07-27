#!/usr/bin/python
# ----------------------------------------------------------------------------
# Plugin to generate better enums for cocos2d
#
# Author: Ricardo Quesada
# Copyright 2013 (C) Zynga, Inc
#
# License: MIT
# ----------------------------------------------------------------------------
'''
Plugin to generate better enums for cocos2d
'''

__docformat__ = 'restructuredtext'


# python modules
import re

# plugin modules
from generate_jsb import JSBGenerateConstants, JSBGenerateFunctions, JSBGenerateClasses


#
#
# Plugin to generate better constants for cocos2d
#
#
class JSBGenerateConstants_CC(JSBGenerateConstants):

    def get_name_for_constant(self, name):
        ok = False
        if name.startswith('kCC'):
            name = name[3:]
            ok = True

        if name.startswith('CC'):
            name = name[2:]
            ok = True

        if ok:
            n = []
            array = re.findall('[A-Z][^A-Z]*', name)
            if array and len(array) > 0:
                prev = ''
                prev_e_len = 0
                for e in array:
                    e = e.upper()
                    # Append all single letters together
                    if re.match('[A-Z][_0-9]?$', e) and len(n) >= 1 and prev_e_len == 1:
                        prev = prev + e
                        n[-1] = prev
                    else:
                        n.append(e)
                        prev = e
                    prev_e_len = len(e)
            name = '_'.join(n)
            name = name.replace('__', '_')
        else:
            name = None

        return name


#
#
# OpenGL ES 2.0 / WebGL function plugin
#
#
class JSBGenerateFunctions_CC(JSBGenerateFunctions):

    def convert_function_name_to_js(self, function_name):

        if function_name.startswith('ccGL'):
            return 'gl' + function_name[4:]
        return super(JSBGenerateFunctions_CC, self).convert_function_name_to_js(function_name)


#
#
# OpenGL ES 2.0 / WebGL function plugin
#
#
class JSBGenerateClasses_CC(JSBGenerateClasses):

    def __init__(self, config):
        super(JSBGenerateClasses_CC, self).__init__(config)

        # Extend supported types
        self.args_js_special_type_conversions['cc_fontdef'] = ['JSB_jsval_to_CCFontDefinition', 'CCFontDefinition*']
        self.supported_declared_types['CCFontDefinition*'] = 'cc_fontdef'

    #
    # Overriden methods
    #
    def validate_argument(self, arg):
        # Treat GLchar* as null-terminated char*
        if arg['declared_type'] == 'GLchar*' or arg['declared_type'] == 'char*' or arg['declared_type'] == 'char*':
            return ('char*', 'char*')
        # if arg['declared_type'] == 'CCFontDefinition*':
        #     return ('cc_fontdef','CCFontDefinition')

        return super(JSBGenerateClasses_CC, self).validate_argument(arg)

    def convert_js_to_objc(self, js_type, objc_type):
        # print js_type, objc_type
        return super(JSBGenerateClasses_CC, self).convert_js_to_objc(js_type, objc_type)


