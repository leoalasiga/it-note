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

位于客户端与服务器之间,接受所有客户端请求,并将请求转发给服务器(或修改后转发),对用户来说就是一个代理.

![img](https://docimg8.docs.qq.com/image/ZzLQ2MmfCfVMgfzCaIufjw?w=740&h=224)

出于安全考虑,会将代理作为转发所有流量的可信任中间节点使用,代理还可以对请求和响应进行过滤;

##### 1.8.2 缓存

web缓存(web cache)或代理缓存(proxy cache是一种特殊的http代理服务器,可以将经过代理传送的常用文档复制保存起来,下一个请求同一文档的客户端就可以享受缓存的私有副本所提供的服务了

![image-20210226142805421](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210226142805421.png)

##### 1.8.3 网关

网关(gateway)是一种特殊的服务器,作为其他服务器的中间实体使用.通常用于将http流量转换成其他协议.

![image-20210226143135432](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210226143135432.png)

##### 1.8.4 隧道

隧道(tunnel)是建立起来之后,就会在两条连接之间对原始数据进行盲转发的http应用程序.

http隧道通常用来在一条或者多条http连接上转发非http数据,转发时不会窥探数据

常见用途:通过http连接承载加密的安全套接字(SSL,Secure Sockets Layer)流量,这样ssl流量就可以穿过只允许web流量通过的防火墙了.

![image-20210226144023725](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210226144023725.png)

##### 1.8.5 Agent代理

用户Agent代理是代表用户发起Http请求的客户端程序.

所有发布web请求的应用程序都是http agent代理

![image-20210226144238618](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210226144238618.png)



### 第二章 URL与资源

> 本章介绍以下内容

+ url语法,url组件含义及其作用
+ 很多web客户端都支持url快捷方式,包括相对url和自动扩展url
+ url编码和字符规则
+ 支持各种因特网信息系统的常见url方案
+ url未来,包括urn(这种框架可以保证对象从一处搬到另一处,保持稳定的访问名称)

#### 2.1 浏览因特网资源

URL是浏览器寻找信息时所需的资源位置

URI是一类更通用的资源标识符,URL实际是他的子集(URI包含URL和URN),URI通过位置标记资源,URN通过名字标记

```txt
如你想访问https://www.google.com/aaa
url第一部分(http)就是URL方案(scheme);
url第二部分(www.google.com)指的是服务器位置
url第三部分(aaa)是资源路径
```

![image-20210226153926830](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210226153926830.png)

大多数URL结构

**`方案://主机/路径`**

#### 2.2 URL语法

大多数URL方案的URL语法都建立在9部分构成的通用格式上

<scheme>://<user>:<password>@<host>:<port>/<path>;<params>?<query><#><frag>

![image-20210226154905232](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210226154905232.png)

##### 2.2.1 方案-使用什么协议

方案实际上是规定如何访问指定资源的主要标识符,告诉负责解析URL的应用采用什么协议

##### 2.2.2  主机与端口

主机组件标记了因特网上能访问资源的宿主机器(用主机名或者ip表示)

端口组件标识了服务器正在监听的网络端口

##### 2.2.3 用户名和密码

很多服务器需要用户输入用户名和密码才可以允许访问

##### 2.2.4 路径

URL路径说明了资源服务器的什么地方,可以用`/` 将http url的路径组件划分为路径段

##### 2.2.5 参数

负责解析URL的应用程序需要这些协议参数来访问资源,以便正确的与服务器交互,这个组件就是URL的键值对,由字符串";"将其与URL的其余部分分隔开

##### 2.2.6 查询字符串

url的查询组件和标识网关资源的url路径一起发送给网关资源

![image-20210226170735966](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210226170735966.png)

很多网关希望查询字符串以一些列键值对的形式出现,键值对之间以`&`隔开

##### 2.2.7 片段

有些资源类型,如HTML,除了资源级之外,还可以进一步划分

如对一个有大章节的文本来说,资源会指向整个文档,但理想情况指定资源某个章节

为了 引用部分资源或者一个片段,url支持使用片段(frag)组件表示一个资源的内部片段,比如可以指向一个特定的图片和小节.

片段挂在URL的右边,前面加一个`#`字符串

http://www.joes-hardware.com/tools.html#drill

![image-20210226171954245](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210226171954245.png)



#### 2.3 URL快捷方式

##### 2.3.1 相对URL

URL有两种方式:**绝对的** 和  **相对的** ;

绝对的URL中包含了访问资源所需的所有信息

相对URL是不完整的,要从相对URL中获取访问资源所需的信息,就必须相对另一个,被称为其基础(base)的URL进行解析

![image-20210226172501811](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210226172501811.png)

a标签的href里面是URL的相对路径

![image-20210226173018775](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210226173018775.png)

1. 基础URL
   + 在资源中显示提供
   + 封装资源的基础URL
   + 没有基础URL
2. 解析相对引用

![image-20210301101421613](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301101421613.png)

这个算法将一个相对URL转换成其绝对模式,之后就可以用它来引用资源了

##### 2.3.2 自动扩展URL

浏览器会在用户提交URL之后,会在用户输入的时候尝试自动扩展URL

+ 主机名扩展
+ 历史扩展



#### 2.4 各种令人头疼的字符

URL是可移植的(portable):可以通过各种不同的协议来传输数据

URL是可读的

URL是完整的

##### 2.4.1 URL字符集

默认计算机以英语为中心,为了满足完整性和可移植性,URL设计者将**转义序列**集成进去,通过转义序列,可以用US-ASCII字符集的有限子集对任意字符进行编码

##### 2.4.2 编码机制

为了避免安全字符集表示法的限制,人们设计了一种编码机制,在URL中表示各种不安全的字符;

这种编码机制表示法通过一个百分号(%),后面跟着两个字符ASCII码的十六进制数

![image-20210301134340336](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301134340336.png)

##### 2.4.3 字符限制

在URL中,有几个字符被保留下来,有着特殊的含义

![image-20210301134505897](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301134505897.png)

##### 2.4.4 另外一点说明

客户端应用程序向其他应用发送任意URL之前,最好把所有的不安全 或受限字符进行转换

#### 2.5 方案的世界

![image-20210301135256952](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301135256952.png)

![image-20210301135306078](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301135306078.png)

#### 2.6 未来展望

统一资源名(uniform resource name,URN),无论对象搬移到什么地方,URN都能为对象提供一个稳定的名称

永久统一资源定位符(persist uniform resource locators,PURL)是用URL实现URN的功能;基本思想是在搜索的时候加入一个中间层,通过中间资源定位符服务器对资源的实际URL进行登记和跟踪,客户端向定位符请求一个永久URL,定位符可以以一个资源作为响应,将客户端重定向到资源当前实际的URL上去

![image-20210301143030662](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301143030662.png)



## 第三章 HTTP报文

这章内容

+ 报文是如何流动的
+ HTTP报文的三个组成部分
+ 请求和响应报文之间的区别
+ 和响应报文一起返回的各种状态码
+ 各种各样的HTTP首部是用来做什么的



#### 3.1 报文流

> HTTP报文是在HTTP应用程序之间发送的数据块,这些数据块以一些文本形式的元信息(meta-information)开头,这些信息描述了报文的内容及含义,后面跟着可选的数据部分

##### 3.1.1 报文流入源端服务器

HTTP使用术语(inbound)和流出(outbound)来描述事务处理(transcation)的方向

![image-20210301161120524](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301161120524.png)

##### 3.1.2 报文向下流动

不管请求还是响应报文,都会向下游(downstream)流动,所有报文的发送者都在接受者的上游(upstream)

![image-20210301162336319](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301162336319.png)

#### 3.2 报文的组成

HTTP报文是简单的格式化数据块

每条报文由三部分组成

+ 对报文进行描述的起始行(start line)
+ 包含属性的首部(header)块
+ 可选的包含数据主体(body)部分

![image-20210301163759078](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301163759078.png)

起始行和首部就是由分隔的ASCII文本.每行以一个由两个字符组成的行终止序列作为结束,其中包括一个回车符合一个换行符.这个行终止序列可以写作CRLF

实体的主体是一个可选的数据块,可以包含文本或二进制数据,也可以为空

##### 3.2.1 报文的语法

所有报文分为两类

+ 请求报文(request message)

```
<method><request-URL><version>
<headers>

<entity-body>
```

+ 响应报文(response message)

```
<version><status><reason-phrase>
<header>

<entity-body>
```

![image-20210301164214729](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301164214729.png)

下面是对各部分的简要描述

+ 方法(method):客户端希望服务器对资源执行的动作,如GET,POST
+ 请求URL(request-URL):命名所请求的资源
+ 版本(version):报文使用的HTTP版本,格式如HTTP/<major>.<minor>
+ 状态码(status-code):三位数字描述请求过程发生的情况,如200,400
+ 原因短语(reason-phrase):数字状态码的可读版本,如404 NOT FOUND
+ 首部(header):零个或多个首部, name: value CRLF
+ 实体的主体部分(entity-body)"包含一个由任意数据组成的数据块

![image-20210301164939722](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301164939722.png)

##### 3.2.2 起始行

所有报文都以一个起始行作为开始;

1. 请求行

请求报文的起始行,包含一个方法和一个请求的URL,包含一个HTTP版本

2. 响应行

响应报文承载了状态信息和操作产生的所有结果数据,将其返回给客户端,包含了HTTP版本,数字状态码以及原因短语

3. 方法

请求起始行以方法开始

![image-20210301165528883](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301165528883.png)

还有一些对HTTP规范的扩展,被称为扩展方法

4. 状态码

告诉客户端发生了什么事情

状态码在每条响应的报文的起始行中返回,包括一个数字状态和一个可读的状态

![image-20210301171506187](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301171506187.png)

![image-20210301171538965](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301171538965.png)

5. 原因短语

原因短语为状态码提供了文本形式解释,与状态码成对出现

6. 版本号

会以HTTP/x.y形式出现

版本号x和y当做数字单独比较,如HTTP/2.22>HTTP/2.3



##### 3.2.3 首部

起始行后面就是零个或多个首部字段

首部字段向请求和响应报文中添加一些附加信息,是一个键值对列表

1. 首部分类

+ 通用首部:请求和响应报文中都可以出现
+ 请求首部:更多请求信息
+ 响应首部:更多响应信息
+ 实体首部:描述长度和内容或者资源本身
+ 扩展首部:规范中没定义的新首部

![image-20210301172426716](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301172426716.png)

2. 首部延续行

将首部分成多行提供可读性,每行前至少有一个空格和制表符

##### 3.2.4 实体的主体部分

第三部分是可选的实体主体部分,实体的主体是HTTP报文的负荷

可以承载很多数字数据:图片,视频,html文档..

##### 3.2.5 版本0.9的报文

HTTP版本0.9是早期版本,鼻祖

![image-20210301173210087](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301173210087.png)



#### 3.3 方法

##### 3.3.1 安全方法

HTTP定义了一组被称为安全方法的方法.GET和HEAD方法都是安全的,因为不会产生什么动作,即不会在服务器上产生什么结果

##### 3.3.2 GET

最常用的方法,用于请求服务器发送某个资源

![image-20210301174206855](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301174206855.png)

##### 3.3.3 HEAD

服务器在响应中的返回首部,不会返回实体的主体部分,允许客户端在未获取实际资源的情况下,对资源的首部进行检查

+ 在不过去资源的情况下了解资源情况(如判断)
+ 通过查看状态码,查看某个对象是否存在
+ 通过查看首部,资源是否被修改

![image-20210301174529423](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301174529423.png)

##### 3.3.4 PUT

PUT方法向服务器写入文档

![image-20210301174757696](C:\Users\leoalasiga\Desktop\image-20210301174757696.png)

PUT方法的语义就是让服务器用主体部分来创建一个由所请求的URL命名的新文档,文档存在,则替换它

##### 3.3.5 POST

起初是用来想服务器输入数据的,实际上用来支持HTML的表单

![image-20210301175138185](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301175138185.png)

##### 3.3.6 TRACE

客户端发起请求,请求要穿过防火墙,代理,网关等,每个中间节点可能修改原始的HTTP请求,TRACE方法可以查看最终请求发送给服务器时,变成了什么样子

TRACE请求会在目的服务器端发起一个环回诊断,可以查看所有中间HTTP组成的请求/响应链,查看原来的报文怎么变化的

![image-20210301175530336](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301175530336.png)

TRACE主要用于诊断

##### 3.3.7 OPTIONS

OPTIONS方法请求WEB服务器告知其支持的各种功能

![image-20210301175810907](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301175810907.png)

##### 3.3.8 DELETE

删除服务器请求URL指定的资源,

![image-20210301175954474](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301175954474.png)

##### 3.3.9 扩展方法

![image-20210301180110595](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210301180110595.png)

HTTP被设计成字段可扩展的

对所发送的内容要求严一点,对所接受的内容宽容一点

#### 3.4 状态码

HTTP状态码被分成五大类

##### 3.4.1 100~199 信息性状态码

![image-20210302105437306](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302105437306.png)

##### 3.4.2 200~299 成功状态码

![image-20210302105720197](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302105720197.png)

##### 3.4.3 300~399 重定向状态码

![image-20210302110244187](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302110244187.png)

![image-20210302110412873](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302110412873.png)

![image-20210302110438693](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302110438693.png)

![image-20210302110500583](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302110500583.png)

##### 3.4.4 400~499 客户端错误状态码

![image-20210302110658728](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302110658728.png)

![image-20210302110723944](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302110723944.png)

##### 3.4.5 500~599 服务器错误状态码

![image-20210302110755945](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302110755945.png)

![image-20210302110803371](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302110803371.png)

#### 3.5 首部

首部和方法配合工作,决定了客户端和服务器能做什么事

+ 通用首部

  这些是客户端和服务器都可以使用的通用首部,提供一些非常有用的通用功能,如Date提供构建报文的时间和日期

+ 请求首部

  请求报文特有的,提供一些额外信息,如Accept首部告诉服务器客户端会接受与其请求相符的任意媒体类型

+ 响应首部

  响应报文首部,给客户端提供信息,如Server告知客户端他在他在拿个服务器进行交互

+ 实体首部

  实体首部指的是用于应对实体主体部分的首部,如可以用来说明实体主体部分的数据类型,如Content-Type告知数据以utf-8作为字符集

+ 扩展首部

  非标准首部,应用开发者创建,未添加到HTTP规范中



##### 3.5.1 通用首部

提供报文相关的最基本信息,即通用首部

![image-20210302111911616](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302111911616.png)

**通用缓存首部**

HTTP/1.0引入第一个允许HTTP应用缓存对象本地副本首部

![image-20210302112031921](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302112031921.png)

##### 3.5.2 请求首部

请求的信息

![image-20210302112154905](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302112154905.png)

1. Accept首部

为客户端提供了一种将其喜好和能力告知服务器的方式

![image-20210302112309142](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302112309142.png)

2. 条件请求首部

有时候客户端希望在请求上添加某些限制,要求服务器在对某些请求响应之前,确保某个条件为真

![image-20210302112403272](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302112403272.png)

3. 安全请求首部

HTTP本身支持的一种简单机制,对请求进行质询/响应认证,在获取特定资源前,对自身认证,使事务稍微安全一些

![image-20210302112616754](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302112616754.png)

4. 代理请求首部

![image-20210302112729526](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302112729526.png)

##### 3.5.3 响应首部

响应报文的响应首部集,为客户端提供了一些额外的信息

![image-20210302112814965](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302112814965.png)

1. 协商首部

如果资源有多种表示法,如服务器上有某文档的法语和德语版本,HTTP/1.1可以为服务器和客户端提供对资源进行协商的能力

![image-20210302113000959](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302113000959.png)

2. 安全响应首部

HTTP质询/响应认证机制的响应侧

![image-20210302113037692](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302113037692.png)



##### 3.5.4 实体首部

用来描述HTTP报文的负荷

![image-20210302113239181](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302113239181.png)

1. 内容首部

提供了与实体内容有关的特定信息,说明了其类型,尺寸以及处理它所需要的其他有用信息

![image-20210302113329311](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302113329311.png)

2. 实体缓存首部

实体缓存首部提供了与被缓存实体有关的信息

![image-20210302113430031](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302113430031.png)



## 第四章 连接管理

本章可以了解

+ HTTP是如何使用TCP连接的
+ TCP连接的时延,瓶颈以及存在的障碍
+ HTTP的优化,包括并行连接,keep-alive和管道化连接
+ 管理连接时应该以及不应该做的事

#### 4.1 TCP连接

几乎所有的通信都是由TCP/IP承载的,TCP/IP是全球计算机及网络设备都在使用的一种常用的分组交换网络分层协议集

![image-20210302114108690](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302114108690.png)

##### 4.1.1 TCP的可靠数据管道

HTTP连接实际上就是TCP连接和一些使用连接的规则

TCP为HTTP提供了一条可靠的比特传输管道,从TCP连接的一段填入的字节会从另一端以原有的顺序,正确的传送出来

![image-20210302114125777](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302114125777.png)

##### 4.1.2 TCP流失分段的,由IP分组传送

TCP的数据是通过名为IP分组的小数据块来发送的,HTTP就是HTTP over TCP over IP这个协议栈中的最顶层

![image-20210302114224869](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302114224869.png)

HTTP要传送一条报文时,以流的形式将报文数据的内容通过一条打开的TCP连接按需传输.TCP收到数据流之后,会将数据流砍成称作段的小数据块,并将端封装在IP分组里,通过因特网传输.所有工作都是通过TCP/IP实现

![image-20210302133128570](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302133128570.png)

每个TCP端都由IP分组承载,从一个IP地址发送到另一个IP地址,每个IP分组中都包括:

+ 一个IP分组首部(通常20字节)
+ 一个TCP段首部(20字节)
+ 一个TCP数据块(0或多个字节)

IP首部包含了源和目的IP地址,长度和其他一些标记

TCP首部包含了TCP端口号,TCP控制标记,以及用于数据排序和完整性检查的一些数字值

##### 4.1.3 保持TCP连接的正确运行

在任意时刻计算机都可以有几条TCP连接处于打开状态,TCP通过端口号来保持所有这些连接的正确运行

TCP连接通过4个值来识别

<源IP地址	源端口号	目的IP地址	目的IP端口号>

这4个值一起唯一定义了一条连接,两条不同的TCP连接不能拥有4个完全相同地址组件值

![image-20210302133136466](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302133136466.png)

![image-20210302133204917](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302133204917.png)

##### 4.1.4 用TCP套接字编程

操作系统提供了一些操纵其TCP连接的工具

![image-20210302133410575](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302133410575.png)

套接字API允许用户创建TCP的端点数据结构,将这些端点与远程服务器的TCP端点进行连接,并对数据流进行读写

![image-20210302133627759](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302133627759.png)

#### 4.2 对TCP性能的考虑

HTTP紧挨着TCP,位于其上层,所以HTTP事务的性能在很大程度上取决于底层TCP通道的性能

##### 4.2.1 HTTP事务的时延

HTTP请求的过程中会出现哪些网络延时

![image-20210302133847488](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302133847488.png)

注意:与建立TCP连接,以及传输请求和响应报文的时间相比,事务处理时间可能是很短的,除非客户端或服务器超载,或正在处理复杂的动态资源,否则HTTP时延就是由TCP网络时延构成的

HTTP事务的时延主要原因

1. 客户端首先要根据URI确定web服务器的IP地址和端口号,如果最近没有对URI主机进行访问,通过DNS解析系统将URI转换成IP地址要花数十秒
2. 接下里,客户端会向服务器发送一条TCP连接请求,并等待服务器回送一个请求接受应答,每条新的TCP连接都会有连接建立时延,这个值通常最多只有一两秒,但如果有数百个HTTP事务,这个值会快速叠加
3. 一旦连接建立起来,客户端就会通过新建立的TCP管道来发送HTTP请求.数据到达时,web服务器会从TCP连接中读取请求报文,并对请求进行处理,因特网传输请求报文,服务器处理请求报文都要时间
4. 然后,web服务器回送HTTP响应,也要花时间

这些TCP网络时延的大小取决于硬件速度,网络和服务器的负载,请求和响应报文的尺寸,以及客户端和服务器之间的距离

##### 4.2.2 性能聚焦区域

+ TCP连接建立握手
+ TCP慢启动的拥塞控制
+ 数据聚集的Nagle算法
+ 用于捎带确认的TCP延迟确认算法
+ TIME_WAIT时延和端口耗尽

##### 4.2.3 TCP连接建立握手时延

建立一条新的TCP连接,甚至是发送任意数据之前,TCP软件之间会交换一些列的IP分组,对连接的有关参数进行沟通.

但如果连接只用来传递少量数据,交换过程就会严重降低HTTP性能

![image-20210302135415851](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210302135415851.png)

1. 请求新的TCP连接时,客户端向服务器发送一个小的TCP分组(通常40-60字节),这个分组中设置了一个特殊的SYN标记,说明这是一个连接请求

2. 如果服务器接收了连接,就会对一些连接参数进行计算,并向客户端回送一个TCP分组,这个分组中的SYN和ACK标记都被置位,说明连接请求已经被接受
3. 最后,客户端向服务器回送一个确认信息,通知连接已成功建立,现代的TCP栈允许客户端在确认分组中发送数据

通常HTTP事务不会交换太多数据,此时SYN/SYN+ACK握手会产生一个可测量的时延.TCP连接的ACK分组通常足够大,可以承载整个HTTP请求报文

##### 4.2.4 延迟确认

由于Internet自身无法确保可靠的分组传输(Internet路由器在超负荷的话,会随意丢弃分组),所以TCP实现了自己的确认机制来确保数据的成功传输

每个TCP都有一个序列号和数据完整性校验和.每个段的接受者收到完好的段时,会向发送者回送小的确认分组,如果发送者没有在指定的窗口时间内收到确认信息,发送者就认为分组已被破坏或损毁,重发数据

由于确认报文很小,所以TCP允许在发往相同方向的输出数据分组中对其进行"捎带",TCP将返回的确认信息与输出的数据分组结合在一起,可以更有效的利用网络

为了确认报文找到同享传输数据分组的可能性,TCP栈实现了一种"延迟算法",延迟算法会在一个特定的窗口时间(100~200ms)内将输出确认存放在缓冲区中,以寻找能够捎带它的输出数据分组,如果没有,就将确认信息放在单独的分组中传送

HTTP具有双峰特征的请求-应答行为降低了捎带信息的可能,当希望有相反方向回传分组的时候,偏偏没有那么多,通常,延迟确认算法会引入相当大的时延.

##### 4.2.5 TCP慢启动

TCP数据传输的性能还取决于TCP连接的使用期(age)

TCP连接会随着时间进行自我"调谐",起初会限制连接的最大速度,如果数据传输成功,会随着时间的推移,提高传输速度,这种调谐被称为TCP慢启动(slow start),用于防止Internet的突然过载或拥塞

TCP慢启动限制了一个TCP端点在任意时刻可以传输的分组数,简单来说,没成功接受一个分组,发送端就有了发送另外两个分组的权限

由于具有这种拥塞控制特性,所以新连接传输速度会比已经交换过一定量数据的以调谐的连接慢一些,所以HTTP中有些可以重用现存连接的工具

##### 4.2.6 Nagle算法与TCP_NODELAY

TCP有一个数据流接口,应用程序可以通过它将任意尺寸的数据放入TCP栈中--即使一个字节也可以,但是,每个TCP段中至少装载了40个字节的标记和首部,所以如果TCP发送了大量包含少量数据的分组,网络的性能就会严重下降

Nagle算法:在发送一个分组之前,将大量的TCP数据绑定在一起,以提高网络效率

Nagle算法鼓励发送全尺寸(LAN最大尺寸的分组大约是1500,Internet上是几百字节)的段,只有当所有其他分组呗确认后,Nagle算法才允许发送非全尺寸的分组

Nagle算法引起的HTTP性能问题:1.HTTP报文太小,无法填满分组,要等待哪些永远不会到来的额外数据而产生时延;	2.Nagle算法与延迟确认之间存在交互问题,Nagle算法组织数据发送,直到有分组到达为止,但确认分组会被延迟确认算法延迟100~200ms

HTTP应用程序常常在自己的栈中设置参数TCP_NODELAY,禁用Nagle算法,提高性能

##### 4.2.7 TIME_WAIT累积与端口耗尽

TIME_WAIT端口耗尽是很严重的性能问题,会影响性能基准,

当某个TCP端点关闭TCP连接时,会在内存中维护一个小的控制块,用来记录最近所关闭连接的IP地址和端口号.这类信息只会维持一小段时间,通常是所顾忌的最大分段使用期的两倍(成为2MSL,通常两分钟)左右,已确保在这段时间内不会创建具有相同地址和端口号的连接,即保证在两分钟不会创建,关闭并重新创建两个具有相同IP地址和端口号的连接

2MSL的连接关闭延迟不是什么问题,但是在性能基准环境下就可能出现问题,如并发量500次/s 就会在120分钟内占用6w个端口,就可能出现TIME_WAIT端口耗尽的问题

​	解决办法:增加客户端负载生成机器的数量,或确保客户端和服务器再循环使用几个虚拟IP地址以增加更多的连接组合



#### 4.3 HTTP连接处理

##### 4.3.1 常被误解的Connection首部

HTTP允许在客户端和最终的源端服务器之间存在一串HTTP中间实体(代理,高速缓存等). 可以从客户端开始,逐条的将HTTP报文经过这些中国今年见设备,转发到源端服务器上去

某些情况下,两个相邻的HTTP应用程序会为他们共享的连接应用一组选项





























## 第二部分 HTTP结构

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