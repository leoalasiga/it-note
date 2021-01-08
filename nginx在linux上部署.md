### Nginx在linux系统上部署

##### 1.下载nginx的tar.gz安装包

```
wget -c https://nginx.org/download/nginx-1.15.8.tar.gz
```

##### 2.解压tar包到指定文件夹

```
tar -zxvf nginx-1.15.8 -C 指定文件夹路径(如果没有,先创建文件夹)
```

##### 3.nginx配置

```
./configure(使用默认配置)
```

(1)会报错,需要安装gcc环境

```
yum install gcc-c++
```

(2)安装PCRE依赖库

PCRE(Perl Compatible Regular Expressions)是一个Perl库,包括perl兼容的正则表达式库.nginx的http模块使用pcre来解析正则表达式,所以需要linux上安装pcre库,pcre-devel是使用pcre开发的一个二次开发库

```
yum install -y pcre pcre-devel
```

(3)安装zlib依赖库

zlib库提供了多种压缩和解压缩的方式,nginx使用的zlib对http包的内容进行了gzip

```
yum install -y zlib zlib-devel
```

(4)安装OpenSSL安全套接字层密码库

OpenSSL是一个强大的安全套接字层密码库.囊括主要密码的算法,常用的密钥和证书封装管理功能及SSL协议,并提供丰富的应用程序供测试或其他目的使用

```
yum install -y openssl openssl-devel
```

(5)再次执行配置命令

```
./configure
```

##### 4.编译安装

```
make install
```

##### 5.查找安装

```
whereis nginx
```

##### 6.启动,停止nginx

(1)进入nginx的目录

```
cd /usr/local/nginx/sbin
```

(2)启动,停止,重加载的命令

```
./nginx				    开启
./nginx -s stop			停止(先查出nginx进程id在使用kill命令强制杀掉进程)
./nginx -s quit			停止(待nginx进程处理任务完毕进行停止)
./nginx -s reload		重加载
```

##### 7.修改端口号

(1)进入nginx的配置文件

```
cd /usr/local/nginx/conf
```

(2)备份配置文件

```
cp nginx.conf nginx.conf.back
```

(3)编辑nginx.conf配置文件

```
vim nginx.conf
```

---nginx配置文件解析

```

#user  nobody;						 定义Nginx运行的用户和用户组
worker_processes  1;				  nginx的进程数,建议设置为cpu总核心数

#error_log  logs/error.log;				全局错误日志定义类型
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;					进程文件


events {						工作模式与连接数上限:worker_connections是单个后台work_processes
    worker_connections  1024;	  进程的最大并发连接数,并发总数是这两者的乘积
}


http {
    include       mime.types;      文件扩展名与文件类型映射表
    default_type  application/octet-stream;		默认文件类型

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;  	开启高效文件传输模式,sendfile指令指定nginx是否调用sendfile函数来输出文件							 对于普通应用设为 on，如果用来进行下载等应用磁盘IO重负载应用，可设置 为							  off，以平衡磁盘与网络I/O处理速度，降低系统的负载。注意:如果图片显示不正常 							 把这个改成off
    
    #autoindex on; 		    开启目录列表访问，合适下载服务器，默认关闭。
    #tcp_nopush     on;		防止网络阻塞
    #tcp_nodelay on; 		防止网络阻塞

    #keepalive_timeout  0;
    keepalive_timeout  65;	长连接超时时间,单位是秒

    #gzip  on;			   开启gzip压缩输出

    server {
        listen       80;	监听的端口号(修改这里的端口号即可改变访问的端口)
        server_name  localhost;		服务器的名字

        #charset koi8-r;		字符集

        #access_log  logs/host.access.log  main;

        location / {			
            root   html;		监听到80端口后跳转到nginx的html文件夹下index页面
            index  index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;	错误页面
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server		https服务
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

}
```

(4)修改配置文件后重新加载nginx,更新配置文件

```
./nginx -s reload
```

(5)查询nginx的进程

```
ps aux|grep nginx
```

##### 8.重启nginx

(1)先停止再启动(推荐)

```
./nginx -s quit
./nginx
```

(2)重新加载配置文件(修改配置文件之后都需要重启nginx才能生效)

```
./nginx -s reload
```

##### 9.开启自启动

(1)打开rc.local文件

```
vim /etc/rc.local
```

(2)添加语句

```
/usr/local/nginx/sbin/nginx
```

(3)设置权限

```
chmod 755 /etc/rc.local
```

##### 10.进阶,配置请求转发

有些时候我们有需求,需要隐藏真正的路径,通过一个公有的路径,通过nginx,将请求转发到我们需要的路径上;

```
	server{
	listen 8800;								监听的端口号
	server_name localhost;
	location / {
		 proxy_redirect off;
		 proxy_set_header Host $host; 
		 proxy_set_header X-Real-Ip $remote_addr;  			用以记录客户端的ip地址
		 proxy_set_header X-Forwarded-For $remote_addr; 	用以记录客户端的ip地址
		 proxy_pass http://122.224.241.29:10080; 			转发到具体地址
		}
	}
```

