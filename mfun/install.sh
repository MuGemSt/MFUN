#!/bin/sh
source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
DIR=$(
	cd $(dirname $0)
	pwd
)
module=mfun
ROG_86U=0
BUILDNO=$(nvram get buildno)
EXT_NU=$(nvram get extendno)
EXT_NU=$(echo ${EXT_NU%_*} | grep -Eo "^[0-9]{1,10}$")
[ -z "${EXT_NU}" ] && EXT_NU="0"
odmpid=$(nvram get odmpid)
productid=$(nvram get productid)
[ -n "${odmpid}" ] && MODEL="${odmpid}" || MODEL="${productid}"
LINUX_VER=$(uname -r | awk -F"." '{print $1$2}')

# 获取固件类型
_get_type() {
	local FWTYPE=$(nvram get extendno | grep koolshare)
	if [ -d "/koolshare" ]; then
		if [ -n "${FWTYPE}" ]; then
			echo "koolshare官改固件"
		else
			echo "koolshare梅林改版固件"
		fi
	else
		if [ "$(uname -o | grep Merlin)" ]; then
			echo "梅林原版固件"
		else
			echo "华硕官方固件"
		fi
	fi
}

exit_install() {
	local state=$1
	case $state in
	1)
		echo_date "本插件适用于【koolshare 梅林改/官改 hnd/axhnd】固件平台!"
		echo_date "你的固件平台不能安装!!!"
		echo_date "本插件支持机型/平台: https://github.com/koolshare/rogsoft#rogsoft"
		echo_date "退出安装!"
		rm -rf /tmp/${module}* >/dev/null 2>&1
		exit 1
		;;
	0 | *)
		rm -rf /tmp/${module}* >/dev/null 2>&1
		exit 0
		;;
	esac
}

# 判断路由架构和平台: koolshare固件, 并且linux版本大于等于4.1
if [ -d "/koolshare" -a -f "/usr/bin/skipd" -a "${LINUX_VER}" -ge "41" ]; then
	echo_date 机型: ${MODEL} $(_get_type) 符合安装要求, 开始安装插件!
else
	exit_install 1
fi

# 判断固件UI类型
if [ -n "$(nvram get extendno | grep koolshare)" -a "$(nvram get productid)" == "RT-AC86U" -a "${EXT_NU}" -lt "81918" -a "${BUILDNO}" != "386" ]; then
	ROG_86U=1
fi

if [ "${MODEL}" == "GT-AC5300" -o "${MODEL}" == "GT-AX11000" -o "${MODEL}" == "GT-AX11000_BO4" -o "$ROG_86U" == "1" ]; then
	# 官改固件, 骚红皮肤
	ROG=1
fi

if [ "${MODEL}" == "TUF-AX3000" ]; then
	# 官改固件, 橙色皮肤
	TUF=1
fi

# 安装插件
cp -rf /tmp/mfun/bin/* /koolshare/bin/
cp -rf /tmp/mfun/scripts/* /koolshare/scripts/
cp -rf /tmp/mfun/webs/* /koolshare/webs/
cp -rf /tmp/mfun/res/* /koolshare/res/
cp -rf /tmp/mfun/uninstall.sh /koolshare/scripts/uninstall_mfun.sh

if [ "$ROG" == "1" ]; then
	echo_date "安装ROG皮肤!"
	continue
else
	if [ "$TUF" == "1" ]; then
		echo_date "安装TUF皮肤!"
		sed -i 's/3e030d/3e2902/g;s/91071f/92650F/g;s/680516/D0982C/g;s/cf0a2c/c58813/g;s/700618/74500b/g;s/530412/92650F/g' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
	else
		echo_date "安装ASUSWRT皮肤!"
		sed -i '/rogcss/d' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
	fi
fi
chmod 755 /koolshare/bin/mfun
chmod +x /koolshare/scripts/mfun*
chmod +x /koolshare/scripts/uninstall_mfun.sh

# 离线安装用
dbus set mfun_version="$(cat $DIR/version)"
dbus set softcenter_module_mfun_version="$(cat $DIR/version)"
dbus set softcenter_module_mfun_description="轻量影视媒体库"
dbus set softcenter_module_mfun_install="1"
dbus set softcenter_module_mfun_name="mfun"
dbus set softcenter_module_mfun_title="MFUN"

# 完成
echo_date "MFUN插件安装完毕!"
exit_install
