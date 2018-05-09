#!/bin/bash

# Customize here:
arch=amd64
version=3.1.3
rev=1
# stop customizing

tmp=$(mktemp -d)
echo "Working in $tmp"

package="ts3server"
binname="teamspeak3-server_linux_${arch}"
dl="${tmp}/${package}.tar.gz"
wget "-O${dl}" "http://dl.4players.de/ts/releases/${version}/${binname}-${version}.tar.bz2"
tar xf "$dl" -C "$tmp"
rm "$dl"
unpacked="${tmp}/${binname}"

build="${tmp}/build"

mkdir "$build"
cp -R base/* "$build"

mkdir -p "${build}/etc/${package}/license"
sed -i \
    -e "s/__VERSION__/${version}-${rev}/" \
    -e "s/__ARCH__/${arch}/" \
    "${build}/DEBIAN/control"

mkdir -p "${build}/usr/bin"
cp "${unpacked}/ts3server" "${build}/usr/bin/ts3server"
chmod +x "${build}/usr/bin/ts3server"

mkdir -p "${build}/usr/lib"
cp "${unpacked}/"*.so "${build}/usr/lib/"

mkdir -p "${build}/usr/share/licenses/${package}"
cp "${unpacked}/LICENSE" "${build}/usr/share/licenses/${package}"

mkdir -p "${build}/usr/share/doc/${package}"
cp -a "${unpacked}/doc" "${build}/usr/share/doc/${package}"

mkdir -p "${build}/usr/share/${package}"
cp -a "${unpacked}/sql" "${build}/usr/share/${package}"

mkdir -p "${build}/var/lib/${package}/files"
cp -R "${unpacked}/redist" "${build}/var/lib/${package}"
touch "${build}/var/lib/${package}/.ts3server_license_accepted"

mkdir -p "${build}/var/log/${package}"

dpkg-deb --build "$build"
mv "${tmp}/$(basename "$build").deb" "${package}_${version}-${rev}.deb"

rm -Rf ${tmp}

