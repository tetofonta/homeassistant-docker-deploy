#!/bin/sh

[ ! -z $BACKUP_DESTINATION ] && rclone -vvvv sync /backup $BACKUP_DESTINATION | tee /logs/$(date +%s)