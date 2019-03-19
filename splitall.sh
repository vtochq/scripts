#!/bin/bash

find /data/music/ -type f -size +100M -exec ./cuesplit.sh {} \;

echo "Don't forget remove bak files"
echo 'find /data/music/ -name "*.bak" -exec rm {} \;'
