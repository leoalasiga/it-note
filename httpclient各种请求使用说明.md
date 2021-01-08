#### HttpClient的使用说明(httpcomponents-client-4.5.2 )

##### 1.http请求

HttpClient 支持所有的定义在 HTTP/1.1 规范的 HTTP 原装方法： GET, HEAD, POST, PUT, DELETE, TRACE 和 OPTIONS。 

每一个方法都有相应的类：HttpGet, HttpHead, HttpPost, HttpPut, HttpDelete, HttpTrace 和 HttpOptions 

```java
HttpGet httpget = new HttpGet("http://www.google.com/search?hl=en&q=httpclient&btnG=Google+Search&aq=f&oq=");
```

HttpClient 提供了 `URIBuilder` 工具类来简化请求 URI 的创建和修改。 

```java
URI uri = new URIBuilder()
        .setScheme("http")
        .setHost("www.google.com")
        .setPath("/search")
        .setParameter("q", "httpclient")
        .setParameter("btnG", "Google Search")
        .setParameter("aq", "f")
        .setParameter("oq", "")
        .build();
HttpGet httpget = new HttpGet(uri);
System.out.println(httpget.getURI());
//输出http://www.google.com/search?hl=en&q=httpclient&btnG=Google+Search&aq=f&oq=
```

##### 2.http响应

HTTP 响应是服务器在收到并解析了客户端的请求信息后返回给客户端的信息。消息的第一行包含了协议的版本号，后面有一个数字 表示的状态码，还有一个相关的词语。 

```java
HttpResponse response = new BasicHttpResponse(HttpVersion.HTTP_1_1, HttpStatus.SC_OK, "OK);

System.out.println(response.getProtocolVersion());//HTTP/1.1
System.out.println(response.getStatusLine().getStatusCode());//200
System.out.println(response.getStatusLine().getReasonPhrase());//OK
System.out.println(response.getStatusLine().toString());//HTTP/1.1 200 OK
```

##### 3.使用消息头

```java
HttpResponse response = enw BasicHttpResponse(HttpVersion.HTTP_1_1, HttpStatus.SC_OK, "OK");
response.addHeader("Set-Cookie", "c1=a; path=/; domain=localhost");
response.addHeader("set-Cookie", "c2=b; path=\"/\", c3=c; domain=\"localhost\"");
Header h1 = response.getFirstHeader("Set-Cookie");
System.out.println(h1);//Set-Cookie: c1=a; path=/; domain=localhost
Header h2 = response.getLastHeader("Set-Cookie");
System.out.println(h2);//Set-Cookie: c2=b; path="/", c3=c; domain="localhost"
Header[] hs = response.getHeaders("Set-Cookie");
System.out.println(hs.length);//2
```

用 HeaderIterator 接口来获取给定类型的所有头部是最高效的方式。 

```java
HttpResponse response = enw BasicHttpResponse(HttpVersion.HTTP_1_1, HttpStatus.SC_OK, "OK");
response.addHeader("Set-Cookie", "c1=a; path=/; domain=localhost");
response.addHeader("set-Cookie", "c2=b; path=\"/\", c3=c; domain=\"localhost\"");

HeaderIterator it = response.headerIterator("Set-Cookie");

while(it.hasNext()) {
    System.out.println(it.next());
}
/**
 * 会输出
 * Set-Cookie: c1=a; path=/; domain=localhost
 * Set-Cookie: c2=b; path="/", c3=c; domain="localhost"
 */
```

迭代器同时提供了方便的方法来将 HTTP 消息解析成独立的头部元素。 

```java
HttpResponse response = enw BasicHttpResponse(HttpVersion.HTTP_1_1, HttpStatus.SC_OK, "OK");
response.addHeader("Set-Cookie", "c1=a; path=/; domain=localhost");
response.addHeader("set-Cookie", "c2=b; path=\"/\", c3=c; domain=\"localhost\"");

HeaderElementIterator it = new BasicHeaderElementIterator(response.headerIterator("Set-Cookie"));

while(it.hasNext()) {
    HeaderElement elem = it.nextElement();
    System.out.println(elem.getName() + " = " + elem.getValue());

    NameValuePair[] params = elem.getParameters();
    for(int i = 0; i < params.length; i++) {
        System.out.println(" " + params[i]);
    }
}
/*
 *c1 = a
 *path=/
 *domain=localhost
 *c2 = b
 *path=/
 *c3 = c
 *domain=localhost
 */
```

##### http实体

HTTP 消息能够携带与请求或响应相关的内容实体。这些实体能在某些请求和某些响应中找到，因为它们是可选的。 使用实体的请求指的是封装请求的实体。HTTP 协议规定了两种实体封装请求方法：POST 和 PUT。 响应通常被认为是封装内容的实体。当然这个规定也有例外，比如 HEAD 方法的响应和 204 No Content，304 Not Modified， 205 Reset Content 响应 