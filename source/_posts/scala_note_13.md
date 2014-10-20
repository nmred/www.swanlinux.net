title: 《快学scala》第十三章 集合 
date: 2014-10-19 14:42:16
tags: scala
categories: 《快学scala》练习
---

\1. 编写一个函数，给定字符串，产出一个包含所有字符的下标的映射。举例来说，indexes("Mississippi")应返回一个映射，让'M'对应集{0}，'i' 对应集{1, 4, 7, 10}，依次类推。使用字符到可变集的映射。另外，你如何保证集是经过排序的？

```
import scala.collection.mutable.{HashMap, SortedSet}
                                         
object indexesTest extends App {         
  def indexes(str: String) : HashMap[Char, SortedSet[Int]] = {
    var i = 0
    var map = new HashMap[Char, SortedSet[Int]]();
    str.foreach{
      item => {
        map.get(item) match {
          case Some(result) => map(item) = result + i
          case None => map += (item -> SortedSet(i))
        }                             
      }                               

      i += 1
    }                 

    map
  }

  println(indexes("Mississippi"))
}
```

\2. 重复前一个练习，这次用字符列表的不可变映射。

```
import scala.collection.mutable.ListBuffer
import scala.collection.immutable.HashMap

object listBufferTest extends App {
  def indexes(str: String): HashMap[Char, ListBuffer[Int]] = {
    var map = new HashMap[Char, ListBuffer[Int]]()
    var i = 0
    str.foreach{
      item => {
        map.get(item) match {
          case Some(result) => result += i
          case None => map += (item -> ListBuffer(i))
        }
      }
      i += 1
    }

    map
  }

  println(indexes("Mississippi"))
}
```

\3. 编写一个函数，从一个整型链表中去除所有零值。

```
object listFilterTest extends App {
  def listFilter(list: List[Int]) : List[Int] = {
    list.filter(_ != 0)
  }

  println(listFilter(List(0, 2, 3, 4, 5, 0, 9)))
} 
```

\4. 编写一个函数，接受一个字符串的集合，以及一个从字符串到整数值的映射。举例来说，给定Array("Tom", "Fred", "Harry") 和 Map("Tom" -> 3, "Dick" -> 4, "Harry" -> 5), 返回Array(3, 5)。提示：用flatMap将get返回的Option值组合在一起。

```
object flatMapTest extends App {
  def find(src: Array[String], map: Map[String, Int]) : Array[Int] = {
    src.flatMap(map.get(_))
  }

  println(find(Array("Tom", "Fred", "Harry"), Map("Tom" -> 3, "Dick" -> 4, "Harry" -> 5)).mkString(","))
}
```

\5. 实现一个函数，作用与mkString相同，使用reduceLeft。

```
object mkStringTest extends App {
  val test =  new scala.collection.mutable.ArrayBuffer[String]() with myMkString
  test += "test"
  test += "test111"
  println(test.myMkString)
}        
         
trait myMkString {
  this: scala.collection.mutable.Iterable[String] =>
  def myMkString = if (this != Nil) this.reduceLeft(_ + _)
} 
```

\6. 给定整型列表lst, (lst :\ List[Int]())(\_ :: \_)得到什么？(List[Int]() /: lst)(\_ :+ \_)又得到什么？如何修改它们中的一个，以对原列表进行反向排列？

```
object listTest extends App {
  val lst = List(1, 2, 3, 4, 5)
  // 从集合尾部开始折叠
  // 新的集合中添加元素到头部
  // 结果：List(1, 2, 3, 4, 5)
  println((lst :\ List[Int]())(_ :: _)) 

  // 从集合头部开始折叠
  // 新的集合中在尾部追加一个元素
  // 结果： List(1, 2, 3, 4, 5)
  println((List[Int]() /: lst)(_ :+ _))

  // 反向排序
  println((lst :\ List[Int]())((a, b) => b :+ a))

  println((List[Int]() /: lst)((a, b) => b :: a))
}
```

\7. 在13.11 节中，表达式(prices zip quantities) map {p => p.\_1 \* p.\_2} 有些不够优雅。我们不能用(prices zip quantities) map (\_ * \_)，因为 \_ \* \_是一个带两个参数的函数，而我们需要的是一个带单个类型为元组为参数的函数。将tupled应用于乘法函数，以便我们可以用它来映射由对偶组成的的列表

```
object tupledTest extends App {
  val prices = List(5.0,20.0,9.95)
  val quantities = List(10,2,1)
  println((prices zip quantities) map { Function.tupled(_ * _) })
}
```

\8. 编写一个函数，将Double数组转化为二维数组。传入列数作为参数。举例来说，Array(1, 2, 3, 4, 5, 6)和三列，返回Array(Array(1, 2, 3), Array(4, 5, 6))。用grouped方法。

```
object groupedTest extends App {
  def groupArr(arr: Array[Int]): Array[Array[Int]] = {
    arr.grouped(3).toArray
  }    
  val test = Array(1, 2, 3, 4, 5, 6)
  groupArr(test).foreach(item => {
      println("=========")
      item.foreach(println)
  })  
} 
```

\9. Harry Hacker 写了一个从命令行接收一系列文件名的程序，对每个文件名，他都启动一个新的线程来读取文件内容并更新一个字母出现频率映射，声明为：

```
val frequencies = new scala.collection.mutable.HashMap[Char, Int] with scala.collection.mutable.SynchronizedMap[Char, Int]
```

当读到字母c时，他调用

```
frequencies(c) = frequencies.getOrElse(c, 0) + 1
```

为什么这样做得不到正确答案？如果他用如下方式实现呢：

```
import scala.collection.JavaConversions.asScalaConcurrentMap

val frequencies: scala.collection.mutable.ConcurrentMap[Char, Int] = new java.util.concurrent.ConcurrentMap[Char, Int]
```

```
并发问题，并发修改集合不安全.修改后的代码和修改前的代码没有什么太大的区别.
```

\10. Harry Hacker 把文件读取到的字符串中，然后想对字符串的不同部分用并行集合来并发更新字母出现频率映射。他用了如下代码：

```
val frequencies = new scala.collection.mutable.HashMap[Char, Int]
for (c <- str.par) frequencies(c) = frequencies.getOrElse(c, 0) + 1
```

为什么说这个想法很糟糕？要真正地并行化这个计算，他应该怎么做呢？（提示：用aggregate） 


```
并行修改共享变量，结果无法估计。
```

```
import scala.collection.immutable.HashMap
object parTest extends App {
  val str = "aaabbbcccaaassssccc"
  
  val frequencies = str.par.aggregate(HashMap[Char, Int]())(
    (map, item) => {
      map + (item -> (map.getOrElse(item, 0) + 1))
    },
    (map1, map2) => {
      (map1.keySet ++ map2.keySet).foldLeft(HashMap[Char, Int]())(
        (result, k) => {
          result + (k -> (map1.getOrElse(k, 0) + map2.getOrElse(k, 0)))
        }  
      ) 
    } 
  ) 
  
  println(frequencies)
}
```

