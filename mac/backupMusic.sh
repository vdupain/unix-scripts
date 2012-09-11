#!/bin/sh
rsync -avz -e ssh --force --delete-after --exclude '.DS_Store' --delete-excluded /Users/Shared/Media/Music admin@nas:/share/homes/vince
