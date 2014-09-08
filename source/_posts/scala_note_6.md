title: 《快学scala》第六章 对象
date: 2014-09-08 13:56:16
tags: scala
categories: 《快学scala》练习
---

\1. 编写一个Conversions对象，加入inchesToCentimeters、gallonsToLiters和milesToKilometers方法。 

```
object Conversions
{
  def inchesToCentimeters(value : Double) = {
    value * 2.54
  }

  def gallonsToLiters(value : Double) = {
    3.78541178 * value
  }

  def milesToKilometers(value : Double) = {
    1.609344 * value
  }
} 

object TestApp
{
  def main(args : Array[String]) {
    println(Conversions.inchesToCentimeters(3));
  }
}
```

\2. 前一个练习不是很面向对象，提供一个通用的超类UnitConversion并定义扩展该超类的InchesToCentimeters、GallonsToLiters和MilesToKilometers对象。

```
abstract class UnitConversion
{
  def convert(value : Double) : Double
}

object inchesToCentimeters extends UnitConversion
{
  def convert(value : Double) = {
    value * 2.54
  }
}

object gallonsToLiters extends UnitConversion
{
  def convert(value : Double) = {
    value * 3.78541178
  } 
}
     
object milesToKilometers extends UnitConversion
{
  def convert(value : Double) = {
    value * 1.609344
  } 
} 


object TestApp
{
  def main(args : Array[String]) {
    println(inchesToCentimeters.convert(3));
  }
}
```

\3. 定义一个扩展自java.awt.Point的Origin对象。为什么说这实际上不是个好主意？（仔细看Point类的方法） 

```
object Origin
{
  def apply() = new java.awt.Point()
}

object TestApp
{
  def main(args : Array[String]) {
    println(Origin());
  } 
}
```

\4. 定义一个Point类和一个伴生对象，使得我们可以不用new而直接用Point(3,4)来构造Point实例。 

```
class Point(val x : Int, val y : Int) {

}
object Point
{
  def apply(x : Int, y : Int) = new Point(x, y)
}

object TestApp
{
  def main(args : Array[String]) {
    val p = Point(3, 4);
    println(p.x)
  } 
} 
```

\5. 编写一个Scala应用程序，使用App特质，以反序打印命令行参数，用空格隔开。 

```
object TestApp extends App
{
  println(args.reverse.mkString(","))
} 
```

\6. 编写一个扑克牌4种花色的枚举，让其toString方法分别返回♣、♦、♥和♠。 

```
object TestApp extends App
{
  for(c <- EnumTest.values) {
    println(c.toString)
  }
}                  
                   
object EnumTest extends Enumeration
{
  val Club = Value(0, "♣")
  val Diomand = Value(1, "♦")
  val Heart = Value(2, "♥")
  val Spade = Value(3, "♠))
}
```

\7. 编写一个函数，检查某张牌的花色是否为红色。 

```
object TestApp extends App
{
  for(c <- EnumTest.values) {
    println(c.toString)
    println(check(c))
  }

  def check(card : EnumTest.Value) = {
    if (card == EnumTest.Heart) {
      true
    } else {
      false
    }
  }
}

object EnumTest extends Enumeration
{
  val Club = Value(0, "♣")
  val Diomand = Value(1, "♦")
  val Heart = Value(2, "♥")
  val Spade = Value(3, "♠")
}
```

\8. 编写一个枚举，描述RGB立方体的8个角。ID使用颜色值（例如，红色是0xff0000）。 

```
object RGBCube extends Enumeration {
  val R = Value(0xff0000)
  val G = Value(0x00ff00)
  val B = Value(0x0000ff)
  val RG = Value(0xffff00)
  val RB = Value(0xff00ff)
  val GB = Value(0x00ffff)
  val RGB = Value(0xffffff)
  val BLACK = Value(0x000000)
} 

object ScalaApp {
  def main(args: Array[String]) {
    for (c <- RGBCube.values) { 
      printf("#%06x\n", c.id) 
    } 
  } 
} 
```
