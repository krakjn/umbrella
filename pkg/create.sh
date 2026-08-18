#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
PKG=umbrella
ARCH=all

command -v bump >/dev/null || {
	echo "bump is required: https://github.com/krakjn/bump" >&2
	exit 1
}
command -v dpkg-deb >/dev/null || {
	echo "dpkg-deb is required" >&2
	exit 1
}

"$ROOT/api/pkg/create.sh"
"$ROOT/cli/pkg/create.sh"
"$ROOT/lib/pkg/create.sh"
"$ROOT/net/pkg/create.sh"

API_VER=$(bump print "$ROOT/api/bump.toml")
CLI_VER=$(bump print "$ROOT/cli/bump.toml")
LIB_VER=$(bump print "$ROOT/lib/bump.toml")
NET_VER=$(bump print "$ROOT/net/bump.toml")
VERSION=$(bump print "$ROOT/bump.toml")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/share/doc/umbrella"

cat >"$STAGE/usr/share/doc/umbrella/README" <<EOF
umbrella meta-package

Installs the modular deliveries:
  umbrella-api (>= $API_VER)
  umbrella-cli (>= $CLI_VER)
  umbrella-lib (>= $LIB_VER)
  umbrella-net (>= $NET_VER)
EOF

cat >"$STAGE/DEBIAN/control" <<EOF
Package: $PKG
Version: $VERSION
Section: metapackages
Priority: optional
Architecture: $ARCH
Maintainer: Tony B <tony@krakjn>
Homepage: https://github.com/krakjn/umbrella
Depends: umbrella-api (>= $API_VER), umbrella-cli (>= $CLI_VER), umbrella-lib (>= $LIB_VER), umbrella-net (>= $NET_VER)
Description: Umbrella product meta-package
 Pulls in independently versioned module debs. The top level does not
 rebuild the world; it depends on what the modules already shipped.
EOF

mkdir -p "$ROOT/dist"
for mod in api cli lib net; do
	cp "$ROOT/$mod/dist/"*.deb "$ROOT/dist/"
done

DEB="$ROOT/dist/${PKG}_${VERSION}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE" "$DEB"
echo "built $DEB"
echo "collected:"
ls -1 "$ROOT/dist/"*.deb
