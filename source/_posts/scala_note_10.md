title: 《快学scala》第十章 特质 
date: 2014-09-11 14:42:16
tags: scala
categories: 《快学scala》练习
---

\1. java.awt.Rectangle类有两个很有用的方法translate和grow,但可惜的是像java.awt.geom.Ellipse2D这样的类没有。在Scala中，你可以解决掉这个问题。定义一个RenctangleLike特质,加入具体的translate和grow方法。提供任何你需要用来实现的抽象方法,以便你可以像如下代码这样混入该特质:

```
val egg = new java.awt.geom.Ellipse2D.Double(5,10,20,30) with RectangleLike
egg.translate(10,-10)
egg.grow(10,20)
```

```
import java.awt.geom.Ellipse2D

trait RectangleLike {
  this: Ellipse2D.Double =>
  def translate(x: Double, y: Double) {
    this.x = x
    this.y = y
  } 

  def grow(x: Double, y: Double) {
    this.x += x
    this.y += y
  }
}

object EclipseTest extends App {
  val egg = new java.awt.geom.Ellipse2D.Double(5,10,20,30) with RectangleLike
  egg.translate(10,-10)
  egg.grow(10,20)
  println(egg.getX)
  println(egg.getY)
}
```

\2.  通过把scala.math.Ordered[Point]混入java.awt.Point的方式，定义OrderedPoint类。按辞典编辑方式排序，也就是说，如果x\<x'或者x=x'且y\<y'则(x,y)\<(x',y') 

```
class OrderedPoint(x : Int, y : Int) extends java.awt.Point(x, y) with scala.math.Ordered[OrderedPoint]
{
  def compare(that : OrderedPoint) : Int = {
    if (this.x == that.x && this.y == that.y) {
      0
    } else if ((this.x < that.x || this.x == that.x) && this.y < that.y) {
      -1
    } else {
      1
    }
  }
}

object TestTrait extends App
{
  val test = Array(new OrderedPoint(3, 4), new OrderedPoint(4, 5));
  scala.util.Sorting.quickSort(test)
  test.foreach((p : OrderedPoint) => {println(p)})
  val p1 = new OrderedPoint(3, 4);
  val p2 = new OrderedPoint(4, 5);

  println(p2 > p1)

}
```

\3.  查看BitSet类,将它的所有超类和特质绘制成一张图。忽略类型参数([…]中的所有内容)。然后给出该特质的线性化规格说明

略 

\4. 提供一个CryptoLogger类，将日志消息以凯撒密码加密。缺省情况下密匙为3，不过使用者也可以重写它。提供缺省密匙和-3作为密匙是的使用示例

```
trait Logger {
  def log(str: String, key: Int = 3) : String
}

class CryptoLogger extends Logger {
  def log(str: String, key: Int) : String = {
    for ( i <- str) yield if (key >= 0) (97 + ((i - 97 + key)%26)).toChar else (97 + ((i - 97 + 26 + key)%26)).toChar
  }
}    

object CryptoLoggerTest extends App {
  val text = "nmred"
  println(text)
  println(new CryptoLogger().log(text))
  println(new CryptoLogger().log(text, -3))
} 
```

\5. JavaBean规范里有一种提法叫做属性变更监听器(property change listener)，这是bean用来通知其属性变更的标准方式。PropertyChangeSupport类对于任何想要支持属性变更通知其属性变更监听器的bean而言是个便捷的超类。但可惜已有其他超类的类—比如JComponent—必须重新实现相应的方法。将PropertyChangeSupport重新实现为一个特质,然后将它混入到java.awt.Point类中

```
import java.awt.Point
import java.beans.PropertyChangeSupport

trait PropertyChange extends PropertyChangeSupport

val p = new Point() with PropertyChange
```
