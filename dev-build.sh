#!/bin/bash


cd "./public_www"

for f in `find ./scripts -type f -iname "*.coffee"`; do
	echo "$f"
	coffee -cb "$f"
done

for f in `find ./styles -type f -iname "*.scss"`; do
	echo "$f"
	scss -q --update "$f"
done
