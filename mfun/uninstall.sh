#!/bin/sh
source /koolshare/scripts/base.sh

rm -rf /koolshare/bin/mfun
rm -rf /koolshare/bin/mfun*
rm -rf /koolshare/bin/scripts
rm -rf /koolshare/res/icon-mfun.png
rm -rf /koolshare/scripts/mfun*
rm -rf /koolshare/webs/Module_mfun.asp
rm -rf /tmp/mfun*

dbus remove mfun_version
dbus remove softcenter_module_mfun_version
dbus remove softcenter_module_mfun_description
dbus remove softcenter_module_mfun_install
dbus remove softcenter_module_mfun_name
dbus remove softcenter_module_mfun_title
