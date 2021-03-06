# CRC校验

po一下概念：循环冗余校验（Cyclic Redundancy Check，CRC），是一种根据网络数据包或计算机文件等数据产生简短固定位数校验码的一种信道编码技术，主要用来检测或校验数据传输或者保存后可能出现的错误。

简单来说，一段“01”比特流经过通信链路从发送端发送到接收端接收，过程中可能会发生比特差错，当接收端经过CRC校验发现差错后，可以直接将这段数据抛弃，并要求发送端重新发送。

## 发送过程

- 设发送端将要发送数据 $10101011$（D8~D1），将发送的数据视作**被除数**；
- 既然有被除数了，再设一个除数—— $10011$
- 因为除数有5位，所以它的位宽 $W = 5 - 1 = 4$
- 在被除数后面补0，补0的数量等于位宽，被除数变为 $101010110000$
- 做模2除法，观察余数（与算术除法类似，但每一位除的结果不影响其它位，即不向上一位借位，实际上就是异或）
  ```
                  1 0 1 1 0 1 1
         ___________________________________
  10011 / 1 0 1 0 1 0 1 1 0 0 0 0
          1 0 0 1 1
          _________
              1 1 0 0 1
              1 0 0 1 1
              _________
                1 0 1 0 1
                1 0 0 1 1
                _________
                    1 1 0 0 0
                    1 0 0 1 1
                    _________
                      1 0 1 1 0
                      1 0 0 1 1
                      _________
                          1 0 1 0
  ```
  所以，余数为 $1010$
- 这个余数就是校验位，将校验位重新补到要发送的数据后面，被除数就变成了 $10101011$**1010**

## 接收过程

- 假设接收端接收到二进制比特流 $10001011 1010$，注意，第10位出现比特差错，暂时接收端还不知道接收的流有错
- 将接收到的比特流作为被除数，除数是预先定义好的 $10011$
- 短除
  ```
                  1 0 0 1
         ___________________________________
  10011 / 1 0 1 0 1 0 1 1 1 0 1 0
          1 0 0 1 1
          _________
              1 0 0 1 1
              1 0 0 1 1
              ____________________
                          1 0 1 0
  ```
- 因为最后除有余数，所以判断在传输过程中出现比特差错

## 基本原理

发送的时候，已经将余数加上了，所以理想情况接收到相同的比特流（视为一个非常长的二进制数）再除以相同的除数时，应该时能被整除的，当不能整除的时候，自然就是传输出错了。

但是相应的，如果同时错了好几位，使得差错的比特流刚好能被除数整除，那就发现不了错误，所以需要在除数的选定上下功夫。

CRC算法中把除数选择这个过程有一个专有的词来描述——**生成多项式**。

所以，上面所述流程中的生成多项式就是 $ G(x) = x^4 + x + 1 $，即除数是$ x $从高往低次幂的系数，其中，常数项及最高次幂必为1，称最高次幂为位宽（$W$）。

> from baike.baidu.com
> 生成多项式需要尽量满足以下条件
> 1. 生成多项式的最高位和最低位必须为1。
> 2. 当被传送信息（CRC码）任何一位发生错误时，被生成多项式做除后应该使余数不为0。
> 3. 不同位发生错误时，应该使余数不同。
> 4. 对余数继续做除，应使余数循环。

现在有一些已经总结好的生成多项式可供选择：
 - $CRC-8=X^8+X^5+X^4+X^0$
 - $CRC-16=X^{16}+X^{15}+X^2+X^0$
 - $CRC-12=X^{12}+X^{11}+X^3+X^2+X^0$
 - $CRC-32=X^{32}+X^{26}+X^{23}+X^{22}+X^{16}+X^{12}+X^{11}+X^{10}+X^8+X^7+X^5+X^4+X^2+X^1+X^0$

值得注意的是，CRC算法只能用来校验数据链路中传输的比特流正确性，并不能检验比特流所携带信息等是否正确（例如数据帧发生丢失、重传等，CRC不知道），因此数据链路层想网络层提供可靠的传输服务中，CRC只是各项保证的其中之一。
