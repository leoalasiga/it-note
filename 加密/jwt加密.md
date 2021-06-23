## 什么是JWT

> Json web token (JWT), 是为了在网络应用环境间传递声明而执行的一种基于JSON的开放标准（(RFC 7519).该token被设计为紧凑且安全的，特别适用于分布式站点的单点登录（SSO）场景。JWT的声明一般被用来在身份提供者和服务提供者间传递被认证的用户身份信息，以便于从资源服务器获取资源，也可以增加一些额外的其它业务逻辑所必须的声明信息，该token也可直接被用于认证，也可被加密。

**简单来说就是** JWT(Json Web Token)是实现token技术的一种解决方案

### 为什么使用JWT

**token验证和session认证的区别**

传统的session认证

http协议本身是一种无状态的协议，而这就意味着如果用户向我们的应用提供了用户名和密码来进行用户认证，那么下一次请求时，用户还要再一次进行用户认证才行，因为根据http协议，我们并不能知道是哪个用户发出的请求，所以为了让我们的应用能识别是哪个用户发出的请求，我们只能在服务器存储一份用户登录的信息，这份登录信息会在响应时传递给浏览器，告诉其保存为cookie,以便下次请求时发送给我们的应用，这样我们的应用就能识别请求来自哪个用户了,这就是传统的基于session认证。

*session缺点*

基于session的认证使应用本身很难得到扩展，随着不同客户端用户的增加，独立的服务器已无法承载更多的用户

Session方式存储用户id的最大弊病在于要占用大量服务器内存，对于较大型应用而言可能还要保存许多的状态。

**基于session认证暴露的问题**

- **Session**需要在服务器保存，暂用资源
- **扩展性** session认证保存在内存中 ，无法扩展到其他机器中
- **CSRF** 基于cookie来进行用户识别的, cookie如果被截获，用户就会很容易受到跨站请求伪造的攻击。

### 基于token的鉴权机制

基于token的鉴权机制类似于http协议也是无状态的，它不需要在服务端去保留用户的认证信息或者会话信息。这就意味着基于token认证机制的应用不需要去考虑用户在哪一台服务器登录了，这就为应用的扩展提供了便利。

JWT方式将用户状态分散到了客户端中，可以明显减轻服务端的内存压力。除了用户id之外，还可以存储其他的和用户相关的信息，例如用户角色，用户性别等。

**请求流程**

1. 用户使用用户名密码来请求服务器
2. 服务器进行验证用户的信息
3. 服务器通过验证发送给用户一个token
4. 客户端存储token，并在每次请求时附送上这个token值
5. 服务端验证token值，并返回数据

> 这个token必须要在每次请求时传递给服务端，它应该保存在请求头里， 另外，服务端要支持 `CORS(跨来源资源共享)`策略，一般我们在服务端这么做就可以了 `Access-Control-Allow-Origin: *`。

### JWT的结构

一个JWT是下面的结构

> 加密后jwt信息如下所示，是由.分割的三部分组成，分别为Header、Payload、Signature

```html
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.
eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.
TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ
```

------

**JWT 的组成**

- Head -主要包含两个部分,alg指加密类型，可选值为`HS256`、`RSA`等等，`typ=JWT`为固定值，表示token的类型

  > ```actionscript
  > Header:
  > {
  >  "alg": "HS256",
  >  "typ": "JWT"
  > }
  > ```

- Payload - Payload又被称为Claims包含您想要签署的任何信息

  > ```actionscript
  > Claims:
  > {
  >  "sub": "1234567890",
  >  "name": "John Doe",
  >  "admin": true
  > }
  > ```
  >
  > JWT Payload的组成
  >
  > Payload通常由三个部分组成，分别是 Registered Claims ; Public Claims ; Private Claims ;每个声明，都有各自的字段。
  >
  > Registered Claims
  >
  > > iss 【issuer】发布者的url地址
  > >
  > > sub 【subject】该JWT所面向的用户，用于处理特定应用，不是常用的字段
  > >
  > > aud 【audience】接受者的url地址
  > >
  > > exp 【expiration】 该jwt销毁的时间；unix时间戳
  > >
  > > nbf 【not before】 该jwt的使用时间不能早于该时间；unix时间戳
  > >
  > > iat 【issued at】 该jwt的发布时间；unix 时间戳
  > >
  > > jti 【JWT ID】 该jwt的唯一ID编号

- Signature 对 则为对Header、Payload的签名

  > ```actionscript
  > Signature:
  > base64UrlEncode(Header) + "." + base64UrlEncode(Claims)
  > ```

