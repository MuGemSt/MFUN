# MFUN 轻量影视媒体库 (梅林固件优化版)
[![license](https://img.shields.io/github/license/MuGemSt/MFUN.svg)](https://github.com/MuGemSt/MFUN/blob/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/MuGemSt/MFUN.svg)](https://github.com/MuGemSt/MFUN/releases/latest)

The MFUN plugin on Merlin, **my version supports intranet tunneling**:
![](https://foruda.gitee.com/images/1732332422663431272/c29bc93a_14243051.png)

## Environment
Install [7-zip](https://www.7-zip.org/download.html) and add it to environment variables, install Python 3.9+ on Windows 10

## Remove CRLFs caused by Windows
(If happens at the first time of cloning into windows local)<br>
Open Git Bash here:
```bash
sh rm_crlf.sh
```

The following issue is generally caused by CRLFs:
![](https://foruda.gitee.com/images/1731801932932166111/6277aeab_14243051.png)

### Git cfg solution
```bash
git config --global core.safecrlf false
```

## Build on Windows
```bash
python build.py
```

## Usage
1. Access high-capacity hard disks outside the router
2. Install `USB2JFFS` plugin and mount the virtual memory on an external hard disk
3. Assume the path of the mounted disk with videos is `/mnt/sda`, your videos are in `/mnt/sda/videos` while the temp dir is `/mnt/sda/tmp`, you can assign `/mnt/sda/tmp` as both `配置路径` and `缓存路径` to fill in required blanks on the MFUN plugin panel of `Software Center`
4. Open `控制台` to login with default username and pass and customize them
5. Switch to `媒体库 - 媒体库管理`, click `添加媒体库` to add videos into the media lib, don't forget to assign `所属用户`
6. If you want meta-data function work, the workaround is to rename your videos ensuring their filename can pinpoint movies and TVs in [TMDB](https://www.themoviedb.org), you can try to search for movies and TVs by keyword, if the result is one and only, just rename the video to this keyword

## Future work
Support HTTPS intranet tunneling

## Thanks
[1] <https://github.com/Carseason/rogsoft_mfun><br>
[2] <https://rogsoft.ddnsto.com/mfun/mfun.tar.gz>