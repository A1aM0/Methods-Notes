# Ubuntu 系统下编译 Boost

> 我的环境：
> 
> Linux-Mint 18.3 下编译 Boost 1.69.0
> 
> 编译其他版本的 boost 只需要改版本号就行

1. [Boost 官网](https://www.boost.org/)下载源码

2. 解压 tar.gz 到当前文件夹，`tar -xvf boost_1_69_0.tar.gz`

3. `cd boost_1_69_0/`

4. 加权限 `chmod 777 bootstrap.sh`

5. `./bootstrap.sh --with-libries=all --with-toolset=gcc`

6. `./b2 toolset=gcc`

7. `sudo ./b2 install`

    - 完成后会有以下提示
        > ...failed updating 54 targets... \
        > ...skipped 6 targets... \
        > ...updated 14831 targets...

8. 重启

