title: 《快学scala》第四章 映射和元组
date: 2014-09-08 02:13:16
tags: scala
thumbnail: /thumbnail/scala_image.png
categories: 《快学scala》练习
---

\1.设置一个映射，其中包含你想要的一些装备，以及它们的价格。然后构建另一个映射，采用同一组键，但在价格上打9折。
 
```
object MapApp
{
  def main(args: Array[String])  = {
    val produce : Map[String, Int] = Map("test1" -> 10, "test2" -> 300);
    val result = (for ((k, v) <- produce) yield {
      (k, v * 0.9)
    })
   
    for ((k, v) <- result) {
      println(k);
      println(v);
    }
  }
} 
```

\2. 编写一段程序，从文件中读取单词。用一个可变映射来清点每一个单词出现的频率。 

```
object MapApp
{
  def main(args: Array[String])  = {
    charCount()
  }

  def charCount() = {
    val in  = new java.util.Scanner(new java.io.File("/tmp/test.txt"));
    val map = new scala.collection.mutable.HashMap[String, Int]();
    while (in.hasNext()) {
      val str = in.next();
      map(str) = map.getOrElse(str, 0) + 1;
    }

    println(map.mkString(","));
  }
}
```

\3. 重复前一个练习，这次用不可变的映射。 

```
object MapApp
{
  def main(args: Array[String])  = {
    charCount()
  }

  def charCount() = {
    val in  = new java.util.Scanner(new java.io.File("/tmp/test.txt"));
    val map = Map[String, Int]();
    var m   = map
    while (in.hasNext()) {
      val str = in.next();
      m += (str -> (m.getOrElse(str, 0) + 1));
    }

    println(m.mkString(","));
  }
}
```

\4. 重复前一个练习，这次用已排序的映射，以便单词可以按顺序打印出来。 

```
object MapApp
{
  def main(args: Array[String])  = {
    charCount()
  } 
    
  def charCount() = {
    val in  = new java.util.Scanner(new java.io.File("/tmp/test.txt"));
    val map = scala.collection.immutable.SortedMap[String, Int]();
    var m   = map;
    while (in.hasNext()) {
      val str = in.next();
      m += (str -> (m.getOrElse(str, 0) + 1));
    }
    
    println(m.mkString(","));
  }
}
```

\5. 重复前一个练习，这次用java.util.TreeMap并使之适用于Scala API。 

```
import scala.collection.JavaConversions.mapAsScalaMap

object MapApp
{
  def main(args: Array[String])  = {
    charCount()
  }

  def charCount() = {
    val in  = new java.util.Scanner(new java.io.File("/tmp/test.txt"));
    val map : scala.collection.mutable.Map[String, Int] = new java.util.TreeMap[String, Int];
    while (in.hasNext()) {
      val str = in.next();
      map(str) = (map.getOrElse(str, 0) + 1);
    }
    
    println(map.mkString(","));
  } 
} 
```

\6. 定义一个链式哈希映射，将“Monday”映射到java.util.Calendar.MONDAY，依此类推加入其他日期。展示元素是以插入的顺序被访问的。 

```
object MapApp
{
  def main(args: Array[String])  = {
    val map = new scala.collection.mutable.LinkedHashMap[String, Int]();
    map("Monday")    = java.util.Calendar.MONDAY;
    map("Tuesday")   = java.util.Calendar.TUESDAY;
    map("Wednesday") = java.util.Calendar.WEDNESDAY;
    map("Thursday")  = java.util.Calendar.THURSDAY;
    map("Friday")    = java.util.Calendar.FRIDAY;
    map("Saturday")  = java.util.Calendar.SATURDAY;
    map("Sunday")    = java.util.Calendar.SUNDAY;
    
    println(map.mkString(","))
  }
}
```

\7. 打印出所有Java系统属性的表格。 

```
import scala.collection.JavaConversions.propertiesAsScalaMap
object MapApp
{
  def main(args: Array[String])  = {
    val props : scala.collection.Map[String, String] = System.getProperties()
    var len = 0;
    for ((i, _) <- props) {
      if (len < i.length) {
        len = i.length
      }        
    }          

    for ((k, v) <- props) {
      print(k)
      print(" " * (len - k.length))
      print(" | ")
      println(v)
    }
  }
}
```

\8. 编写一个函数minmax(values: Array[Int]），返回数组中最小值和最大值的对偶。

```
object MapApp
{
  def main(args: Array[String])  = {
    val test = Array(1, 2, 3, 4, 5)
    val result = minmax(test)
    println(result._1)
    println(result._2)
  } 
  
  def minmax(values : Array[Int]) = {
    val max = values.max
    val min = values.min
    (max, min)
  }
}
```

\9. 编写一个函数lteqgt(values: Array[Int], v: Int)，返回数组中小于v，等于v和大于v的数量，要求三个值一起返回。 

```
object MapApp
{
  def main(args: Array[String])  = {
    val test = Array(1, 2, 3, 4, 5)
    val result = lteqgt(test, 3)
    println(result)
  } 
  
  def lteqgt(values : Array[Int], n : Int) = {
    var lt, eq, gt = 0
    for (v <- values) {
      if (v > n) {
        gt += 1; 
      } else if (v < n) {
        lt += 1;
      } else {
        eq += 1;
      } 
    } 
    
    (lt, eq, gt)
  } 
}
```

\10. 当你将两个字符串拉链在一起，比如"Hello".zip("World")，会是什么结果？想出一个讲得通的用例。 

```
object MapApp
{
  def main(args: Array[String])  = {
    var t1 = "hello".zip(" world");
    var t2 = "ab".zip("cdef");
    var t3 = "abc".zip("d");
    println(t1)
    println(t2)
    println(t3)
  }
}

```

运行结果:

```
Vector((h, ), (e,w), (l,o), (l,r), (o,l))
Vector((a,c), (b,d))
Vector((a,d))
```
