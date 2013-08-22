#!/bin/sh

#!/bin/sh

TP="/usr/local/bin/TexturePacker"
#cd ${PROJECT_DIR}/${PROJECT}

if [ "${ACTION}" = "clean" ]; then
echo "cleaning..."

rm -f images/build/*.plist
rm -f images/build/*.pvr.ccz

#rm -f wizard/wizard1*.pvr.ccz
#rm -f Resources/background*.plist

# ....
# add all files to be removed in clean phase
# ....
else
#ensure the file exists
if [ -f "${TP}" ]; then
echo "building..."
# create assets
${TP} --smart-update images/spells-core.tps
${TP} --smart-update images/spells-extra.tps
${TP} --smart-update images/wizard1.tps
${TP} --smart-update images/wizard1-clothes.tps
${TP} --smart-update images/sprites.tps

# ${TP} --smart-update images/Resources/background.tps

# ....
# add other sheets to create here
# ....

exit 0
else
#if here the TexturePacker command line file could not be found
echo "TexturePacker tool not installed in ${TP}"
echo "skipping requested operation."
exit 1
fi

fi
exit 0