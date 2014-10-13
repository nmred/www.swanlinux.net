title: 《快学scala》第十一章 操作符 
date: 2014-10-13 14:42:16
tags: scala
categories: 《快学scala》练习
---

\1. 根据优先级规则， 3 + 4 -> 5 和 3 -> 4 + 5 是如何被求值的？

\2. BigInt 类有一个pow方法，但没有用操作符字符，Scala类库的设计者为什么没有选用\*\*（像Fortran那样）或者^(像Pascal那样)作为乘方操作符呢？

\3. 实现Fraction类，支持 + - * / 操作，支持约分, 例如将 15 / -6 变成 -5 / 2。除以最大公约数，像这样：

```
class Fraction(n : Int, d: Int) {
  private val num : Int = if (d == 0) 1 else n * sign(d) / gcd(n, d);
  private val den : Int = if (d == 0) 0 else d * sign(d) / gcd(n, d);

  override def toString = num + "/" + den;

  def sign(a : Int) = if (a > 0) 1 else if (a < 0) -1 else 0

  def gcd(a: Int, b: Int) : Int = if (b == 0) a.abs else gcd(b, a % b)
}
```

```
class Fraction(n : Int, d: Int) {
  private val num : Int = if (d == 0) 1 else n * sign(d) / gcd(n, d);
  private val den : Int = if (d == 0) 0 else d * sign(d) / gcd(n, d);

  override def toString = num + "/" + den;

  def sign(a : Int) = if (a > 0) 1 else if (a < 0) -1 else 0

  def gcd(a: Int, b: Int) : Int = if (b == 0) a.abs else gcd(b, a % b)

  def +(a: Fraction) : Fraction = {
    return new Fraction(this.num * a.den + a.num * this.den, this.den * a.den);
  } 
  
  def -(a: Fraction) : Fraction = {
    return new Fraction(this.num * a.den - a.num * this.den, this.den * a.den);
  } 
  
  def *(a: Fraction) : Fraction = {
    return new Fraction(this.num * a.num , this.den * a.den);
  } 
  
  def /(a: Fraction) : Fraction = {
    return new Fraction(this.num * a.den , this.den * a.num);
  } 
} 

object FractionTest extends App {
  val num1 = new Fraction(3, 4);
  val num2 = new Fraction(1, 2);
  
  println(num1);
  println(num2);
  println(num1 + num2);
  println(num1 - num2);
  println(num1 * num2);
  println(num1 / num2);
} 
```

\4. 实现一个Money类，加入美元和美分字段。提供 +、-操作符已经比较操作符==和\< 。举例来说，Money(1, 75) + Money(0, 50) == Money(2, 25) 应为true, 你应该同时提供 \* 和 / 操作符吗？为什么？

```
class Money(private val d: Int, private val c: Int) {
  private var dollars = d;

  private val cents = {
    if (c >= 100) {
      dollars += c / 100
      c % 100
    } else if (c < -100) {
      dollars -= c / 100
      c % 100
    } else {
      c
    }
  } 
  
  override def toString = {
    "(" + dollars + "," + cents + ")"
  } 
  
  def +(a: Money) = {
    new Money(this.dollars + a.dollars, this.cents + a.cents);
  } 
  
  def -(a: Money) = {
    new Money(this.dollars - a.dollars, this.cents - a.cents);
  } 
  
  def ==(a: Money) = {
    (this.dollars * 100 + this.cents) == (a.dollars * 100 + a.cents)
  } 
  
  def <(a: Money) = {
    (this.dollars * 100 + this.cents) < (a.dollars * 100 + a.cents)
  } 
}

object Money {
  def apply(d: Int, c: Int) = new Money(d, c);
  
  def unapply(o: Money) = {
    Some((o.dollars, o.cents))
  } 
} 

object MoneyTest extends App {
  val c = Money(2, 175);
  val Money(a: Int, b: Int) = c

  println(a)
  println(Money(1, 75) + Money(0, 50) == Money(2, 25))
}
```

对于美元操作乘、除是没有意义.

\5. 提供操作符用于构造HTML表格。例如：

```
	Table() | "Java" | "Scala" || "Gosling" | "Odersky" || "JVM" | "JVM, .NET"
```

应产出：

```
<table><tr><td>Java</td><td>Scala</td></tr><tr><td>Gosling</td><td>Odersky</td></tr><tr><td>JVM</td><td>JVM, .NET</td></tr></table>
```

