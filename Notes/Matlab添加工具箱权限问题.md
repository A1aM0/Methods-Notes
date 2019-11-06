# Matlab添加工具箱遇到的权限问题（Linux-mint 19.2）

> Folder Error: Failed to create folder
>
> or
>
> Access denied: Unable to write to *

在安装Matlab的时候安装路径为默认路径，导致路径为 */usr/local/MATLAB* ，后续想添加工具箱的时候，会出现权限问题，提示如上所示。

运行以下命令添加修改权限：`sudo chown -R $LOGNAME: /usr/local/MATLAB/R2019b/`