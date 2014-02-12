#!/bin/bash

export PATH=$PATH:/usr/local/node/bin
hexo clean
hexo g
hexo server
