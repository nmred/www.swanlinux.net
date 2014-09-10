title: 《快学scala》第九章 文件和正则表达式
date: 2014-09-10 11:32:16
tags: scala
categories: 《快学scala》练习
---

\1. 编写一小段Scala代码，将某个文件中的行倒转顺序（将最后一行作为第一行，一次类推）

```
import scala.io.Source
object Test extends App
{
  val fileName = "/tmp/aa.txt"
  val sc = Source.fromFile(fileName, "UTF-8");
  val buf = sc.getLines.toArray
  val result = buf.reverse

  val ps = new java.io.PrintWriter(fileName);
  result.foreach(ps.println)
  ps.flush()
  ps.close()
}
```

\2. 编写Scala程序，从一个带有制表符的文件读取内容，将每个制表符替换成一组空格，使得制表符隔开的n列仍然保持纵向对齐，并将结果写入到同一个文件

```
import scala.io.Source
object Test extends App
{
  val fileName = "/tmp/aa.txt"
  val sc = Source.fromFile(fileName, "UTF-8")
  val result = sc.getLines.toArray.map(convert)
  val ps = new java.io.PrintWriter(fileName);
  result.foreach(ps.println)
  ps.flush
  ps.close

  def convert(s : String) : String = {
    s.replaceAll("\t", " ")
  }
}
```

\3. 编写一小段Scala代码，从一个文件读取内容并把所有字符数大于12 的单词打印到控制台

```
import scala.io.Source
object Test extends App
{  Source.fromFile("/tmp/aa.txt", "UTF-8").mkString("").split("\\s+").filter(_.toString.length > 12).map(println)
}
```

\4. 编写 Scala程序，从包含浮点数的文本文件读取内容，打印出文件中所有浮点数之和、平均值、最大值和最小值

```
import scala.io.Source
object Test extends App
{
  val result = Source.fromFile("/tmp/aa.txt", "UTF-8").mkString;
  val filterResult : Array[Double] = "[0-9]+\\.[0-9]+".r.findAllIn(result).map(_.toDouble).toArray;

  val max = filterResult.max
  val min = filterResult.min
  val avg = filterResult.sum / filterResult.length
  println((max, min, avg))
}
```

\5. 编写 Scala程序， 向文件中写入2的n次方及其倒数，指数n从0到20，对齐各列：

```
	1 	1
	2 	0.5
	4 	0.25
	..	..
```

```
import scala.io.Source
object Test extends App
{
  val ps = new java.io.PrintWriter("/tmp/aa.txt")
  for (n <- 0 to 20) {
    val value : Double = 1 / (scala.math.pow(2, n))
    ps.println("\t" + n.toString + "\t" + value.toString);
  }

  ps.flush
  ps.close
}
```

\6. 编写正则表达式，匹配Java或C++ 程序代码中类似"like this, maybe with \" or \\" 这样的带引号的字符串。

```
import scala.io.Source
object Test extends App
{
  val sc = Source.fromFile("/tmp/aa.php", "UTF-8")
  val result = """\"(\w[^\\])+(\\)?"""".r.findAllIn(sc.mkString)
  result.foreach(println)
}
```

\7. 编写 Scala 程序， 从文本文件读取内容， 并打印出所有非浮点数的词法单元，要求使用正则表达式

```
import scala.io.Source
object Test extends App
{
  val sc = Source.fromFile("/tmp/aa.php", "UTF-8")
  val result = "[0-9]+\\.[0-9]+".r.replaceAllIn(sc.mkString, "")

  println(result)
}
```

\8. 编写 Scala程序， 打印出某个网页中所有img标签的src属性，使用正则表达式和分组

```
import scala.io.Source
object Test extends App
{
  val sc = Source.fromURL("http://www.baidu.com", "UTF-8")
    val pat = "<img[^>]+src=\"([^\"]+)\"[^>]+>".r
  val result = pat.findAllIn(sc.mkString)
  for (pat(src) <- result) {
    println(src)
  }
}
```

\9. 编写Scala程序，盘点给定目录及其子目录中总共有多少以.class为扩展名的文件

```
import scala.collection.mutable.ArrayBuffer
import java.io.File
object Test extends App
{
  def getFiles(dir : File) : ArrayBuffer[String] = {
    val files : ArrayBuffer[String] = new ArrayBuffer[String]();
    val children = dir.listFiles.toIterator
    for (f <- children) {
      if (f.isDirectory && f.canRead) { // 注意没有读权限的目录
        val childrenFiles = getFiles(f)
        files ++= childrenFiles
      } else {
        if (f.getName.endsWith(".class")) {
          files += f.getName;
        }
      }
    }

    files
  }

  println(getFiles(new File("/usr/home/zhongxiu")).length)
}
```

\10. 扩展那个可序列化的Person类，让它能以一个集合保存某个人的朋友信息，构造出一些Person对象，让他们中的一些人成为朋友，然后将Array[Person]保存到文件，将这个数组从文件中重新读出来，校验朋友关系是否完好

```
import scala.collection.mutable.ArrayBuffer
import java.io.File
object Test extends App
{
  val p = new Person("test1", 23);
  val p1 = new Person("test2", 24);
  val p2 = new Person("test3", 25);

  p.addFriend(p1)
  p.addFriend(p2)

  import java.io._
  val fileName = "/tmp/test.obj"
  val objStream = new ObjectOutputStream(new FileOutputStream(fileName))
  objStream.writeObject(p)

  val in = new ObjectInputStream(new FileInputStream(fileName))
  val pObj = in.readObject.asInstanceOf[Person]

  println(pObj.getFirendNames)
}

class Person(val name : String, val age : Int) extends Serializable
{
  private val friends : ArrayBuffer[Person] = new ArrayBuffer[Person]();

  def addFriend(friend : Person) {
    friends += friend
  }

  def getFirendNames() : String = {
    val str = ""
    friends.map(_.name).mkString
  }
}
```
