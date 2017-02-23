#!/usr/bin/env sh
for p in $(opkg list-upgradable); do
  if [ "$p" != "-" ]; then
    if [ "$(echo ${p:0:1} | sed -e 's/[0-9]//')" != "" ]; then
      echo "upgrading $p"
      opkg upgrade $p
    fi
  fi
done