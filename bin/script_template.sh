#!/bin/bash

# colorized output
function cinfo() {
  # echo -e "\E[34m$1\E[0m" # blue
  # echo -e "\x1b[34m$1\x1b[0m" # blue
  # echo -e "\E[32m$1\E[0m" # green
  echo -e "\x1b[32m$1\x1b[0m" # green
}
function cwarn() {
  # echo -e "\E[33m$1\E[0m"
  echo -e "\x1b[33m$1\x1b[0m"
}
function cerror() {
  # echo -e "\E[31m$1\E[0m"
  echo -e "\x1b[31m$1\x1b[0m"
}

