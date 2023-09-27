#!/bin/bash

rm -rf release-zips

mkdir -p release-zips

cd core
zip -r ../release-zips/tachy-guns-$1-core.zip .
cd ..

cd content-packs
for path in ./*; do
	[ -d "${path}" ] || continue
	dir_name="$(basename "${path}")"

	cd "${dir_name}"
	zip -r ../../release-zips/tachy-guns-$1-${dir_name}.zip .
	cd ..
done
