#!/bin/bash

# jailpatch.sh: webOS Developer Mode jail_app.conf patcher
# Copyright 2023. AGPL 3 or later. No warranties. See LICENSE for details.
# https://github.com/throwaway96/install-jail-conf

set -e

tmp='/media/developer/temp'
path='/media/developer'
tmp_conf="${tmp}/jail_app.conf.new"
tmp_sig="${tmp}/jail_app.conf.sig.new"
path_conf="${path}/jail_app.conf"
path_sig="${path}/jail_app.conf.sig"
backup_conf="${tmp}/jail_app.conf.orig"
backup_sig="${tmp}/jail_app.conf.sig.orig"

hash_md5() {
    md5sum -- "${1}" | cut -d ' ' -f 1
}

get_sdkversion() {
    luna-send-pub -w 10000 -n 1 -q 'sdkVersion' 'luna://com.webos.service.tv.systemproperty/getSystemInfo' '{"keys":["sdkVersion"]}' | sed -n -e 's/^\s*"sdkVersion":\s*"\([0-9.]\+\)"\s*$/\1/p'
}

check_tmp() {
    if [ ! -d "${tmp}" ]; then
    	echo '*** error: temp dir does not exist'
    	exit 1
    elif [ ! -w "${tmp}" ]; then
    	echo '*** error: temp dir not writable'
    	exit 1
    fi
}

check_files() {
    if [ ! -f "${path_conf}" ]; then
        echo "*** error: jail_app.conf (${path_conf}) not found"
        exit 1
    elif [ ! -f "${path_sig}" ]; then
        echo "*** warning: jail_app.conf.sig (${path_sig}) not found"
    fi
}

check_writable() {
    if [ ! -w "${path_conf}" ]; then
        echo "*** error: jail_app.conf (${path_conf}) not writable"
        echo "*** your Dev Mode app is probably patched; see https://gist.github.com/throwaway96/e811b0f7cc2a705a5a476a8dfa45e09f#service-20240402"
        echo "*** if it's not, then you didn't reboot properly"
        exit 1
    elif [ ! -w "${path_sig}" ]; then
        echo "*** error: jail_app.conf.sig (${path_sig}) not writable"
	exit 1
    fi
}

check_sdkversion() {
    ver="$(get_sdkversion)"

    echo "*** webOS version: ${ver}"

    major_ver="$(echo "${ver}" | cut -d '.' -f 1)"

    if [ "${major_ver}" -lt 4 ]; then
        echo '*** error: crashd does not work on webOS < 4!'
        exit 1
    fi
}

check_current() {
    if verify_sig "${path_conf}" "${path_sig}"; then
	    echo '*** verification of current conf successful'
    else
    	echo '*** verification of current conf failed. do not reboot unless fixed'
    fi
}

backup_files() {
    if [ ! -f "${backup_conf}" ]; then
    	echo '*** backing up jail_app.conf'
    	cp "${path_conf}" "${backup_conf}"
    else
        echo '*** jail_app.conf backup already exists'
    fi

    if [ ! -f "${backup_sig}" ]; then
    	echo '*** backing up jail_app.conf.sig'
    	cp "${path_sig}" "${backup_sig}"
    else
        echo '*** jail_app.conf.sig backup already exists'
    fi
}

md5_4='410cb71a593449bcaccf000134592c87'
md5_5='5d7600be24998f1fb2d07fc52add55f9'
md5_6='c3e565cd828ab97ab9957c5252f34b55'
md5_7='032f5777ec3a35db01d64e43678c03e5'
md5_t='032d779de16b537f4517a895d54058e3'

verify_sig() {
    openssl smime -verify -noverify -inform pem -in "${2}" -content "${1}" >/dev/null 2>&1
}

confirm_target() {
    printf "%s  %s\n" "${md5_t}" "${1}" | md5sum -c >/dev/null 2>&1
}

sig_data='H4sIAAAAAAAAAzNoYpnIxqnV5tH2nZeRnWlBE0uTQRNLHRMjoyG3AScbqzYfM5MUK4MBN0IR44Im
pgqDJqYSgybGuwuYmRiZmDgZ/jhcDdLZZPXPgBeukJEVqC8YbAxzKAubMJN3kKGwgSCIw8HDFZyf
m6obXJJYkmrIZ8ADEmTnYQ1OzS/NMeQx4ALxuXiYfdxdDQUN+EE8Zh6O4tTk0qLMkkoDOXFeQ1ND
A0MLI2MTM1PzKHFeYxDXGMqljaWN85H9xsjKwNzYy2DQ2MnU2MiwoW2S/dyPL80zloWds7pUc+r9
y/A9U1JOMZTv3TWzX5kp7pjqc/E3Me9ZisI19iuqbK9Y9O58wrm7Xq+OdX2N3/96doKo4YsFD2pW
9bSYr1oTpHFDLHHxYv1Gzj73/lMrtFtMZnzinfy5/TajEOOVFb/+Jahe5Zm8du4hxqrZc6vmcpwx
O1+VyMTMyMC4OMDAz0AW6GxZPhYxFpEH196JnL10ujF8tWj/u5TPZc3rPz83kAdJK7NIGIg1YFcA
ChRZYRZWA2ZGxv9okckM9KkX19VTaXJv1r5iCn01d8XaF7aLtv9tYKuXlTtpZ3361nWdORsatITn
fZqXpql0d+NqywfPv+vtXXFH6qgT74NpieE9Heb/qrauvf6R79fZWMG01A9xUyV2PBMVVmCqEzLy
Y5y6+eccn0d9v1x+suSqKzUZfvr1ubZmhtSlnOusW+Y8P5PQtEvNsInxISjdAROoQQJNIho5MSMy
wILGGwYS8NDgZDZEzhAGMggZVkN+cV4jQwMLIxMDMxMTE4soA2WELIshMGaCGHf9+CZ4ceJ3yXkl
L1kbfPkl+BcaVCIU8RvmGGSBclxCmwdjKjMLoxYyRwyZwwT0DAdEHzO7AR+czcTExNAAjD4En9HB
gB3iG3ZUcQ20ZM3S2MD2/6D2yfVX61ZrTUybLLhY1DxP+soav+Pf70gbnXkYuni9tsT29JnbGTdv
2sn8Iajl8aZrDwz1pU4XFjtnZ99kfO3gOsf9UPWHg5rzVZgmz9qyr3TJFCf+WcoO/7+dfO5mMPt3
j0eWfO75btUDL7fM1A31YfR3WD8jMXnVb8e3Qoq/hE93fl4MAAaoms2VBAAA'

