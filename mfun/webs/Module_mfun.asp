﻿<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta HTTP-EQUIV="Pragma" CONTENT="no-cache" />
    <meta HTTP-EQUIV="Expires" CONTENT="-1" />
    <link rel="shortcut icon" href="images/favicon.png" />
    <link rel="icon" href="images/favicon.png" />
    <title>软件中心 - MFUN</title>
    <link rel="stylesheet" type="text/css" href="index_style.css" />
    <link rel="stylesheet" type="text/css" href="form_style.css" />
    <link rel="stylesheet" type="text/css" href="css/element.css">
    <link rel="stylesheet" type="text/css" href="/res/softcenter.css">
    <link rel="stylesheet" type="text/css" href="/res/layer/theme/default/layer.css">
    <script type="text/javascript" src="/res/Browser.js"></script>
    <script type="text/javascript" src="/res/softcenter.js"></script>
    <script type="text/javascript" src="/state.js"></script>
    <script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
    <script type="text/javascript" src="/general.js"></script>
    <script type="text/javascript" src="/popup.js"></script>
    <style>
        a:focus {
            outline: none;
        }

        .FormTitle i {
            color: #ff002f;
            font-style: normal;
        }

        .SimpleNote {
            padding: 5px 10px;
        }

        .popup_bar_bg_ks {
            position: fixed;
            margin: auto;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 99;
            /*background-color: #444F53;*/
            filter: alpha(opacity=90);
            /*IE5、IE5.5、IE6、IE7*/
            background-repeat: repeat;
            visibility: hidden;
            overflow: hidden;
            /*background: url(/images/New_ui/login_bg.png);*/
            background: rgba(68, 79, 83, 0.85) none repeat scroll 0 0 !important;
            background-position: 0 0;
            background-size: cover;
            opacity: .94;
        }

        .loadingBarBlock {
            width: 740px;
        }

        .loading_block_spilt {
            background: #656565;
            height: 1px;
            width: 98%;
        }

        #mfun_main {
            border-width: 0.5px;
        }

        /* W3C rogcss */
    </style>
    <script>
        var odm = '<% nvram_get("productid"); %>'
        var lan_ipaddr = "<% nvram_get(lan_ipaddr); %>"
        var params_chk = ['mfun_enable'];
        var params_inp = [];
        var refresh_flag;
        var count_down;

        function init() {
            show_menu(menu_hook);
            get_status();
            get_dbus_data();
            register_event();
            setMfunAddr();
        }

        function register_event() {
            $(".popup_bar_bg_ks").click(
                function () {
                    count_down = -1;
                });
            $(window).resize(function () {
                if ($('.popup_bar_bg_ks').css("visibility") == "visible") {
                    document.scrollingElement.scrollTop = 0;
                    var page_h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
                    var page_w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
                    var log_h = E("loadingBarBlock").clientHeight;
                    var log_w = E("loadingBarBlock").clientWidth;
                    var log_h_offset = (page_h - log_h) / 2;
                    var log_w_offset = (page_w - log_w) / 2 + 90;
                    $('#loadingBarBlock').offset({ top: log_h_offset, left: log_w_offset });
                }
            });
        }

        function get_dbus_data() {
            $.ajax({
                type: "GET",
                url: "/_api/mfun",
                dataType: "json",
                async: false,
                success: function (data) {
                    dbus = data.result[0];
                    conf2obj();
                    register_event();
                }
            });
        }

        function conf2obj() {
            for (var i = 0; i < params_chk.length; i++) {
                if (dbus[params_chk[i]]) {
                    E(params_chk[i]).checked = dbus[params_chk[i]] != "0";
                }
            }
            /*if (dbus["mfun_store"]) {
                E("mfun_feat_store").value = dbus["mfun_store"]
            }*/
            if (dbus["mfun_tmp"]) {
                E("mfun_feat_tmp").value = dbus["mfun_tmp"]
            }
            E("mfun_feat_watch").checked = dbus["mfun_watch"] == "1"
            if (dbus["mfun_port"]) {
                E("mfun_feat_port").value = dbus["mfun_port"]
            }
            E("mfun_feat_open").checked = dbus["mfun_open"] == "1"
        }

        function get_status() {
            var id = parseInt(Math.random() * 100000000);
            var postData = { "id": id, "method": "mfun_status.sh", "params": [1], "fields": "" };
            $.ajax({
                type: "POST",
                cache: false,
                url: "/_api/",
                data: JSON.stringify(postData),
                dataType: "json",
                success: function (response) {
                    if (response.result) {
                        E("mfun_status").innerHTML = response.result;
                        setTimeout("get_status();", 5000);
                    }
                },
                error: function (xhr) {
                    console.log(xhr)
                    setTimeout("get_status();", 15000);
                }
            });
        }

        function save() {
            var dbus_new = {};
            for (var i = 0; i < params_chk.length; i++) {
                dbus_new[params_chk[i]] = E(params_chk[i]).checked ? '1' : '0';
            }
            // dbus_new["mfun_store"] = E("mfun_feat_store").value
            dbus_new["mfun_tmp"] = E("mfun_feat_tmp").value
            dbus_new["mfun_watch"] = E("mfun_feat_watch").checked ? "1" : "0"
            dbus_new["mfun_old_port"] = dbus["mfun_port"]
            dbus_new["mfun_port"] = E("mfun_feat_port").value
            dbus_new["mfun_open"] = E("mfun_feat_open").checked ? "1" : "0"
            E("mfun_apply").disabled = true;
            var id = parseInt(Math.random() * 100000000);
            var postData = { "id": id, "method": "mfun_config.sh", "params": ["web_submit"], "fields": dbus_new };
            $.ajax({
                type: "POST",
                url: "/_api/",
                data: JSON.stringify(postData),
                dataType: "json",
                success: function (response) {
                    E("mfun_apply").disabled = false;
                    get_log();
                }
            });
        }

        function showWBLoadingBar() {
            document.scrollingElement.scrollTop = 0;
            E("loading_block_title").innerHTML = "应用中, 请稍后 ...";
            E("LoadingBar").style.visibility = "visible";
            var page_h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
            var page_w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
            var log_h = E("loadingBarBlock").clientHeight;
            var log_w = E("loadingBarBlock").clientWidth;
            var log_h_offset = (page_h - log_h) / 2;
            var log_w_offset = (page_w - log_w) / 2 + 90;
            $('#loadingBarBlock').offset({ top: log_h_offset, left: log_w_offset });
        }

        function hideWBLoadingBar() {
            E("LoadingBar").style.visibility = "hidden";
            E("ok_button").style.visibility = "hidden";
            if (refresh_flag == "1") {
                refreshpage();
            }
        }

        function count_down_close() {
            if (count_down == "0") {
                hideWBLoadingBar();
            }
            if (count_down < 0) {
                E("ok_button1").value = "手动关闭"
                return false;
            }
            E("ok_button1").value = "自动关闭(" + count_down + ")"
            --count_down;
            setTimeout("count_down_close();", 1000);
        }

        function get_log(flag) {
            E("ok_button").style.visibility = "hidden";
            showWBLoadingBar();
            $.ajax({
                url: '/_temp/mfun_log.txt',
                type: 'GET',
                cache: false,
                dataType: 'text',
                success: function (response) {
                    var retArea = E("log_content");
                    if (response.search("XU6J03M6") != -1) {
                        retArea.value = response.replace("XU6J03M6", " ");
                        E("ok_button").style.visibility = "visible";
                        retArea.scrollTop = retArea.scrollHeight;
                        if (flag == 1) {
                            count_down = -1;
                            refresh_flag = 0;
                        } else {
                            count_down = 6;
                            refresh_flag = 1;
                        }
                        count_down_close();
                        return false;
                    }
                    setTimeout("get_log(" + flag + ");", 200);
                    retArea.value = response.replace("XU6J03M6", " ");
                    retArea.scrollTop = retArea.scrollHeight;
                },
                error: function (xhr) {
                    E("loading_block_title").innerHTML = "暂无日志信息 ...";
                    E("log_content").value = "日志文件为空, 请关闭本窗口!";
                    E("ok_button").style.visibility = "visible";
                    return false;
                }
            });
        }

        function menu_hook(title, tab) {
            tabtitle[tabtitle.length - 1] = new Array("", "MFUN");
            tablink[tablink.length - 1] = new Array("", "Module_mfun.asp");
        }

        function setMfunAddr() {
            E("mfun_website").href = location.origin + ":" + E("mfun_feat_port").value;
        }
    </script>
