title: 《快学scala》第八章 继承
date: 2014-09-09 14:51:16
tags: scala
categories: 《快学scala》练习
---

\1. 扩展入校的BankAccount类，新类CheckingAccount 对每次存款和取款都收取1美元的手续费

```
class BankAccount(initialBalance : Double) {
  private var balance = initialBalance

  def deposit (amount : Double) = {
    balance += amount
    balance
  }

  def withdraw(amount : Double) = {
    balance -= amount
    balance
  }
}
```

```
class BankAccount(initialBalance : Double) {
  private var balance = initialBalance

  def deposit (amount : Double) = {
    balance += amount
    balance
  }

  def withdraw(amount : Double) = {
    balance -= amount
    balance
  }
}

class CheckingAccount(initialBalance : Double) extends BankAccount(initialBalance)
{
  private var balance = initialBalance
  override def deposit(amount : Double) = {
    balance = super.deposit(amount) - 1
    balance
  }

  override def withdraw(amount : Double) = {
    balance = super.withdraw(amount) - 1
    balance
  }
}

object Test extends App
{
  val ch = new CheckingAccount(100);
  println(ch.withdraw(2))
}
```

\2. 扩展前一个练习中的BankAccount 类， 新类SavingAccount 每个月都有利息产生 (earnMonthlyInterest方法被调用)，并且有每月三次免手续费的存款和取款。在earnMonthlyInterest 方法中重置交易计数

```
class BankAccount(initialBalance : Double) {
  private var balance = initialBalance

  def deposit (amount : Double) = {
    balance += amount
    balance
  }

  def withdraw(amount : Double) = {
    println("base before" + balance.toString)
    balance -= amount
    println("base " + balance.toString)
    balance
  }
}

class SavingAccount(initialBalance : Double) extends BankAccount(initialBalance)
{
  private var balance = initialBalance

  // 存取款计数
  private var count = 0

  private val earnValue = 0

  override def deposit (amount : Double) = {
    balance += amount;
    if (count > 3) {
      balance -= 1
    }
    count += 1
    balance
  }

  override def withdraw(amount : Double) = {
    balance -= amount
    if(count >= 3) {
      balance -= 1
    }
    count += 1
    balance
  }

  def earnMonthlyInterest() : Double = {
    count = 0
    balance += earnValue
    balance
  }
}

object Test extends App
{
  val ch = new SavingAccount(100);
  println(ch.withdraw(2))
  println(ch.withdraw(2))
  println(ch.withdraw(2))
  println(ch.withdraw(2))
  ch.earnMonthlyInterest
  println(ch.withdraw(20))
  println(ch.withdraw(2))
}
```

\4. 定义一个抽象类Item, 加入方法 price 和description. SimpleItem 是一个在构造器中给出价格和描述的物件，利用val可以重写def方法， Bundle是一个可以包含其他物件的物件，其价格是打包中所有物件的价格之和。同时提供一个将物件添加到打包当中的机制，以及一个合适的description 方法

```
abstract class Item
{
  def price : Int
  def description : String
}

class SimpleItem(private val initPrice : Int, private val initDescription : String) extends Item
{
  override val price : Int = initPrice
  override val description : String = initDescription
}

class Bundle extends Item
{
  private val items : scala.collection.mutable.ArrayBuffer[SimpleItem] = new scala.collection.mutable.ArrayBuffer[SimpleItem]();

  def addItem(item : SimpleItem) {
    items += item
  }

  def price() = {
    var result = 0
    for (i <- items) {
      result += i.price
    }
    result
  }

  def description() = {
    var desc = new scala.collection.mutable.ArrayBuffer[String]();
    for (i <- items) {
      desc += i.description
    }

    desc.mkString(",")
  }
}

object Test extends App
{
  val bundle = new Bundle();
  bundle.addItem(new SimpleItem(20, "test1"));
  bundle.addItem(new SimpleItem(21, "test2"));
  bundle.addItem(new SimpleItem(22, "test3"));

  println(bundle.price);
  println(bundle.description);
}
```

\5. 设计一个Point 类， 其 x 和 y 坐标可以通过构造器提供，提供一个子类 LabeledPoint , 其构造器接收一个标签值和 x, y 坐标， 比如： new LabeledPoint("Black Thursday", 1929, 230.07)

```
abstract class Point(val x : Int, val y : Int)
{
}

class LabeledPoint(var label : String, x : Int, y : Int) extends Point(x, y)
{

}

object Test extends App
{
  val p = new LabeledPoint("Black Thursday", 1929, 2307)
  println(p.label)
}
```

\6. 定义一个抽象类 Shape、一个抽象方法centerPoint, 以及该抽象类的子类 Rectangle 和 Circle , 为子类提供合适的构造器，并重写 centerPoint 方法

```
abstract class Shape
{
  def centerPoint : (Double, Double)
}

class Rectangle(val height : Int, val width : Int)
{
  def centerPoint : (Double, Double) = {
    val x = height.toDouble / 2.0
    val y = width.toDouble / 2.0
    (x, y)
  }
}

class Circle(val diameter : Int)
{
  def centerPoint : (Double, Double) = {
    val x = 0
    val y = diameter.toDouble / 2.0
    (x, y)
  }
}

object Test extends App
{
  val rect = new Rectangle(2, 3);
  println(rect.centerPoint);
  val cir  = new Circle(30)
  println(cir.centerPoint)
}
```

\7. 提供一个Square 类， 扩展自 java.awt.Rectangle 并且有三个构造器：一个以给定的端点和宽度构造正方形，一个以(0, 0) 为端点和给定的宽度构造正方形，一个以(0， 0) 为端点、0为宽度构造正方形

```
class Square(x : Int, y : Int, width : Int) extends java.awt.Rectangle(x, y, width, width)
{
  def this(x : Int, y : Int) {
    this(x, y, 10)
  }

  def this(width : Int) {
    this(0, 0, width)
  }
}

object Test extends App
{
  val rect = new Square(2, 3);
  println(rect);
}
```

\8. 编译 8.6 节中的Person 和 SecretAgent 类并使用 javap 分析类文件。总共有多少name 的getter方法？它们分别取什么值？ （提示：可以用 -c 和 -private 选项）

\9. 在 8.10 节的Creature 类中， 将 val range 替换成一个 def ， 如果你在Ant子类中也用 def的话有什么效果？如果在子类中使用 val又会有什么效果？ 为什么？

```
class Creature {
  def range  = 10

  val env : Array[Int] = new Array[Int](range)
}

class Ant extends Creature
{
  override def range = 2
} 

object Test extends App
{
  val test = new Ant();
  println(test.env.length);
} 
```
