title: 《快学scala》第十二章 高阶函数 
date: 2014-10-18 14:42:16
tags: scala
categories: 《快学scala》练习
---

\1. 编写函数 values(fun: (Int) =\> Int, low:Int, high: Int), 该函数输出一个集合，对应给定区间内给定函数的输入和输出。比如，values(x=\> x \* x, -5, 5)应该产生一个对偶的集合(-5, 25), (-4, 16), (-3, 9), ...., (5, 25)。

```
object valueTest extends App {

  def values(func: (Int) => Int, low: Int, high: Int) = {
    val result = (low to high).map(
      p => {
        (p, func(p))
      }
    );

    result
  }

  def func(x: Int) = {
    x * x
  }

  values(func, 1, 5).foreach(item => {
    println(item._1)
    println(item._2)
  })
}
```

\2. 如何用 reduceLeft 得到数组中最大元素？

```
object reduceLeftTest extends App {
  val testData = (1 to 10).toArray

  println(testData.reduceLeft((num1, num2) => {
    if (num1 > num2) {
      num1
    } else {
      num2
    }
  }))
} 
```

\3. 用 to 和 reduceLeft 实现阶乘函数，不得使用循环和递归。

```
object produceTest extends App {
  println((1 to 10).reduceLeft(_ * _))
}
```

\4. 前一个实现需要处理一个特殊情况，即 n < 1 的情况。展示如何用foldLeft来避免这个需要。

```
object produceTest extends App {
  println((1 to -10).foldLeft(1)(_ * _))
}
```

\5. 编写函数 largest(fun:(Int) => Int, inputs: Seq[Int]), 输出在给定输入序列中给定函数的最大值。举例来说，largest(x =\> 10 \* x - x \* x, 1 to 10) 应该返回 25，不得使用循环和递归。

```
object largestTest extends App {
  def largest(func: (Int) => Int, inputs: Seq[Int]) = {
    val opResult = inputs.map(func(_))
    opResult.max
  }               

  println(largest( x => 10 * x - x * x, 1 to 10))
} 
```

\6. 修改前一个函数，返回最大的输出对应的输入。举例来说，largestAt(fun: (Int) =\> Int, inputs: Seq[Int])应该返回5. 不得使用循环递归

```
object largestTest extends App {
  def largest(func: (Int) => Int, inputs: Seq[Int]) = {
    val opResult = inputs.map(item => {(item, func(item))})
    val max = opResult.reduceLeft((item1, item2) => {
      if (item1._2 > item2._2) {
        item1
      } else {
        item2
      }
    })

    max._1
  } 
  
  println(largest( x => 10 * x - x * x, 1 to 10))
}
```

\7. 要得到一个序列的对偶很容易，比如：

```
    val pairs = (i to 10) zip (11 to 20)
```

假定你想要对这个序列做某种操作---比如，给对偶中的值求和。但你不能直接用：

```
    pairs.map(_ + _)
```

函数 \_ + \_ 接收两个 Int 作为参数，而不是(Int, Int)对偶。编写函数 adjustToPair, 该函数接受一个类型为(Int, Int) => Int, 并返回一个等效的、可以以对偶作为参数的函数。举例来说就是： adjustToPair(\_ \* \_)((6, 7))应得到42.

然后用这个函数通过map计算出各个对偶的元素之和

```
object adjustToPairTest extends App {
  def adjustToPair(fun: (Int, Int) => Int)(item: (Int, Int)) = {
    fun(item._1, item._2)
  }

  val pairs = (1 to 10) zip (11 to 20)
  pairs.map(item => adjustToPair(_ + _)(item)).foreach(println)
}
```

\8. 在12.8节中，你看到了用于两组字符串数组的corresponds方法。做出一个方法的调用，让它帮我们判断字符串数组里的所有元素的长度是否和某个给定整数数组相对应。

```
object correspondsTest extends App {
  val a = Array("aaaaa", "bbbbbb", "ccc")
  val b = Array("aaa", "bbb", "ccc")
  val c = Array(5, 6, 3)

  println(a.corresponds(c)(_.length == _))
  println(b.corresponds(c)(_.length == _))
} 
```

\9. 不使用柯里化实现 corresponds 。 然后尝试从以前一个练习的代码来调用。你遇到什么问题？

```
类型推断会有问题
```

\10. 实现一个 unless 控制抽象，工作机制类似 if， 但条件是反过来的。第一个参数需要是换名调用的参数吗？你需要柯里化吗？

```
object unlessTest extends App {
  def unless(condition: => Boolean)(block: => Unit) {
    if (!condition) {
      block
    }
  }

  val n = 10;
  unless(n == 1) {
    println(n)
  }
}

需要换名和柯里化
```
