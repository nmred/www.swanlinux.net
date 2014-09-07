title: 《快学scala》第三章 数组相关操作
date: 2014-09-05 23:13:16
tags: scala
categories: 《快学scala》练习
---

\1. 编写一段代码，将a设置为一个n个随机整数的数组，要求随机数介于0和n之间。

```
object App
{
  def main(args: Array[String]) {
    makeArr(10).foreach(println);
  } 
   
  def makeArr(n : Int) : Array[Int] = {
    val a = new Array[Int](n);
    val rand = new scala.util.Random();
    for (i <- a) yield rand.nextInt(n);
  }                   
}  
```

\2. 编写一个循环，将整数数组中相邻的元素置换。


```
object App
{
  def main(args: Array[String]) {
    val a = Array(1, 2, 3, 4, 5);
    revert(a);
    a.foreach(println);
  } 
  
  def revert(arr : Array[Int]) = {
    for (i <- 0 until (arr.length - 1, 2)) {
      val t = arr(i);
      arr(i) = arr(i + 1);
      arr(i + 1) = t;
    } 
  } 
} 
```

\3. 重复前一个练习，不过这次生成一个新的值交换过的数组。用for/yield。 

```
object App
{
  def main(args: Array[String]) {
    val a = Array(1, 2, 3, 4, 5);
    val b = revertYield(a);
    b.foreach(println);
  }

  def revertYield(arr : Array[Int]) = {
    for (i <- 0 until arr.length) yield {
      if (i < (arr.length - 1) && i % 2 == 0) {
        val t = arr(i);
        arr(i) = arr(i + 1);
        arr(i + 1) = t;
      } 
      arr(i);
    } 
  } 
} 
```

\4.  给定一个整数数组，产出一个新的数组，包含元数组中的所有正值，以原有顺序排列，之后的元素是所有零或负值，以原有顺序排列。 

```
import scala.collection.mutable.ArrayBuffer

object App
{
  def main(args: Array[String]) {
    val a = Array(1, -2, 0, -3, 0, 4, 5);
    val b = sigNumArr(a);
    b.foreach(println);
  }
  def sigNumArr(arr : Array[Int]) = {
    val buf = new ArrayBuffer[Int]();
    buf ++= (for (i <- arr if i > 0) yield i)
    buf ++= (for (i <- arr if i == 0) yield i)
    buf ++= (for (i <- arr if i < 0) yield i)

    buf.toArray
  }
}
```

\5. 如何计算Array[Double]的平均值？ 

```
object App
{
  def main(args: Array[String])  = {
    val a = Array(1.0, -2.0, 0.0, -3.0, 0.0, 4.0, 5.0);
    val b = avgArr(a);
    println(b)
  }

  def avgArr(arr : Array[Double]) = {
    arr.sum / arr.length          
  } 
}
```

\6. 如何重新组织Array[Int]的元素将它们反序排列？对于ArrayBuffer[Int]你又会怎么做呢？  

```
import scala.collection.mutable.ArrayBuffer

object App
{
  def main(args: Array[String])  = {
    val a = Array(1, -2, 0, -3, 0, 4, 5);
    revertArray(a);
    a.foreach(println)
   
    // ArrayBuffer 反转
    val b = ArrayBuffer(1, -2, 0, -3, 0, 4, 5);
    val c = ArrayBuffer[Int]()
    c ++= b.reverse
    c.foreach(println)
  }  
     
  def revertArray(arr : Array[Int]) = {
    for (i <- 0 until (arr.length % 2)) {
      val t = arr(i); 
      arr(i) = arr(arr.length - 1 - i);
      arr(arr.length - 1 - i) = t;
    } 
  } 
}
```

\7. 编写一段代码，产出数组中的所有值，去掉重复项。

```
import scala.collection.mutable.ArrayBuffer

object App
{
  def main(args: Array[String])  = {
    // ArrayBuffer 排重
    val b = ArrayBuffer(1, -2, 0, -3, 0, 4, 5);
    val c = ArrayBuffer[Int]() 
    c ++= b.distinct
    c.foreach(println)
  } 
}
```

\8. 重新编写3.4节结尾的示例。收集负值元素的下标，反序，去掉最后一个下标，然后对每一个下标调用a.remove(i)。比较这样做的效率和3.4节中另外两种方法的效率。 

```
import scala.collection.mutable.ArrayBuffer

object App
{
  def main(args: Array[String])  = {
    val b = Array(1, -2, 0, -3, 0, 4, 5);
    val c = deleteUnFirstF(b)
    c.foreach(println)
  } 
  
  def deleteUnFirstF(arr : Array[Int]) = {
    val indexes = (for (i <- 0 until arr.length if arr(i) < 0) yield i)
    val rights  = indexes.reverse.dropRight(1)
    val tmp = arr.toBuffer
    for (index <- rights) tmp.remove(index)
    tmp 
  }
}
```

\9. 创建一个由java.util.TimeZone.getAvailableIDs返回的时区集合，判断条件是它们在美洲，去掉"America/"前缀并排序。 

```
import scala.collection.mutable.ArrayBuffer
import scala.collection.JavaConversions.asScalaBuffer

object App
{
  def main(args: Array[String])  = {
    var c = timeZoneName()
    c.foreach(println)
  }        
  
  def timeZoneName() = {
    val arr = java.util.TimeZone.getAvailableIDs();
    val tmp = (for (i <- arr if i.startsWith("America/")) yield {
      i.drop("America/".length)
    })
    scala.util.Sorting.quickSort(tmp)
    tmp
  }
}
```
\10. 引入java.awt.datatransfer._并构建一个类型为SystemFlavorMap类型的对象，然后以DataFlavor.imageFlavor为参数调用getNativesForFlavor方法，以Scala缓冲保存返回值。

```
import scala.collection.JavaConversions.asScalaBuffer
import scala.collection.mutable.Buffer
import java.awt.datatransfer._

object App
{
  def main(args: Array[String])  = {
     val flavors = SystemFlavorMap.getDefaultFlavorMap().asInstanceOf[SystemFlavorMap]
     val buf : Buffer[String] = flavors.getNativesForFlavor(DataFlavor.imageFlavor);
     buf.foreach(println);
  }
}
```
