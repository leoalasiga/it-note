## java白皮书

+ 简单性
+ 面向对象
+ 分布式
+ 健壮性
+ 安全性
+ 体系结构中立
+ 可移植性
+ 解释型
+ 高性能
+ 多线程
+ 动态性





## java的基本程序设计结构

### 一个简单的java应用程序

```java
public class FirstSample
{
    public static void main(String[] args) {
        System.out.println("Hello world!");
    }
}
```

+ **public:**访问修饰符,用来控制程序的其他部分对这段代码的访问级别
+ **class:**表名java程序的全部内容都包含在这个类中
+ **FirstSample:**类名,驼峰式,字母开头,后面可以是字母和数字的组合,但不能是java保留字
+ **main:**main方法只能用public修饰
+ **{}**:用大括号划分程序的各部分
+ `;` :java以分号代表一句话结束
+ `.`:点号用于调用方法,java的固定语法为object.method(parameters)



### 注释

+ //... 
+ /* ... */
+ /** ...  */



### 数据类型

> 8种基本类型

+ 整数型
  + byte
  + short
  + int
  + long :要带后缀L或l
+ 浮点型(浮点数不能用于金融运算,因为浮点数使用二进制表示的)
  + float :要带后缀F或f
  + double 
    + 浮点运算遵循IEEE 754规范,下面是表示溢出或出错的三个特殊的浮点数
      + 正无穷大:Double.POSITIVE_INFINITY
      + 负无穷大:Double.NEGATIVE_INFINITY
      + NaN(不是一个数字):Double.NaN
    + 注意不能使用x==Doube.NaN检测是否等于NaN,得调用Double.isNaN(x)来判断
+ 布尔型
  + boolean:false和true
+ 字符型
  + char:表示单个字符



### 变量

> ​	类型(type) + 变量名(name)

+ 变量的初始化
  + 声明一个变量后,用赋值语句对变量进行显示初始化,不能使用未初始化的变量
+ 常量
  + 利用关键字`final`指示常量,关键字final表示这个变量只能被赋值一次,一旦赋值,不能更改,习惯上常量名用大写
  + 