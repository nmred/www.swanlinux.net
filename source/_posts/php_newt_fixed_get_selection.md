title: 修复newt扩展库newt_*_get_selection函数中断不返回的BUG
date: 2013-09-14 18:13:16
tags: newt 
categories: php
---

继上篇文章修复newt\_checkbox\_tree\_add\_item函数错误后再次修复

>newt\_checkbox\_tree\_get\_selection
>
>newt\_checkbox\_tree\_get\_multi\_selection
>
>newt\_listbox\_get\_selection

这三个函数有同样的bug，下面是修复的方法：（注意：包括上篇的bug只是在newt-1.2.6中存在，可能以后版本会修复，这是因为很少人用，所有更新版本缓慢）


以newt\_checkbox\_tree\_get\_selection为例

```
	PHP_FUNCTION(newt_checkbox_tree_get_selection)  
	{
	    zval *z_checkboxtree;
	    newtComponent checkboxtree;
	    ulong *retval;
	    zval *z_val;
	    int num_items;
	    int i;
	    
	    if (zend_parse_parameters (ZEND_NUM_ARGS() TSRMLS_CC, "r", &z_checkboxtree) == FAILURE) {
	        return;
	    }
	    
	    ZEND_FETCH_RESOURCE(checkboxtree, newtComponent, &z_checkboxtree, -1, le_newt_comp_name, le_newt_comp);
	    retval = (ulong *)newtCheckboxTreeGetSelection (checkboxtree, &num_items);
	
	    array_init (return_value);
	    if (retval) {
	        MAKE_STD_ZVAL (z_val);
	        for (i=0; i < num_items; i++ ) {
	            PHP_NEWT_FETCH_DATA (retval[i], z_val);
	            zval_add_ref (&z_val);
	            zend_hash_next_index_insert (Z_ARRVAL_P(return_value), &z_val, sizeof(zval *), NULL);
	            SEPARATE_ZVAL (&z_val);
	        }
	        free (retval);
	    }
	}
```
