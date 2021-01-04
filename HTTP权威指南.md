## HTTP权威指南



## 第一部分 HTTP:WEB基础

### 第一章 HTTP概述



#### 1.1 HTTP--因特网的多媒体信使

HTTP使用的是可靠信息传输协议,因此可以确保数据在传输过程中不会被损坏或产生错乱;



#### 1.2 Web客户端和服务器

Web内容=>存在Web服务器;

Web服务器使用Http协议=>也叫Http服务器

Http服务器存储因特网数据

+ Http客户端发出请求

+ 服务器会在Http响应中回送所请求的数据

![img](https://docimg9.docs.qq.com/image/hz2fgmbEV_UhBO6zlILX2A?w=752&h=280)

#### 1.3 资源

Web服务器是Web资源的宿主

web资源是web内容的源头(最简单的资源就是web服务器文件系统中的静态文件)

![img](https://docimg7.docs.qq.com/image/QAgE7iLaFJGMnvdQlnWPoA?w=741&h=553)

##### 1.3.1 媒体类型

Http给每种要通过Web传输的对象都打上名为MIME类型的数据格式标签

Web服务器会给所有Http对象数据带上一个MIME类型,让他知道该如何处理这个对象

![img](https://docimg9.docs.qq.com/image/M-CajlZmYthDjyadARGLyw?w=764&h=254)

> MIME是一种文本标记,表示一种主要的对象类型和一个特定的子类型,中间以一条斜杠来分隔

+ HTML格式文本文档由text/html类型标记

+ 普通的Ascii格式由text/plain类型标记

+ JPEG图片为image/jpeg类型

+ GIF图片为image/gif类型

...

\##### 1.3.2 URI

每个web服务器资源	都有一个名字

服务器的资源名统称为统一资源标识符(Uniform Resource Identifier,URI)

URI有两种对象

+ URL

+ URN

##### 1.3.3 URL

统一资源定位符(URL)是资源标识符最常见的形式

URL描述了一台特定服务器上某资源的特定位置

![img](https://docimg3.docs.qq.com/image/VGqHL9ObZvS5yCZ7GOxTEw?w=758&h=329)

> URL遵循统一的标准格式

+ URL第一部分称为方案,说明访问服务器的协议类型,这部分通常为HTTP协议

+ 第二部分给出了因特网的地址

+ 其余部分说明了WEB服务器上的某个资源

现在几乎所有URI都是URL

##### 1.3.4 URN

URN(统一资源名),作为特定内容的唯一名称使用,与资源的所在地无关

使用URN,可以将资源四处搬移,用一个名字就可以通过多种网络协议访问资源



#### 1.4 事务

一个HTTP事务是由一条请求命令和一个响应结果组成

这种通信是通过名为HTTP报文的格式化数据块组成

![img](https://docimg10.docs.qq.com/image/F1jwvKGs2UQtspNqyMFamQ?w=747&h=347)

##### 1.4.1 方法

Http支持集中不同的请求命令,这些命令被称为http方法

![img](https://docimg1.docs.qq.com/image/wQup-cD8brMh0drkHGOZJQ?w=742&h=211)##### 

##### 1.4.2 状态码

http响应报文都会携带一个状态码,

状态码由三个数字组成,告知服务器请求是否成功,是否需要采取什么操作

![img](https://docimg5.docs.qq.com/image/6o6M5ESz0zhpoO6tlPMDVg?w=758&h=160)

伴随状态码,还有一个解释性的原因短语文本

##### 1.4.3 Web页面中可以包含多个对象

应用程序完成一项任务时通常会发布多个http事务

![img](https://docimg1.docs.qq.com/image/7-E0e1WsU4CsY1VlqT66bQ?w=757&h=428)

#### 1.5 报文

Http报文是由一行行的简单字符串组成

![img](https://docimg4.docs.qq.com/image/aanha4MY0f86muhT9Lc7BQ?w=779&h=244)

+ web客户端发往web服务端的http报文成为请求报文

+ 服务端=>客户端的成为响应报文

> http报文包括以下三部分

+ 起始行

第一行就是起始行,请求报文中用来说明要做什么,响应报文中说明出现什么情况

+ 首部字段

起始行后面有零个或多个首部字段,每个首部字段包含一个名字和一个值,以`:` 来分隔,首部字段以空行结束

+ 主体

空行之后为报文主体,包含所有类型的数据,请求主体包含发送给web服务器的数据,响应主体中装载了要返回给客户端的数据.起始行和首部字段都是结构化的文本数据,而主体可以包含任意二进制数据

![img](https://docimg8.docs.qq.com/image/M-mNRGic3LffFoohJKfszg?w=758&h=735)



#### 1.6 连接

> 报文通过传输协议(TCP)进行传输

##### 1.6.1 TCP/IP

HTTP是应用层的协议,无需关心网络通信,由通用可靠的因特网传输协议TCP/IP负责

TCP提供了:

+ 无差错的数据传输

+ 按需传输(数据按照发送顺序到达)

+ 未分段数据流(可以在任意时刻以任何尺寸将数据发出)



用网络术语来说,HTTP协议位于TCP的上层![img](https://docimg5.docs.qq.com/image/3ANx9I23CACrjilU6P3EFw?w=766&h=291)

##### 1.6.2 连接 ip地址及端口号

在TCP客户端向服务器发送报文之前,需要用网络协议(ip)地址和端口号在客户端和服务器之间建立一条TCP/IP连接

![img](https://docimg6.docs.qq.com/image/pMYBY6OnTrTunYf1xF4UjA?w=762&h=706)

1. 浏览器从url中解析出服务器的主机名
2. 浏览器将服务器的主机名转换成服务器ip地址
3. 浏览器将端口号从url中解析出来
4. 浏览器建立一条与web服务器的tcp连接
5. 浏览器向服务器发送一条HTTP请求报文
6. 服务器向浏览器回送一条HTTP响应报文
7. 关闭连接,显示文档



##### 1.6.2 使用Telnet实例

telnet程序可以连接到某个TCP端口,将内容回显到屏幕

![img](https://docimg2.docs.qq.com/image/scHehKlb5dy2-qxejmYGqg?w=760&h=658)



#### 1.7 协议版本

+ HTTP/0.9

+ HTTP/1.0

+ HTTP/1.0+

+ HTTP/1.1

+ HTTP/NG



#### 1.8 web的机构化组件

+ 代理

位于客户端与服务器之间的HTTP中间实体

+ 缓存

HTTP仓库,使常用的页面副本可以保存在离客户端更近的地方

+ 网关

连接其他应用程序的特殊WEB服务器

+ 隧道

对Http通信报文进行盲转发的特殊代理

+ Agent代理

发起自动的HTTP请求的半智能Web客户端

##### 1.8.1 代理

位于客户端与服务器之间,接受所有客户端请求,并将请求转发给服务器(或修改后转发),对用户来说就是一个代理

![img](https://docimg8.docs.qq.com/image/ZzLQ2MmfCfVMgfzCaIufjw?w=740&h=224)







\### 第二章 URL与资源

\### 第三章 HTTP报文

\### 第四章 连接管理

\## 第二部分 HTTP结构

\### 第五章 web服务器

\### 第六章 代理

\### 第七章 缓存

\### 第八章 集成点:网关 隧道 中继

\### 第九章 Web机器人

\### 第十章 HTTP-NG

\## 第三部分 识别认证与安全

\### 第十一章 客户端识别与cookie机制

\### 第十二章 基本认证机制

\### 第十三章 摘要认证

\### 第十四章 安全HTTP

\## 第四部分 实体 编码和国际化

\### 第十五章 实体和编码

\### 第十六章 国际化

\### 第十七章 内容协商及转码

\## 第五部分 内容发布与分发

\### 第十八章 Web主机委托

\### 第十九章 发布系统

\### 第二十章 重定向与负载均衡

\### 第二十一章 日志记录及使用情况追踪

\## 第六部分 附录

 







# 