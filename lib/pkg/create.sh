#!/bin/sh
set -eu

MOD=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
REPO=$(CDPATH= cd -- "$MOD/.." && pwd)
PKG=umbrella-lib

command -v bump >/dev/null || {
	echo "bump is required: https://github.com/krakjn/bump" >&2
	exit 1
}
command -v cmake >/dev/null || {
	echo "cmake is required" >&2
	exit 1
}
command -v dpkg-deb >/dev/null || {
	echo "dpkg-deb is required" >&2
	exit 1
}

if [ ! -f "$REPO/api/gen/schema.h" ]; then
	"$REPO/api/pkg/generate.sh"
fi

ARCH=$(dpkg --print-architecture 2>/dev/null || echo amd64)
VERSION=$(bump print --only-base "$MOD/bump.toml")
bump emit c -o "$MOD/version.h" "$MOD/bump.toml"

cmake -S "$MOD" -B "$MOD/build" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build "$MOD/build"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
DESTDIR="$STAGE" cmake --install "$MOD/build"

mkdir -p "$STAGE/DEBIAN"
cat >"$STAGE/DEBIAN/control" <<EOF
Package: $PKG
Version: $VERSION
Section: libs
Priority: optional
Architecture: $ARCH
Maintainer: Tony B <tony@krakjn>
Homepage: https://github.com/krakjn/umbrella
Description: C hello library for umbrella
 Shared library whose greeting comes from the generated api schema.
EOF

mkdir -p "$MOD/dist"
DEB="$MOD/dist/${PKG}_${VERSION}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE" "$DEB"
echo "built $DEB"