```
import scala.collection.mutable.ArrayBuffer

class Table
{
  private val trTags : ArrayBuffer[String] = ArrayBuffer();
  private val tdTags : ArrayBuffer[String] = ArrayBuffer();

  def |(str: String) = {
    tdTags += str
    this
  }

  def ||(str: String) : Table= {
    trTags += "<tr><td>" + tdTags.mkString("</td><td>") + "</td><tr>"
    tdTags.clear()     
    tdTags += str
    this
  }

  override def toString = {
    if (!tdTags.isEmpty) {
      trTags += "<tr><td>" + tdTags.mkString("</td><td>") + "</td><tr>"
    } 
    
    "<table>" + trTags.mkString("")+ "</table>"
  } 
} 

object Table {
  def apply() = new Table()
} 

object TableTest extends App {
  val str = Table() | "Java" | "Scala" || "Gosling" | "Odersky" || "JVM" | "JVM, .NET"
  println(str)
} 
```

\6. 提供一个ASCIIArt 类，其对象包含类似这样的图形：

```
 /\_/\
( ' ' )
(  _  )
 | | |
(__|__)
``` 

提供将两个ASCIIArt图形横向或纵向结合的操作符，选用适当优先级的操作符命名。横向结合的实例：

```
 /\_/\    -----
( ' ' ) / Hello \
(  _  )<  Scala |
 | | |  \ Coder /
(__|__)   -----
```

\7. 实现一个BigSequence 类，将64个bit的序列包在一个Long值中。提供apply和update操作来获取和设置某个位置具体的bit


\8. 提供一个Matrix类---你可以选择需要的是一个2x2的矩阵，任意大小的正方形矩阵，或是mxn的矩阵。支持+和\*操作。\*操作应同样适用于单值，例如 mat \* 2. 单个元素可以通过 mat(row,col)得到

```
import scala.collection.mutable.ArrayBuffer
class Matrix(private val data: Array[Int], private val nrow: Int){
  private val matrixData : Array[Array[Int]] = {
    val cols = (data.length.toFloat / nrow).ceil.toInt
    val result : Array[Array[Int]] = Array.ofDim[Int](nrow, cols);
    for (i <- 0 until nrow) {
      for (j <- 0 until cols) {
        val index = i*cols + j
        result(i)(j) = if (data.isDefinedAt(index)) data(index) else 0
      }
    }
    result
  }

  override def toString = {
    var str = ""
    matrixData.map((p: Array[Int]) => {
      p.mkString(",")
    }).mkString("\n")
  }

  def *(a: Matrix) = {
    val data: ArrayBuffer[Int] = ArrayBuffer();
    for (i <- 0 to  a.matrixData.length - 1) {
      for (j <- 0 to a.matrixData(0).length - 1) {
        data += a.matrixData(i)(j) * this.matrixData(i)(j)
      }
    }

    new Matrix(data.toArray, a.matrixData.length)
  }

  def *(a: Int) = {
    val data: ArrayBuffer[Int] = ArrayBuffer();
    for (i <- 0 to  this.matrixData.length - 1) {
      for (j <- 0 to this.matrixData(0).length - 1) {
        data += this.matrixData(i)(j) * a 
      }
    }

    new Matrix(data.toArray, this.matrixData.length)
  }

  def +(a: Matrix) = {
    val data: ArrayBuffer[Int] = ArrayBuffer();
    for (i <- 0 to  this.matrixData.length - 1) {
      for (j <- 0 to this.matrixData(0).length - 1) {
        data += this.matrixData(i)(j) + a.matrixData(i)(j)
      }
    }

    new Matrix(data.toArray, this.matrixData.length)
  }

  def mat(row: Int, col: Int) = {
    matrixData(row - 1)(col - 1)
  }
}

object MatrixTest extends App {
  val m = new Matrix(Array(1,2,3,4), 3)
  val n = new Matrix(Array(1,2,3,4), 3)
  println(m * n)
  println(m + n)
  println(m.mat(2, 2))
  println(n * 10)
}
```

\9. 为RichFile 类定义unapply操作，提取文件路劲、名称和扩展名。举例来说，文件/home/cay/readme.txt的路劲为/home/cay, 名称为 readme, 扩展名txt

```
import java.io.File
object RichFile { 

  def unapply(filePath : String) = {
    val file = new File(filePath)
    val ext = file.getName.split("\\.")
    Some((file.getParent, file.getName, ext(1)))
  }                                    
}                                      

object RichFileTest extends App {
  val RichFile(path, fileName, ext) = "/home/cay/readme.txt"
  println(path)
  println(fileName)
  println(ext)
} 
```

\10. 为RichFile 类定义一个unapplySeq, 提取所有路阶段。举例来说，对于/home/cay/readme.txt,你应该产出三个路劲的序列: home，cay,readme.txt

```
object RichFile {
  def unapplySeq(filePath : String) : Option[Seq[String]]= {
    Some(filePath.trim.split("\\/"))
  } 
} 

object RichFileTest extends App {
  val str = "/home/cay/readme.txt"
  str match {
    case RichFile(str0, str1, str2, str3) => {
      println(str1);
      println(str2);
    } 
    case _ => {println(str)}
  } 
} 
```