**头部、声明、签名用 . 号连在一起就得到了我们要的JWT** 也就是夏明这种类型的字符串

> eyJhbGciOiJIUzI1NiJ9.
>
> eyJleHAiOjE1MTUyOTgxNDEsImtleSI6InZhdWxlIn0.
>
> orewTmil7YmIXKILHwFnw3Bq1Ox4maXEzp0NC5LRaFQ
>
> 其实这些事一行的，我只是让看的更直白点将其割开了。

### JAVA 实现

JAVA中使用JWT

使用Maven引入和Gradle引入

Maven

```markup
 <dependency>     
 <groupId>io.jsonwebtoken</groupId>     
 <artifactId>jjwt</artifactId>     
 <version>0.9.0</version> </dependency>
```

Gradle

```pascal
 dependencies { compile 'io.jsonwebtoken:jjwt:0.9.0' }
```

**JWT依赖于Jackson，需要在程序中加入Jackson的jar包且版本大于2.x**

**签发JWT**

```java
public static String createJWT() {
        SignatureAlgorithm signatureAlgorithm = SignatureAlgorithm.HS256;
        SecretKey secretKey = generalKey();
        JwtBuilder builder = Jwts.builder()
                .setId(id)                                      // JWT_ID
                .setAudience("")                                // 接受者
                .setClaims(null)                                // 自定义属性
                .setSubject("")                                 // 主题
                .setIssuer("")                                  // 签发者
                .setIssuedAt(new Date())                        // 签发时间
                .setNotBefore(new Date())                       // 失效时间
                .setExpiration(long)                                // 过期时间
                .signWith(signatureAlgorithm, secretKey);           // 签名算法以及密匙
        return builder.compact();
}
```

**验证JWT**

```java
public static Claims parseJWT(String jwt) throws Exception {
    SecretKey secretKey = generalKey();
    return Jwts.parser()
        .setSigningKey(secretKey)
        .parseClaimsJws(jwt)
        .getBody();
}
```

**完整示例**

```java
package com.tingfeng.demo;

import com.google.gson.Gson;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtBuilder;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.apache.tomcat.util.codec.binary.Base64;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class JwtUtil {

    /**
     * 由字符串生成加密key
     *
     * @return
     */
    public SecretKey generalKey() {
        String stringKey = Constant.JWT_SECRET;

        // 本地的密码解码
        byte[] encodedKey = Base64.decodeBase64(stringKey);

        // 根据给定的字节数组使用AES加密算法构造一个密钥
        SecretKey key = new SecretKeySpec(encodedKey, 0, encodedKey.length, "AES");

        return key;
    }

    /**
     * 创建jwt
     * @param id
     * @param issuer
     * @param subject
     * @param ttlMillis
     * @return
     * @throws Exception
     */
    public String createJWT(String id, String issuer, String subject, long ttlMillis) throws Exception {

        // 指定签名的时候使用的签名算法，也就是header那部分，jjwt已经将这部分内容封装好了。
        SignatureAlgorithm signatureAlgorithm = SignatureAlgorithm.HS256;

        // 生成JWT的时间
        long nowMillis = System.currentTimeMillis();
        Date now = new Date(nowMillis);

        // 创建payload的私有声明（根据特定的业务需要添加，如果要拿这个做验证，一般是需要和jwt的接收方提前沟通好验证方式的）
        Map<String, Object> claims = new HashMap<>();
        claims.put("uid", "123456");
        claims.put("user_name", "admin");
        claims.put("nick_name", "X-rapido");

        // 生成签名的时候使用的秘钥secret，切记这个秘钥不能外露哦。它就是你服务端的私钥，在任何场景都不应该流露出去。
        // 一旦客户端得知这个secret, 那就意味着客户端是可以自我签发jwt了。
        SecretKey key = generalKey();

        // 下面就是在为payload添加各种标准声明和私有声明了
        JwtBuilder builder = Jwts.builder() // 这里其实就是new一个JwtBuilder，设置jwt的body
                .setClaims(claims)          // 如果有私有声明，一定要先设置这个自己创建的私有的声明，这个是给builder的claim赋值，一旦写在标准的声明赋值之后，就是覆盖了那些标准的声明的
                .setId(id)                  // 设置jti(JWT ID)：是JWT的唯一标识，根据业务需要，这个可以设置为一个不重复的值，主要用来作为一次性token,从而回避重放攻击。
                .setIssuedAt(now)           // iat: jwt的签发时间
                .setIssuer(issuer)          // issuer：jwt签发人
                .setSubject(subject)        // sub(Subject)：代表这个JWT的主体，即它的所有人，这个是一个json格式的字符串，可以存放什么userid，roldid之类的，作为什么用户的唯一标志。
                .signWith(signatureAlgorithm, key); // 设置签名使用的签名算法和签名使用的秘钥

        // 设置过期时间
        if (ttlMillis >= 0) {
            long expMillis = nowMillis + ttlMillis;
            Date exp = new Date(expMillis);
            builder.setExpiration(exp);
        }
        return builder.compact();
    }

    /**
     * 解密jwt
     *
     * @param jwt
     * @return
     * @throws Exception
     */
    public Claims parseJWT(String jwt) throws Exception {
        SecretKey key = generalKey();  //签名秘钥，和生成的签名的秘钥一模一样
        Claims claims = Jwts.parser()  //得到DefaultJwtParser
                .setSigningKey(key)                 //设置签名的秘钥
                .parseClaimsJws(jwt).getBody();     //设置需要解析的jwt
        return claims;
    }

    public static void main(String[] args) {

        User user = new User("tingfeng", "bulingbuling", "1056856191");
        String subject = new Gson().toJson(user);

        try {
            JwtUtil util = new JwtUtil();
            String jwt = util.createJWT(Constant.JWT_ID, "Anson", subject, Constant.JWT_TTL);
            System.out.println("JWT：" + jwt);

            System.out.println("\n解密\n");

            Claims c = util.parseJWT(jwt);
            System.out.println(c.getId());
            System.out.println(c.getIssuedAt());
            System.out.println(c.getSubject());
            System.out.println(c.getIssuer());
            System.out.println(c.get("uid", String.class));

        } catch (Exception e) {
            e.printStackTrace();
        }

    }
}
```

