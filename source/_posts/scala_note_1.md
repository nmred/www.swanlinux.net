title: 《快学scala》第一章
date: 2014-09-05 13:13:16
tags: scala
categories: 《快学scala》练习
---

\1. 在 Scala REPL 中键入3，然后按TAB键。有那些方法可以被应用？ 

```
	scala> 3.
	!=             ##             %              &              *              +              -              /              
	<              <<             <=             <init>         ==             >              >=             >>             
	>>>            ^              asInstanceOf   equals         getClass       hashCode       isInstanceOf   toByte         
	toChar         toDouble       toFloat        toInt          toLong         toShort        toString       unary_+        
	unary_-        unary_~        |  

```

\2. 在scala REPL中，计算3的平方根，然后再对该值求平方，现在，这个结果与3相差多少？（提示：res变量是你的朋友）

```
	scala> import scala.math._
	import scala.math._

	scala> sqrt(3)
	res0: Double = 1.7320508075688772

	scala> pow(res0, 2)
	res1: Double = 2.9999999999999996

	scala> 3 - res1
	res3: Double = 4.440892098500626E-16	

```

\3. res变量是val还是var？

```
	val
```

\4. Scala 允许你用数字去乘字符串--去 REPL中试一下 "crazy" * 3, 这个操作做什么？在 Scaladoc 中如何找到这个操作？

```
	scala> "crazy" * 3
	res4: String = crazycrazycrazy

	def *(n: Int): String

	Return the current string concatenated n times.

```
 
\5. 10 max 2的含义是什么？max方法定义在哪个类中？ 


含义： 10.max(2)

max 方法定义在 RichInt -> ScalaNumberProxy

\6. 用BigInt计算2的1024次方。 

```
	scala> val x : BigInt = 2
	x: scala.math.BigInt = 2

	scala> x.pow(1024)
	res5: scala.math.BigInt = 179769313486231590772930519078902473361797697894230657273430081157732675805500963132708477322407536021120113879871393357658789768814416622492847430639474124377767893424865485276302219601246094119453082952085005768838150682342462881473913110540827237163350510684586298239947245938479716304835356329624224137216

```

\7. 为了在使用probablePrime(100, Random)获取随机素数时不在probablePrime和Radom之前使用任何限定符，你需要引入什么？ 

```
	scala> import scala.util._
	import scala.util._

	scala> import scala.math.BigInt._
	import scala.math.BigInt._

	scala> 

	scala> 

	scala> probablePrime(100, Random)
	res6: scala.math.BigInt = 1139920916542977579379440009349
```

\8. 创建随机文件的方式之一是生成一个随机的BigInt，然后把它转换成三十六进制，输出类似"qsnveffwfweq434ojjlk"这样的字符串，查阅scaladoc，找到在scala中实现该逻辑的办法。 

```
	scala> val x : BigInt = probablePrime(100, Random)
	x: scala.math.BigInt = 1241670916639639181026223834111

	scala> x.toString(36)
	res18: String = 3cdr1tpupxgeogbs2ynz
```

\9. 在Scala中如何获取字符串的首字符和尾字符？ 

```
	scala> val str : String = "abcdef"
	str: String = abcdef

	scala> str.head
	res19: Char = a

	scala> str.last
	res20: Char = f
```

\10.  take, drop, takeRight, dropRight这些字符串函数是做什么用的？和substring相比，它们的优点和缺点都有哪些？ 

```
	scala> val str : String = "abcdef"
	str: String = abcdef

	scala> str.take(2)
	res21: String = ab

	scala> str.drop(2)
	res22: String = cdef

	scala> str.takeRight(2)
	res23: String = ef

	scala> str.dropRight(2)
	res24: String = abcd
```
