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
