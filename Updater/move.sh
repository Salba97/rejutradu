#!/bin/bash

set -e
set -u
set -o pipefail

sleep 3

echo "Finishing engine update."

if [ "$#" -ne 5 ]; then
    echo "Missing arguments"
    exit 1
fi

source_dir="$1"
dest_dir="$2"
bootstrap="$3"
constant="$4"
value="$5"

if [ ! -d "$source_dir" ]; then
    echo "Error: Source directory '$source_dir' does not exist."
    exit 1
fi

if [ ! -d "$dest_dir" ]; then
    echo "Destination directory '$dest_dir' does not exist."
    exit 1
fi

echo "Moving from '$source_dir' to '$dest_dir'"
rsync -a "$source_dir/" "$dest_dir"

echo "Deleting '$source_dir'"
rm -rf "$source_dir"

echo "Fixing AppImage permissions"
chmod +x *.AppImage

echo "Changing '$constant' to '$value' in '$bootstrap'"
sed -i "s/^$constant = '.*'$/$constant = '$value'/" "$bootstrap"

echo "Done."
