#!/bin/bash

UINTENT_ROOT=$(pwd)
UINTENT_OUTPUT_DIR=$UINTENT_ROOT/output

if [ ! -d "$UINTENT_OUTPUT_DIR" ]; then
	mkdir "$UINTENT_OUTPUT_DIR"
fi

EXTRACT_DIR="$UINTENT_ROOT/$UINTENT_OPENWRT_DIR"
TARGET_DIR="$EXTRACT_DIR/imagebuilder-$UINTENT_PRITARGET-$UINTENT_SUBTARGET-$OPENWRT_VERSION"
OPENWRT_OUTPUT_DIR="$TARGET_DIR/bin/targets/$UINTENT_PRITARGET/$UINTENT_SUBTARGET"

for i in "$OPENWRT_OUTPUT_DIR"/*.bin; do
    [ -f "$i" ] || break
    mv "$i" "$UINTENT_OUTPUT_DIR/"
done
