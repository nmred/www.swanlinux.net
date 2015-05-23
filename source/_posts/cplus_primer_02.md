title: 《C++ Primer Plus(第6版)》第二章 开始学习C++
date: 2015-04-30 13:13:16
tags: C++
categories: 《C++ Primer Plus(第6版)》练习
---

\1. 编写一个C++程序，它显示您的姓名和地址？

```
#include <iostream>

int main(void) {
    using namespace std;
    cout << "Name: nmred" << endl;
    cout << "Address: Hai Dian Bei Jing" << endl;
    return 0;
}

```

\2. 编写一个C++程序，它要求用户输入一个以long 为单位的距离，然后转化为码(1 long = 220码)

```
#include <iostream>

int main(void) {
    using namespace std;
    int longSize = 0;
    cout << "Please input long size:";
    cin >> longSize;

    cout << "After convert value:" << longSize * 220 << endl;
    return 0;
}
```

\3. 编写一个C++程序，它使用了3个用户定义的函数（包括main）并生成下面的输出：

```
Three blind nice
Three blind nice
See how they run
See how they run
```

其中一个函数要调用两次，该函数生成输出的前两行，另一个函数也被调用两次，并生成其余的输出。

```
#include <iostream>

using namespace std;

void printBlind() {
    cout << "Three blind nice" << endl;
}

void printRun() {
    cout << "See how they run" << endl;
}

int main(void) {
    printBlind();
    printBlind();

    printRun();
    printRun();
    return 0;
}
```

\4. 编写一个程序，让用户输入其年龄，然后显示该年龄包含多少个月，如下所示：

```
Enter your age : 29
```

```
#include <iostream>

int main(void) {
    using namespace std;

    int age;
    cout << "Enter your age:";
    cin >> age;

    cout << "You age mouth: " << age * 12 << endl;

    return 0;
}
```

\5. 编写一个程序， 其中的main() 调用一个用户定义的函数(以摄氏温度值为参数，并返回相应的华氏温度值)。该程序按下面的格式要求用户输入摄氏温度值，并显示结果：

```
Please enter a Celsius value: 20
20 degrees Celsius is 68 degrees Fahrenheit
```

下面是转换公式:

华氏温度 = 1.8 * 摄氏温度 + 32.0

```
#include <iostream>

int main(void) {
    using namespace std;

    int celsius;
    cout << "Please enter a Celsius value:";
    cin >> celsius;

    cout << celsius << " degrees Celsius is " << celsius * 1.8 + 32 << " degrees Fahrenheit" << endl;

    return 0;
}
```

\6. 编译一个程序，其main() 调用一个用户定义的函数(以光年值为参数，并返回对应天文单位的值). 该程序按下面的格式要求用户输入光年值，并显示结果：

```
Enter the number of light years: 4.2
4.2 light years = 265608 astronomical units.
```

天文单位是从地球到太阳的平均距离（约150000000公里或93000000英里）, 光年是光一年走的距离(约10万亿公里或6万亿英里)（除太阳外，最近的恒星大约离地球4.2光年）。请使用double类型， 转化公式为：

1光年 = 63240 天文单位

```
#include <iostream>

double convert(double years) {
    return years * 63240;
}

int main(void) {
    using namespace std;
    double year;
    cout << "Enter the number of light years:";
    cin >> year;
    cout << year << " light years = " << convert(year) << " astronomical units." << endl;

    return 0;
}
```

\7. 编写一个程序，要求用户输入小时数和分钟数，在mian() 函数中，将这两个值传递给一个void函数，后者以下面这样的格式显示这两个值：

```
Enter the number of hours: 9
Enter the number of minutes: 28
Time: 9:28
```

```
#include <iostream>

int main(void) {
    using namespace std;
    int hour = -1;
    int minute = -1;

    cout << "Enter the number of hours:";
    cin >> hour;
    if (!cin) {
        cin.clear();
        while (cin.get() != '\n') {
            continue;
        }
    }
    while (hour > 24 || hour < 0) {
        cout << "Enter the number of hours:";
        cin >> hour;
    }
    cout << "Enter the number of minutes:";
    cin >> minute;
    if (!cin) {
        cin.clear();
        while (cin.get() != '\n') {
            continue;
        }
    }
    while (minute > 60 || minute < 0) {
        cout << "Enter the number of minutes:";
        cin >> minute;
    }

    cout << "Time:" << hour << ":" << minute << endl;

    return 0;
}
```
