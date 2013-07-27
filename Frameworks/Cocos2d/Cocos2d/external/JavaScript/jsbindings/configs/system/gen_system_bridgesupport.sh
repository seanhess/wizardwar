#!/bin/sh
#
# run this script from chipmunk include directory
# cd cocos2d-iphone/externals/Chipmunk/include/chipmunk
#
gen_bridge_metadata -F complete --no-64-bit -c '-DNDEBUG -I.' *.h -o ../jsbindings/configs/system/system.bridgesupport
