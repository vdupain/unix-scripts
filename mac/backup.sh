#!/bin/sh
rsync -avz -e ssh --force --delete-after --exclude '.DS_Store' --delete-excluded /Users/vince/Documents admin@nas:/share/homes/vince
