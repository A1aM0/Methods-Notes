# Ubuntu 系统下编译 OpenCV

> 我的环境：
> 
> Linux-Mint 18.3 下编译 OpenCV 4.1.0
> 
> 编译其他版本的 OpenCV 只需要改版本号就行

1. <a href="https://opencv.org/" target="_blank"> OpenCV 官网 </a> 下载源码

2. 解压源码，进入解压后的文件夹 `cd opencv-4.1.0/`

3. 安装依赖项
```
sudo apt-get install build-essential
sudo apt-get install cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
```

4. `mkdir build`

5. 进入 build 文件夹，`cd build`

6. `cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local ..`

7. `make -j n` 
    > n 表示构建时利用处理器线程数

8. `sudo make install`

9. 重启

---
### 可能遇到的问题：

1. 第6步cmake的时候，可能因为墙的原因在安装OpenCV的IPP加速库卡住

    `IPPICV: Download: ippicv_2019_lnx_intel64_general_20180723.tgz`  然后就没有然后了......

    > Tips：OpenCV可以利用Intel的IPP性能库来提升程序的运行速度，而这个IPP库是要另外进行购买的。实际上，Intel为当前的OpenCV免费提供了IPP加速库的一部分，在此我们称之为ippcv。ippcv会在cmake的时候自动从github上下载，但是在网络状况不佳的情况下会下载失败。

    解决方法是手动下载，在cmake的时候把路径链接过去即可
        
        1)  直接访问OpenCV在Github上的opencv_3rdparty可以找到文件的具体地址https://github.com/opencv/opencv_3rdparty
        2)  选择正确的分支即可。
        3)  我在写这些的时候，最新的分支是 ippicv/master_20180723，https://github.com/opencv/opencv_3rdparty/tree/ippicv/master_20180723

    改cmake链接，在 `$${你的OpenCV路径}/3rdparty/ippicv` 文件夹下的  ippicv.cmake 文件中，第47行，将 file 的路径改为 `file:$${下载IPP加速库所在的位置}`，例如我所下载的位置 `file:~/Library/` 

    然后再重新进行第6步即可
