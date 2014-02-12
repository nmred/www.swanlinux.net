title: 关于newt从HashTable中通过data获取key函数调用错误的bug
date: 2013-09-14 18:13:16
tags: newt 
categories: php
---

在运用PHP中newt过程中除了上几篇文中遇到的bug最近在用newt\_checkbox\_tree\_set\_current这个函数是发现在对应C语言中可以正常使用，但是php中没有效果，多次修改没有结果，最终是由于没有搞明白其和C语言传递值的原理，其实php中传递的KEY值，而这个KEY是在php中存储在HashTable中，但是源码中运用了PHP\_NEWT\_STORE\_DATA (z\_data, key)这个是对data进行存储到Hash表中，最终返回key的，

但是当前函数是需要通过php传递过来的data来查找key，显然这个宏是不能达到目地的，在这个文件中找到宏定义，发现原本就有PHP\_NEWT\_FETCH\_KEY(z\_data, key)这个宏，是专门通过data来查找对应的key的，所有将其替换原有的PHP\_NEWT\_STORE\_DATA (z\_data, key)即可修正这个bug.

```
	PHP_FUNCTION(newt_checkbox_tree_set_current)
	{
	    zval *z_checkboxtree, *z_data;
	    newtComponent checkboxtree;
	    ulong key;

	    if (zend_parse_parameters (ZEND_NUM_ARGS() TSRMLS_CC, "rz", &z_checkboxtree, &z_data) == FAILURE) {
	        return;
	    }

	    ZEND_FETCH_RESOURCE(checkboxtree, newtComponent, &z_checkboxtree, -1, le_newt_comp_name, le_newt_comp);

	    PHP_NEWT_FETCH_KEY(z_data, key);
	    newtCheckboxTreeSetCurrent (checkboxtree, (void *)key);
	}
```

此扩展库有同样的bug不只是这个函数，还有以下几个函数，其修复办法一样：

>newt\_checkbox\_tree\_set\_entry\_value
>
>newt\_checkbox\_tree\_get\_entry\_value
>
>newt\_checkbox\_tree\_find\_item
>
>newt\_checkbox\_tree\_set\_entry


可能还有其他的函数有同样的bug到目前还没有发现，如果发现将陆续修复。