write_sig() {
    fmt="-----%s PKCS7-----\n"
    printf "${fmt}" 'BEGIN' >"${1}"
    echo "${sig_data}" | base64 -d | gzip -d | base64 | tr -d '\n' | sed -e 's/.\{64\}/&\n/g' -e 's/$/\n/' >>"${1}"
    printf "${fmt}" 'END' >>"${1}"
}

l1='\mount rw /var/log/crashd'

l2='\	\
	copynod /dev/video20\
	chmod 660 /dev/video20\
	chown /dev/video20 0 44'

l3='\		\
		#chrome, native app crash\
                copynod /dev/dma_buf_te\
                chown /dev/dma_buf_te 0 5000\
                chmod 660 /dev/dma_buf_te\
\
                #GAV demo\
                copynod /dev/ump\
                chmod 660 /dev/ump\
                chown /dev/ump 0 44\
		\
		# cloud game\
                copynod /dev/mma\
                chown /dev/mma 0 5000\
                chmod 660 /dev/mma\
\
                copynod /dev/video28\
                chmod 660 /dev/video28\
                chown /dev/video28 0 44'

l4='\	\
    copynod /dev/dri/card0\
    chmod 666 /dev/dri/card0\
    chown /dev/dri/card0 0 5000\
    \
    copynod /dev/dri/card1\
    chmod 666 /dev/dri/card1\
    chown /dev/dri/card1 0 5000\
    \
    copynod /dev/dri/controlD64 \
    chmod 666 /dev/dri/controlD64 \
    chown /dev/dri/controlD64  0 5000\
    \
    copynod /dev/dri/renderD128\
    chmod 666 /dev/dri/renderD128\
    chown /dev/dri/renderD128 0 5000\
    \
    copynod /dev/pvr_sync\
    chmod 666 /dev/pvr_sync\
    chown /dev/pvr_sync 0 5000'

sed4="2y/5/9/
51a${l1}
72i${l2}
214,216c
319,321d
322i${l3}
483c${l4}"

sed5="51a${l1}
321,323d
324i${l3}
485c${l4}"

sed6="44d
52a${l1}
502c${l4}"

sed7="51a${l1}"

patch() {
    sed -e "${1}" -- "${path_conf}" >"${tmp_conf}"

    if ! confirm_target "${tmp_conf}"; then
        echo "*** patching failed. result is not correct"
        exit 1
    fi
}

echo '****** jailpatch.sh from https://github.com/throwaway96/install-jail-conf'
echo '*** for instructions, see https://gist.github.com/throwaway96/e811b0f7cc2a705a5a476a8dfa45e09f'

check_tmp
check_files
check_sdkversion

backup_files

jhash="$(hash_md5 "${path_conf}")"

echo "*** current hash: ${jhash}"

if [ "${jhash}" == "${md5_t}" ]; then
    echo "*** correct jail_app.conf already present. not patching."
    check_current
    exit 0
fi

check_writable

case "${jhash}" in
"${md5_4}")
    echo "*** found version 4, patching..."
    patch "${sed4}"
    ;;
"${md5_5}")
    echo "*** found version 5, patching..."
    patch "${sed5}"
    ;;
"${md5_6}")
    echo "*** found version 6, patching..."
    patch "${sed6}"
    ;;
"${md5_7}")
    echo "*** found version 7, patching..."
    patch "${sed7}"
    ;;
*)
    echo "*** error: unknown version. please save your jail_app.conf and jail_app.conf.sig and seek support"
    exit 1
    ;;
esac

write_sig "${tmp_sig}"

if verify_sig "${tmp_conf}" "${tmp_sig}"; then
    echo "*** patched signature verified"
	echo '*** overwriting...'
	cat "${tmp_conf}" >"${path_conf}"
	cat "${tmp_sig}" >"${path_sig}"
	sync -f "${path_conf}"
	echo '*** done overwriting'
else
    echo "*** signature verification failed"
    check_current
    exit 1
fi

check_current
