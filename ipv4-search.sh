#!/bin/bash

SEARCH_DIR=${SEARCH_DIR:-/root/logs}

grep -ohrE "\b(25[0-5]|w[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}\b" $SEARCH_DIR | LC_ALL=C sort -u
