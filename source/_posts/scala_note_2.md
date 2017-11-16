title: 《快学scala》第二章 控制结构和函数
date: 2014-09-05 15:13:16
tags: scala
categories: 《快学scala》练习
thumbnail: /thumbnail/scala_image.png
---

\1. 一个数字如果为正数，则它的signum为1；如果是负数，则signum为-1；如果是0，则signum为0.编写一个函数来计算这个值。

```
def signum(x : Int) : Int = {
     if (x > 0) { 
       1
     } else if (x == 0) {
       0
     } else {
       -1
     } 
} 
``` 

\2. 一个空的块表达式{}的值是什么？类型是什么？ 

没有值
类型为 Unit

\3. 指出在Scala中何种情况下赋值语句x = y = 1是合法的。（提示：给x找个合适的类型定义。）

x 为 Unit 类型

\4. 针对下列Java循环编写一个scala版, for (int i = 10; i >= 0; i--) System.out.println(i);

```
def forTest(x : Int) = {
  for (i <- x.to(0, -1)) {
	println(i);
  }
}
```

\5. 编写一个过程countdown(n:Int)，打印从n到0的数字

```
object App
{
	def main(args: Array[String]) {
	  countdown(10);
	} 

	def countdown(x : Int) = {
	  for (i <- x.to(0, -1)) {
		println(i);
	  } 
	} 
} 
```

\6. 编写一个for循环，计算字符串中所有字母的Unicode代码的乘积。 

```
object TestWDO
{
  def main(args : Array[String]) {
      val str = "hello";
      var result = 1;
      for (i <- str) {
        result *= i.toInt
      }

      println(result);
  }
}
```

\7. 同样是解决前一个练习的问题，但这次不使用循环。 

```
object TestWDO
{
  def main(args : Array[String]) {
      val str = "hello";
      var result = 1;
      str.foreach(result *= _.toInt)
      println(result);
  }
}
```

\8. 编写一个函数product(s: string)，计算前面练习中提过的乘积。 

```
object TestWDO
{
  def main(args : Array[String]) {
      val str = "hello";
      var result = 1;
      result = product(str)
      println(result);
  }           
  
  def product(s : String) = {
    s.map(_.toInt).product
  }
}
```

\9. 把前一个练习中的函数改成递归函数。 

```
object TestWDO
{
  def main(args : Array[String]) {
      val str = "hello";
      var result = 1;
      result = product(str)
      println(result);
  }           
  
  def product(s : String) : Int = {
    if (s.length == 1) {
      s(0).toInt
    } else {
      s(0).toInt * product(s.substring(1));
    }
  } 
} 
```