</head>

<body onload="init();">
    <div id="TopBanner"></div>
    <div id="Loading" class="popup_bg"></div>
    <div id="LoadingBar" class="popup_bar_bg_ks" style="z-index: 200;">
        <table cellpadding="5" cellspacing="0" id="loadingBarBlock" class="loadingBarBlock" align="center">
            <tr>
                <td height="100">
                    <div id="loading_block_title" style="margin:10px auto;margin-left:10px;width:85%; font-size:12pt;">
                    </div>
                    <div id="loading_block_spilt" style="margin:10px 0 10px 5px;" class="loading_block_spilt"></div>
                    <div style="margin-left:15px;margin-right:15px;margin-top:10px;overflow:hidden">
                        <textarea cols="50" rows="25" wrap="off" readonly="readonly" id="log_content" autocomplete="off"
                            autocorrect="off" autocapitalize="off" spellcheck="false"
                            style="border:1px solid #000;width:99%; font-family:'Lucida Console'; font-size:11px;background:transparent;color:#FFFFFF;outline: none;padding-left:3px;padding-right:22px;overflow-x:hidden"></textarea>
                    </div>
                    <div id="ok_button" class="apply_gen" style="background:#000;visibility:hidden;">
                        <input id="ok_button1" class="button_gen" type="button" onclick="hideWBLoadingBar()" value="确定">
                    </div>
                </td>
            </tr>
        </table>
    </div>
    <table class="content" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td width="17">&nbsp;</td>
            <td valign="top" width="202">
                <div id="mainMenu"></div>
                <div id="subMenu"></div>
            </td>
            <td valign="top">
                <div id="tabMenu" class="submenuBlock"></div>
                <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
                    <tr>
                        <td align="left" valign="top">
                            <table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3"
                                class="FormTitle" id="FormTitle">
                                <tr>
                                    <td bgcolor="#4D595D" colspan="3" valign="top">
                                        <div>&nbsp;</div>
                                        <div class="formfonttitle">MFUN<lable id="mfun_version">
                                                <lable>
                                        </div>
                                        <div style="float:right; width:15px; height:25px;margin-top:-20px">
                                            <img id="return_btn" onclick="reload_Soft_Center();" align="right"
                                                style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;"
                                                title="返回软件中心" src="/images/backprev.png"
                                                onMouseOver="this.src='/images/backprevclick.png'"
                                                onMouseOut="this.src='/images/backprev.png'"></img>
                                        </div>
                                        <div style="margin:10px 0 10px 5px;" class="splitLine"></div>
                                        <div class="SimpleNote">
                                            <li>MFUN 轻量影视媒体库</li>
                                            <li style="color: #FC0;">请设置虚拟内存后再使用</li>
                                            <li style="color: #FC0;">初始账号密码: admin password</li>
                                        </div>
                                        <div id="mfun_main">
                                            <table width="100%" border="1" align="center" cellpadding="4"
                                                cellspacing="0" class="FormTable">
                                                <thead>
                                                    <tr>
                                                        <td colspan="2">MFUN 设定</td>
                                                    </tr>
                                                </thead>
                                                <tr id="switch_tr">
                                                    <th>开关</th>
                                                    <td colspan="2">
                                                        <div class="switch_field"
                                                            style="display:table-cell;float: left;">
                                                            <label for="mfun_enable">
                                                                <input id="mfun_enable" class="switch" type="checkbox"
                                                                    style="display: none;">
                                                                <div class="switch_container">
                                                                    <div class="switch_bar"></div>
                                                                    <div class="switch_circle transition_style">
                                                                        <div></div>
                                                                    </div>
                                                                </div>
                                                            </label>
                                                        </div>
                                                        <div style="float: right;margin-top:5px;margin-right:30px;">
                                                            <a type="button" class="ks_btn" href="javascript:void(0);"
                                                                onclick="get_log(1)"
                                                                style="cursor: pointer;margin-left:5px;border:none">查看日志</a>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th>运行状态</th>
                                                    <td><span id="mfun_status"></span></td>
                                                </tr>
                                                <!-- <tr>
                                                    <th>媒体路径(请确保资源全部储存在此目录或其子目录下)<span style="color: red;"> * </span>
                                                    </th>
                                                    <td>
                                                        <input style="width:300px;" type="text" class="input_ss_table"
                                                            id="mfun_feat_store" name="mfun_feat_store" maxlength="100"
                                                            value="" autocorrect="off" autocapitalize="off">
                                                    </td>
                                                </tr> -->
                                                <tr>
                                                    <th>配置及缓存路径<span style="color: red;"> * </span></th>
                                                    <td>
                                                        <input style="width:300px;" type="text" class="input_ss_table"
                                                            id="mfun_feat_tmp" name="mfun_feat_tmp" maxlength="100"
                                                            value="" autocorrect="off" autocapitalize="off">
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th>文件监控</th>
                                                    <td>
                                                        <input type="checkbox" id="mfun_feat_watch"
                                                            style="vertical-align:middle;">
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th>面板 HTTP 端口<span style="color: red;"> * </span></th>
                                                    <td>
                                                        <input style="width:62px;" type="number" class="input_ss_table"
                                                            id="mfun_feat_port" name="mfun_feat_port" value="8990"
                                                            min="1" max="65535">
                                                        <input type="checkbox" id="mfun_feat_open"
                                                            style="vertical-align:middle;" checked>
                                                        <span style="color: #FC0;">开放公网端口</span>
                                                        <!-- <input type="checkbox" id="mfun_feat_ssl"
                                                            style="vertical-align:middle;" checked="true">
                                                        <span style="color: #FC0;">启用 HTTPS</span> -->
                                                    </td>
                                                </tr>
                                                <tr id="mfun_console">
                                                    <th>控制台</th>
                                                    <td>
                                                        <a type="button" id="mfun_website" class="ks_btn" href=""
                                                            target="_blank" style="border:none">控制台</a>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div class="apply_gen">
                                            <input class="button_gen" id="mfun_apply" onClick="save()" type="button"
                                                value="提交" />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
            <td width="10" align="center" valign="top"></td>
        </tr>
    </table>
    <div id="footer"></div>
</body>

</html>