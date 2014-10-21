title: 《快学scala》第十五章 注解
date: 2014-10-22 19:42:16
tags: scala
categories: 《快学scala》练习
---

\1. 编写四个Junit测试案例，分别使用带或不带某个函数的@Test注解。用 Junit执行这些测试。

\2. 创建一个类的示例，展示注解可以出现的所有位置。用@deprecated作为你的示例注解。

\3. Scala 类库中的那些注解用到了元注解@param, @field, @getter, @setter, @beanGetter或@beanSetter?

\4. 编写一个Scala方法sum，带有可变长度的整型参数，返回所有参数之和。从Java调用该方法

\5. 编写一个返回包含某文件所有行的字符串的方法。从Java调用该方法

\6. 编写一个Scala对象，该对象带有一个易失(volatile)的Boolean字段。让某一个线程睡眠一段时间，之后将该字段设为true, 打印消息，然后退出。而另一个线程不停地检查该字段是否为true。 如果是，它将打印一个消息并退出。如果不是，它将短暂睡眠，然后重试。如果变量不是易失的，会发生什么？

\7. 给出一个示例，展示如果方法可被重写，则尾递归优化为非法。

\8. 将allDifferent 方法添加到对象，编译并检查字节码。@specialized 注解产生了哪些方法？

\9. Range.foreach 方法被注解为 @specialized(Unit)。为什么？ 通过以下命令检查字节码：

```
javap -classpath /path/to/scala/lib/scala-library.jar scala.collection.immutable.Range
``` 

并考虑Function1 上的@specialized 注解。点击ScalaDoc 中的Function1.scala链接进行查看

\10. 添加 assert(n >= 0) 到factorial方法。在启用断言的情况下编译并校验factorial(-1) 会抛异常。在禁用断言的情况下编译。会发生什么？用javap检查该断言调用


