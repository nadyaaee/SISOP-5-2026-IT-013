#!/bin/bash
set -e

TIME=$(date +"%d%m%Y-%H%M%S")
ZIPNAME="farewell_backup_[$TIME].zip"

cd osboot
zip "$ZIPNAME" bzImage single.gz multi.gz farewell.iso
echo "Backup selesai: osboot/$ZIPNAME"
