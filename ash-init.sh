#!/bin/ash

cd /

apk --no-cache add bash
exec env -i /app/entry.sh
