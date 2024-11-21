#!/bin/sh

source /koolshare/scripts/base.sh
eval $(dbus export mfun)
LOG_FILE=/tmp/upload/mfun_log.txt
LOCK_FILE=/var/lock/mfun.lock
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

set_lock() {
	exec 1000>"$LOCK_FILE"
	flock -x 1000
}

unset_lock() {
	flock -u 1000
	rm -rf "$LOCK_FILE"
}

sync_ntp() {
	echo_date "尝试从 ntp 服务器: ntp1.aliyun.com 同步时间..."
	ntpclient -h ntp1.aliyun.com -i3 -l -s >/tmp/ali_ntp.txt 2>&1
	SYNC_TIME=$(cat /tmp/ali_ntp.txt | grep -E "\[ntpclient\]" | grep -Eo "[0-9]+" | head -n1)
	if [ -n "${SYNC_TIME}" ]; then
		SYNC_TIME=$(date +%Y/%m/%d-%X @${SYNC_TIME})
		echo_date "完成!时间同步为: ${SYNC_TIME}"
	else
		echo_date "时间同步失败, 跳过!"
	fi
}

fun_wan_start() {
	if [ "${mfun_enable}" == "1" ]; then
		if [ ! -L "/koolshare/init.d/M71mfun.sh" ]; then
			echo_date "添加开机启动..."
			ln -sf /koolshare/scripts/mfun_config.sh /koolshare/init.d/M71mfun.sh
		fi
	else
		if [ -L "/koolshare/init.d/M71mfun.sh" ]; then
			echo_date "删除开机启动..."
			rm -rf /koolshare/init.d/M71mfun.sh >/dev/null 2>&1
		fi
	fi

	if [ ! -z $old_mfun_port ] && [ $old_mfun_port != $mfun_port ]; then
		iptables -D INPUT -p tcp --dport "$old_mfun_port" -j ACCEPT
	fi
}

