#!/bin/bash
# vasilisc 2019-2022
# version 0.3

# variables
WINEPRFX="${HOME}/.wine"
NEED_EXT="asm"
output="REGEDIT4"$'\n'$'\n'
# end variables

# check
if [ ! -d "${WINEPRFX}" ]; then
    echo "There is no such WINE prefix ${WINEPRFX}"
    exit
fi
# end check

# create backup reg
cp -f "${WINEPRFX}/system.reg" "${WINEPRFX}/system.reg.bak"
cp -f "${WINEPRFX}/user.reg" "${WINEPRFX}/user.reg.bak"
cp -f "${WINEPRFX}/userdef.reg" "${WINEPRFX}/userdef.reg.bak"
# end backup

# create script
mkdir -p ${HOME}/bin/

cat > "${HOME}/bin/run_linux_app" <<-'_RUN_LINUX_APP_SCRIPT'
#!/bin/bash
open "$(winepath --unix "$1")"
_RUN_LINUX_APP_SCRIPT

chmod a+x "${HOME}/bin/run_linux_app"
winpath2script=$(winepath --windows "${HOME}/bin/run_linux_app")
#echo ${winpath2script}
command="${winpath2script//\\/\\\\} \\\"%1\\\""
#echo ${command}
# end create script

# create reg file
for ext in ${NEED_EXT}; do
    #echo ${ext}
    output+="[HKEY_CLASSES_ROOT\\.${ext}]"$'\n'
    output+="@=\"UniversalHandlerW2L\""$'\n\n'
done

output+="[HKEY_CLASSES_ROOT\\UniversalHandlerW2L\\shell\\open\\command]"$'\n'
output+="@=\"${command}\""$'\n'
output+=$'\n'

printf '%s' "$output" > "${HOME}/bin/dump.reg"

env WINEPREFIX="${WINEPRFX}" wine regedit "${HOME}/bin/dump.reg"
rm -f "${HOME}/bin/dump.reg"
# end reg file

exit 0