**Constant.java**

```java
package com.tingfeng.demo;

import java.util.UUID;

public class Constant {
    public static final String JWT_ID = UUID.randomUUID().toString();

    /**
     * 加密密文
     */
    public static final String JWT_SECRET = "woyebuzhidaoxiediansha";
    public static final int JWT_TTL = 60*60*1000;  //millisecond
}
```

**输出示例**

```
JWT：eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiIxMjM0NTYiLCJzdWIiOiJ7XCJuaWNrbmFtZVwiOlwidGluZ2ZlbmdcIixcIndlY2hhdFwiOlwiYnVsaW5nYnVsaW5nXCIsXCJxcVwiOlwiMTA1Njg1NjE5MVwifSIsInVzZXJfbmFtZSI6ImFkbWluIiwibmlja19uYW1lIjoiWC1yYXBpZG8iLCJpc3MiOiJBbnNvbiIsImV4cCI6MTUyMjMxNDEyNCwiaWF0IjoxNTIyMzEwNTI0LCJqdGkiOiJhNGQ5MjA0Zi1kYjM3LTRhZGYtODE0NS1iZGNmMDAzMzFmZjYifQ.B5wdY3_W4MZLj9uBHSYalG6vmYwdpdTXg0otdwTmU4U

解密

a4d9204f-db37-4adf-8145-bdcf00331ff6
Thu Mar 29 16:02:04 CST 2018
{"nickname":"tingfeng","wechat":"bulingbuling","qq":"1056856191"}
Anson
123456
```

## 总结

**优点**

- 因为json的通用性，所以JWT是可以进行跨语言支持的，像JAVA,JavaScript,NodeJS,PHP等很多语言都可以使用。
- 因为有了payload部分，所以JWT可以在自身存储一些其他业务逻辑所必要的非敏感信息。
- 便于传输，jwt的构成非常简单，字节占用很小，所以它是非常便于传输的。
- 它不需要在服务端保存会话信息, 所以它易于应用的扩展

**安全相关**

- 不应该在jwt的payload部分存放敏感信息，因为该部分是客户端可解密的部分。
- 保护好secret私钥，该私钥非常重要。
- 如果可以，请使用https[协议](https://www.cnblogs.com/wangshouchang/p/9551748.html)

### 参考文章

> http://www.ibloger.net/article/3075.html
>
> jjwt-gitHub：https://github.com/jwtk/jjwt
>
> https://blog.csdn.net/u012240455/article/details/79019825
>
> https://blog.csdn.net/u012017645/article/details/53585872
>
> http://itindex.net/detail/58305-jwt-json-web
>
> http://itindex.net/detail/58305-jwt-json-web
>
> http://itindex.net/detail/58629-json-web-token
>
> https://www.jianshu.com/p/d215e70dc1f9