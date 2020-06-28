# 升级 gcc / g++ 到最新版本（7.4）

安装了 Linux-Mint 18.3（基于 Ubuntu 16.04）才发现，gcc 版本是5.3，然后本身正常的项目会报各种奇妙的 bug ，所以得还是需要升级到新的版本，起码项目之前是在新版本下（7.4）开发的。但 Ubuntu 16.04 软件库里最新的 gcc 就是 5.3 的，所以得通过添加 PPA 手动升级。

```
sudo apt-get install -y software-properties-common
sudo apt-add-repository ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt install g++-7 -y
```

然后运行以下命令，更新
```
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-7
sudo update-alternatives --config gcc
```

告一段落，可以通过 `gcc --version` 或 `g++ --version` 来查看 gcc 的版本号
