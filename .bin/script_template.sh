#!/bin/bash

# colorized output
function cinfo() {
  echo -e "\E[34m$1\E[0m"
}
function cwarn() {
  echo -e "\E[33m$1\E[0m"
}
function cerror() {
  echo -e "\E[31m$1\E[0m"
}
