title: 《快学scala》第七章 包和引入
date: 2014-09-09 11:40:16
tags: scala
categories: 《快学scala》练习
---


\1. 编写示例程序，展示为什么
package com.horstmann.impatient
不同于
package com
package horstmann
package impatient

```
// 假如有这样一个包
package com {
  object Test1{}
  package horstmann {
    object Test2 {}
    package impatient {
      object Test3 {}
    }       
  }         
}

```

```
package com
package horstmann
package impatient

object Test4 {
  val x = Test1 // 可以访问
  val y = Test2 // 可以访问
  val z = Test3 // 可以访问
}
```


```
package com.horstmann.impatient

object Test4 {
  val x = Test1 // 不可以访问
  val y = Test2 // 不可以访问
  val z = Test3 // 可以访问
} 
```

\2. 编写一段让你的Scala朋友们感到困惑的代码，使用一个不在顶部的com包。 

```
package com.horstmann.impatient {
  object Funcy {
    def foo {
      println("top level com");
    }
  }
}
package scala.com.horstmann.impatient {
  object Funcy {
    def foo {
      println("not top level com");
    }
  }
}

import scala._ // 如果去掉用输出 "top level com" , 否则输出 "not top level com"
object ScalaApp1 {
  def main(args : Array[String]) {
    com.horstmann.impatient.Funcy.foo
  }
}
```

\3. 编写一个包random，加入函数nextInt():Int、nextDouble: Double和setSeed(seed:Int):Unit。生成随机数的算法使用线性同余生成器：
 后值=(前值 x * a + b) mod 2^n
其中，a=1664525，b=1013904223，n=32，前值的初始值为seed。

```
package random {
  package object random {
    val a : Long = 1664525;
    val b : Long = 1013904223;
    val n : Int = 32;
    var prev : Int = 1;

    def nextInt() : Int = {
      val rand = (prev * a + b) % n
      setSeed(rand.toInt)
      rand.toInt  
    }             
                  
    def setSeed(seed : Int) : Unit = {
      this.prev = seed 
    } 
    
    def nextDouble() : Double = {
      nextInt.toDouble / n 
    } 
  } 
} 

object TestRandom {
  def main(args : Array[String]) {
    import random._
    random.setSeed(999);
    for (_ <- 1.to(100, 1)) {
      println(random.nextInt);
    } 
    for (_ <- 1.to(100, 1)) {
      println(random.nextDouble);
    } 
  } 
} 
```

\4. 在你看来，Scala的设计者为什么要提供package object语法而不是简单地让你将函数和变量添加到包中呢？ 

这是因为Java虚拟机的局限  

\5. private[com] def giveRaise(rate:Double)的含义是什么？有用吗？

限制giveRaise函数在com包内可见  

\6. 编写一段程序，将Java哈希映射中的所有元素拷贝到Scala哈希映射。用引入语句重命名这两个类。

```
import java.util.{HashMap => JavaHashMap}
import scala.collection.JavaConversions.mapAsScalaMap
import scala.collection.mutable.{Map => ScalaHashMap}

object TestMap7 {
  def main(args : Array[String]) {
    var map = new JavaHashMap[String, Int]();
    map.put("test1", 1);
    map.put("test2", 3);
    map.put("test3", 5);

    val m2 : ScalaHashMap[String, Int] = map;
    println(m2.mkString(","))
  }         
}  
```

\7. 在前一个练习中，将所有引入语句移动到尽可能小的作用域里。 

```
object TestMap7 {
  def main(args : Array[String]) {
    import java.util.{HashMap => JavaHashMap}
    import scala.collection.JavaConversions.mapAsScalaMap
    import scala.collection.mutable.{Map => ScalaHashMap}
    
    var map = new JavaHashMap[String, Int]();
    map.put("test1", 1);
    map.put("test2", 3);
    map.put("test3", 5);

    val m2 : ScalaHashMap[String, Int] = map;
    println(m2.mkString(","))
  }
}
```

\8. 以下代码的作用是什么？这是个好主意吗？
import java._
import javax._

```
完全引入java和javax包的所有成员，在编写代码时可以使用更短的名称。  
从多个源引入大量名称总是让人担心，会增加名称冲突的风险，通过将引入放置在需要这些引入的地方，可以大幅减少可能的名称冲突。 
```

\9. 编写一段程序，引入java.lang.System类，从user.name系统属性读取用户名，从Console对象读取一个密码，如果密码不是"secret"，则在标准错误流中打印一个消息，如果密码是“secret”，则在标准输出流中打印一个问候消息。不要使用任何其他引入，也不要使用任何限定词（带句点的那种）。

```
import java.lang.System.getProperty
import java.lang.System.err.{println => perror}

object TestErr {
  def main(args : Array[String]) {
    val name = getProperty("user.name");
    print("password:");
    if (readLine() == "secret") {
      println("welcome, " + name);
    } else {
      perror("wrong password");
    } 
  } 
}
```
