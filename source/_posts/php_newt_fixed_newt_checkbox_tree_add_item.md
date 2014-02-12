title: php的newt扩展库newt_checkbox_tree_add_item的bug修复
date: 2013-09-14 18:13:16
tags: newt 
categories: php
---

今天研究newt的复选框树时发现函数使用的实际情况和手册不一样，实际情况只能传递5个参数，当然结果肯定就是错误的了如图：

![php-newt-001-001][php-newt-001-001]

代码：

![php-newt-002-001][php-newt-002-001]

当按正确的传递6个参数时就会报错，最后查看其源代码发现在参数验证这块有逻辑错误，错误代码如下：

```
	PHP_FUNCTION(newt_checkbox_tree_add_item)
	{
	    zval *z_checkboxtree, *z_data, ***args;
	    newtComponent checkboxtree;
	    char *text;
	    int text_len, i;
	    long flags;
	    void **newt_args = NULL;
	    ulong key;
	    
	    int argc = ZEND_NUM_ARGS();
	    if (argc < 5) { WRONG_PARAM_COUNT; }
	    if (zend_parse_parameters (argc TSRMLS_CC, "rszl", &z_checkboxtree, &text, &text_len, &z_data, &flags) == FAILURE) {
	        return;
	    }   
	    
	    args = (zval ***) safe_emalloc (argc, sizeof(zval **), 0);
	    if (zend_get_parameters_array_ex (argc, args) == FAILURE) {
	        efree (args);
	        return;
	    }   
	    
	    ZEND_FETCH_RESOURCE(checkboxtree, newtComponent, &z_checkboxtree, -1, le_newt_comp_name, le_newt_comp);
	    
	    PHP_NEWT_STORE_DATA (z_data, key);
	    
	    newt_args = (void **) safe_emalloc (argc, sizeof(void *), 0);
	    newt_args[0] = (void *)checkboxtree;
	    newt_args[1] = (void *)text;
	    newt_args[2] = (void *)key;
	    newt_args[3] = (void *)flags;
	
	    for (i=4; i<argc; i++) {
		       if (Z_TYPE_PP(args[i]) != IS_LONG) {
	            efree (newt_args);
	            efree (args);
	            php_error_docref (NULL TSRMLS_CC, E_ERROR, "Arguments starting from fifth must be integers");
	            return;
	        }    
	        newt_args[i] = (void *)Z_LVAL_PP(args[i]);
	    }    
	
	    newt_vcall ((void *)newtCheckboxTreeAddItem, newt_args, argc);
	
	    efree (newt_args);
	    efree (args);
	}
```

在限定参数中出现了逻辑错误，我最后有稍作了修改，当然这个办法现在只是解决了问题，但是绝对不是最后的方法，如下：

```
	PHP_FUNCTION(newt_checkbox_tree_add_item)
	{
	    zval *z_checkboxtree, *z_data, ***args;
	    newtComponent checkboxtree;
	    char *text;
	    int text_len, i;
	    long flags;
	    long index1;
	    long index2;
	    long index3;
	    long index4;
	    long index5;
	    long index6;
	    void **newt_args = NULL;
	    ulong key;
	    
	    int argc = ZEND_NUM_ARGS();
	    if (argc < 5) { WRONG_PARAM_COUNT; }
	    if (zend_parse_parameters (argc TSRMLS_CC, "rszl|llllll", &z_checkboxtree, &text, &text_len, &z_data, &flags) == FAILURE) {
	        return;
	    }   
	    
	    args = (zval ***) safe_emalloc (argc, sizeof(zval **), 0);
	    if (zend_get_parameters_array_ex (argc, args) == FAILURE) {
	        efree (args);
	        return;
	    }   
	    
	    ZEND_FETCH_RESOURCE(checkboxtree, newtComponent, &z_checkboxtree, -1, le_newt_comp_name, le_newt_comp);
	    
	    PHP_NEWT_STORE_DATA (z_data, key);
	    
	    newt_args = (void **) safe_emalloc (argc, sizeof(void *), 0);
	    newt_args[0] = (void *)checkboxtree;
	    newt_args[1] = (void *)text;
	    newt_args[2] = (void *)key;
	    newt_args[3] = (void *)flags;
	
	    for (i=4; i<argc; i++) {
		       if (Z_TYPE_PP(args[i]) != IS_LONG) {
	            efree (newt_args);
	            efree (args);
	            php_error_docref (NULL TSRMLS_CC, E_ERROR, "Arguments starting from fifth must be integers");
	            return;
	        }    
	        newt_args[i] = (void *)Z_LVAL_PP(args[i]);
	    }    
	
	    newt_vcall ((void *)newtCheckboxTreeAddItem, newt_args, argc);
	
	    efree (newt_args);
	    efree (args);
	}
```


这样一来就正确了：

![php-newt-003-001][php-newt-003-001]

![php-newt-004-001][php-newt-004-001]

BUG说明：其实这个bug在2012-03-28就有人提出了，但是可能修复bug的误解了问题所以修复了以后的newt-1.2.60还是错误的：


Bug \#61545
newt\_checkbox\_tree\_add\_item() doesn’t accept correct number of arguments

[https://bugs.php.net/bug.php?id=61545][bugs_url]



官方更新BUG的文件diff

[http://svn.php.net/viewvc/pecl/newt/trunk/newt.c?r1=312452&r2=324608][svn_diff]

![php-newt-005-001][php-newt-005-001]

其实也就是这块错误！但是官方没有彻底的解决掉！！

由于newt的整体互联网资料短缺所以供后人参考。

[bugs_url]: https://bugs.php.net/bug.php?id=61545
[svn_diff]: http://svn.php.net/viewvc/pecl/newt/trunk/newt.c?r1=312452&r2=324608
[php-newt-001-001]: /image/php/php-newt-001-001.png
[php-newt-002-001]: /image/php/php-newt-002-001.png
[php-newt-003-001]: /image/php/php-newt-003-001.png
[php-newt-004-001]: /image/php/php-newt-004-001.png
[php-newt-005-001]: /image/php/php-newt-005-001.png
