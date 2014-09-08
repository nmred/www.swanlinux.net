title: 《快学scala》第五章 类
date: 2014-09-08 10:56:16
tags: scala
categories: 《快学scala》练习
---

\1. 改进5.1节的Counter类，让它不要在Int.MaxValue时变成负数。

```
object TestC {
  def main(args : Array[String]) {
    val count = new Counter();
    for (_ <- 1 to Int.MaxValue) {
      count.increment();
    }
    println(count.current)
  }
}

class Counter
{ 
  private var value = 0
  
  def increment() { 
    if ((value + 1).isValidInt) {
      value += 1
    }
  }
  
  def current() = value
}
```

\2. 编写一个BankAccount类，加入deposit和withdraw方法，和一个只读的balance属性。  

```
object TestC {
  def main(args : Array[String]) {
    val bank = new BankAccount(200);
    bank.deposit
    bank.withdraw
    println(bank.balance)
  }
}

class BankAccount(val balance : Int)
{
  def deposit = {
    println("deposit function");
  }

  def withdraw = {
    println("withdraw function");
  }
}
```

\3. 编写一个Time类，加入只读属性hours和minutes，和一个检查某一时刻是否早于另一时刻的方法before(other: Time): boolean。Time对象应该以new Time(hrs, min)方式构建，其中hrs小时数以军用时间格式呈现（介于0和23之间）。

```
package net.swanlinux.www.test

object TestC {
  def main(args : Array[String]) {
    val time = new Time(23, 9);
    println(time.before(new Time(23, 10)))
  } 
} 

class Time(private var hrs : Int, private var min : Int)
{
  // 格式化合法的时间
  hrs = hrs % 24
  min = min % 60
  
  def before(other : Time) : Boolean = {
    other.hours > this.hours || (other.hours == this.hours && other.minutes > this.minutes)
  } 
  
  def hours = hrs
  
  def minutes = min
} 
```

\4. 重新实现前一个练习中的Time类，将内部呈现改成自午夜起的分钟数（介于0到24x60-1之间）。不要改变公有接口。也就是说，客户端代码不应因你的修改而受影响。 

```
package net.swanlinux.www.test

object TestC {
  def main(args : Array[String]) {
    val time = new Time(23, 9);
    println(time.before(new Time(23, 10)))
  } 
} 

class Time(private var hrs : Int, private var min : Int)
{
  // 格式化合法的时间
  hrs = hrs % 24
  min = min % 60
  
  def before(other : Time) : Boolean = {
    other.total > this.total
  }                     
                        
  def hours = hrs

  def minutes = min

  def total = (hrs * 60 + min)
}
```

\5. 创建一个Student类，加入可读写的JavaBeans属性name(类型为String)和id(类型为Long)。 

```
package net.swanlinux.www.test
import scala.reflect.BeanProperty

object TestC {
  def main(args : Array[String]) {
    val stu = new Student("test", 4000)
    println(stu.getName);
    println(stu.getId);
  }
} 

class Student(@BeanProperty var name : String, @BeanProperty var id : Long)
{
}
```

\6. 在5.2节的Person类中提供一个主构造器，将负年龄转换为0。 

```
package net.swanlinux.www.test

object TestC {
  def main(args : Array[String]) {
    val per = new Person();
    per.age = -2
    println(per.age)
  } 
} 

class Person
{
  private var privateAge = 0

  def age_=(newValue : Int) { 
    if (newValue < 0) {
      privateAge = 0
    } else {
      privateAge = newValue
    }             
  }               
     
  def age = privateAge
} 
```

\7. 编写一个Person类，其主构造器接受一个字符串，该字符串包含名字、空格和姓，如new Person("Fred Smith")。提供只读属性firstName和LastName。 

```
package net.swanlinux.www.test

object TestC {
  def main(args : Array[String]) {
    val per = new Person("Fred Smith");
    println(per.firstName)
    println(per.lastName)
  } 
} 

class Person(val name : String)
{
  val firstName = name.split(" ")(0)
  val lastName = name.split(" ")(1)
} 
```

\8. 创建一个Car类，以只读属性对应制造商、型号名称、型号年份以及一个可读写的属性用于车牌。提供四组构造器。每一个构造器都要求制造商和型号名称为必填。型号年份以及车牌为可选，如果未填，则型号年份设置为-1，车牌设置为空字符串。你会选择哪一个作为你的主构造器？为什么？

```

package net.swanlinux.www.test

object TestC {
  def main(args : Array[String]) {
    val car = new Car("Fred Smith", "test", 2008, "JX222");
    println(car.model)
  } 
} 

class Car(val maker : String, val name : String)
{
  private var privateModel = -1
  var licence = ""
  
  def this(maker : String, name : String, model : Int) {
    this(maker, name)
    this.privateModel = model
  }     
        
  def this(maker : String, name : String, model : Int, licence : String) {
    this(maker, name, model)
    this.licence = licence
  } 
  
  def this(maker : String, name : String, licence : String) {
    this(maker, name)
    this.licence = licence
  } 
  
  def model = privateModel
}
```

\10. 考虑如下类：

class Employee(val name: String, var salary: Double) {

  def this() {this("John Q. Public", 0.0)}

}

重写该类，使用显式的字段定义，和一个缺省主构造器。你更倾向于使用哪一种形式？为什么？

```
package net.swanlinux.www.test

object TestC {
  def main(args : Array[String]) {
    val em = new Employee();
    println(em.name)
  } 
} 

class Employee
{
  private var privateName = "John Q. Public"
  private var privateSalary = 0.0
  
  def this(name : String, salary : Double) {
    this()
    this.privateName = name
    this.privateSalary = salary
  } 
  
  def name = privateName
  
  def salary = privateSalary
}
```
