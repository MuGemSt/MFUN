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

dbus remove mfun_enable
dbus remove mfun_tmp
dbus remove mfun_watch
dbus remove mfun_old_port
dbus remove mfun_port
dbus remove mfun_open