fix_path() {
	for dir in /mnt/*/; do
		if [ -d "$dir" ]; then
			sub=$(echo "$1" | cut -d'/' -f4-)
			if [ ! -z $sub ] && [ -d "$dir$sub" ]; then
				echo "$dir$sub"
			fi
		fi
	done
}

fix_db_path() {
	fixed_tempath=$(fix_path $1)
	db_dir="$fixed_tempath/db"
	if [ -d $fixed_tempath ] && [ -d $db_dir ]; then
		prodb=$db_dir/products.db
		dbpath=$db_dir/db.db
		if [ -f $prodb ] && [ -f $dbpath ]; then
			products=$(sqlite3 $prodb "SELECT path FROM m_product WHERE path LIKE '/mnt/%';")
			echo "$products" | while IFS= read -r line; do
				fixed_path=$(fix_path $line)
				if [ $fixed_path != $line ] && [ ! -z $fixed_path ]; then
					sqlite3 $prodb "UPDATE m_product SET path='$fixed_path' WHERE path='$line';"
				fi
			done

			videos=$(sqlite3 $dbpath "SELECT path FROM m_media WHERE path LIKE '/mnt/%';")
			echo "$videos" | while IFS= read -r line; do
				fixed_path=$(fix_path $line)
				if [ $fixed_path != $line ] && [ ! -z $fixed_path ]; then
					sqlite3 $dbpath "UPDATE m_media SET path='$fixed_path' WHERE path='$line';"
				fi
			done

			songs=$(sqlite3 $dbpath "SELECT path m_music_list_data WHERE path LIKE '/mnt/%';")
			echo "$songs" | while IFS= read -r line; do
				fixed_path=$(fix_path $line)
				if [ $fixed_path != $line ] && [ ! -z $fixed_path ]; then
					sqlite3 $dbpath "UPDATE m_music_list_data SET path='$fixed_path' WHERE path='$line';"
				fi
			done
		fi
	fi

	echo $fixed_tempath
}

start_mfun() {
	# 检查入参
	if [[ -z $mfun_port ]]; then
		close_in_five "请输入有效端口号!"
	fi
	if [[ -z $mfun_tmp ]]; then
		close_in_five "请输入有效配置缓存路径!"
	fi

	if [ ! -d $mfun_tmp ]; then
		# 自动修复盘符
		echo_date "检查媒体库..."
		fixed_mfun_tmp=$(fix_db_path $mfun_tmp)
		if [ "$mfun_tmp" != "$fixed_mfun_tmp" ] && [ -d $fixed_mfun_tmp ]; then
			dbus set mfun_tmp="$fixed_mfun_tmp"
			mfun_tmp=$fixed_mfun_tmp
			echo_date "配置缓存路径已自动修复!"
		else
			close_in_five "请输入有效配置缓存路径!"
		fi
	fi

	# 插件开启的时候同步一次时间
	if [ "${mfun_enable}" == "1" -a -n "$(which ntpclient)" ]; then
		sync_ntp
	fi

	echo_date "启动 MFUN 主程序..."
	export GOGC=40
	cd /koolshare/bin
	if [ "${mfun_watch}" == "1" ]; then
		./mfun --store="$mfun_tmp" --tmp="$mfun_tmp" --port="$mfun_port" --watch >/dev/null 2>&1 &
	else
		./mfun --store="$mfun_tmp" --tmp="$mfun_tmp" --port="$mfun_port" >/dev/null 2>&1 &
	fi
	sleep 1
	local SDPID
	local i=10
	until [ -n "$SDPID" ]; do
		i=$(($i - 1))
		SDPID=$(pidof mfun)
		if [ "$i" -lt 1 ]; then
			echo_date "MFUN 进程启动失败!"
			close_in_five "可能是内存不足造成的, 建议使用虚拟内存后重试!"
		else
			echo_date "正在等待 MFUN 主程序启动 ..."
		fi
		usleep 500000
	done
	echo_date "MFUN 启动成功, pid: ${SDPID}"

	# 开放 http 端口用于内网穿透
	iptables -D INPUT -p tcp --dport "$mfun_port" -j ACCEPT
	if [ "${mfun_open}" == "1" ]; then
		iptables -I INPUT -p tcp --dport "$mfun_port" -j ACCEPT
		echo_date "已开放公网 HTTP 端口 ${mfun_port} !"
	else
		echo_date "仅可访问控制台 HTTP 端口 ${mfun_port} ..."
	fi

	echo_date "MFUN 插件启动完毕, 本窗口将在 5s 内自动关闭!"
}

close_in_five() {
	echo_date $1
	dbus set mfun_enable=0
	echo_date "插件将在5秒后自动关闭!!"
	local i=5
	while [ $i -ge 0 ]; do
		sleep 1
		echo_date $i
		let i--
	done
	stop
	echo_date "插件已关闭!!"
	unset_lock
	exit
}

stop() {
	# 关闭 mfun 进程
	if [ -n "$(pidof mfun)" ]; then
		echo_date "停止 MFUN 主进程, pid: $(pidof mfun)"
		killall mfun >/dev/null 2>&1
		echo_date "关闭端口..."
		iptables -D INPUT -p tcp --dport "$mfun_port" -j ACCEPT
	fi

	fun_wan_start
}

case $1 in
start)
	set_lock
	if [ "${mfun_enable}" == "1" ]; then
		logger "[软件中心]: 启动 MFUN !"
		start_mfun
	fi
	unset_lock
	;;
restart)
	set_lock
	if [ "${mfun_enable}" == "1" ]; then
		stop
		start_mfun
	fi
	unset_lock
	;;
stop)
	set_lock
	stop
	unset_lock
	;;
esac

case $2 in
web_submit)
	set_lock
	true >$LOG_FILE
	http_response "$1"
	if [ "${mfun_enable}" == "1" ]; then
		stop | tee -a $LOG_FILE
		start_mfun | tee -a $LOG_FILE
	else
		stop | tee -a $LOG_FILE
		echo_date "MFUN 已经停止运行, 本窗口将再 5s 后关闭!" | tee -a $LOG_FILE
	fi
	echo XU6J03M6 | tee -a $LOG_FILE
	unset_lock
	;;
esac

# 重启自启其它变量初始化
mfun_enable=$(dbus get mfun_enable)
if [ "$mfun_enable" == "1" ] && [ ! -n "$(pidof mfun)" ]; then
	mfun_watch=$(dbus get mfun_watch)
	mfun_port=$(dbus get mfun_port)
	mfun_open=$(dbus get mfun_open)
	mfun_tmp=$(dbus get mfun_tmp)
	# 开启 MFUN
	start_mfun | tee -a $LOG_FILE
	echo XU6J03M6 | tee -a $LOG_FILE
fi
