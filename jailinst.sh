#!/bin/sh

set -e

url_conf='https://www.example.com/jail_app.conf'
url_sig='https://www.example.com/jail_app.conf.sig'
tmp='/media/developer/tmp'
path='/media/developer'
tmp_conf="${tmp}/jail_app.conf.new"
tmp_sig="${tmp}/jail_app.conf.sig.new"
path_conf="${path}/jail_app.conf"
path_sig="${path}/jail_app.conf.sig"
backup_conf="${tmp}/jail_app.conf.orig"
backup_sig="${tmp}/jail_app.conf.sig.orig"

if [ ! -f "${backup_conf}" ]; then
	echo '*** backing up conf'
	cp "${path_conf}" "${backup_conf}"
fi

if [ ! -f "${backup_sig}" ]; then
	echo '*** backing up sig'
	cp "${path_sig}" "${backup_sig}"
fi

echo '*** downloading files...'

curl -L -o "${tmp_conf}" "${url_conf}"
curl -L -o "${tmp_sig}" "${url_sig}"

echo '*** download complete'

if openssl smime -verify -noverify -inform pem -in "${tmp_sig}" -content "${tmp_conf}" >/dev/null 2>&1; then
	echo '*** overwriting...'
	cat "${tmp_conf}" >"${path_conf}"
	cat "${tmp_sig}" >"${path_sig}"
	sync -f "${path_conf}"
	echo '*** done overwriting'
else
	echo '*** verification of downloaded files failed. not overwriting'
fi

if openssl smime -verify -noverify -inform pem -in "${path_sig}" -content "${path_conf}" >/dev/null 2>&1; then
	echo '*** verification of current conf successful'
else
	echo '*** verification of current conf failed. do not reboot unless fixed'
fi
