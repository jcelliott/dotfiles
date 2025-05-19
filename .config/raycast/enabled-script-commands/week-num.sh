#!/bin/bash

# @raycast.title Week Number
# @raycast.schemaVersion 1
# @raycast.mode inline
# @raycast.refreshTime 1h
# @raycast.packageName Developer Utilities
# @raycast.icon 🗓️
# @raycast.description Show current week number

echo -e "\x1b[32m$(date +%V)\x1b[0m"
