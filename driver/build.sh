#!/bin/sh
# driver/build.sh - build the Nextor kernel ROM with the TC8566AF driver.
#
# Run inside WSL. Requires N80 + mknexrom in PATH (or ~/nextor-tools) and a
# prebuilt nextor_base.dat (make base in nextor/source/kernel).
#
# Output: bin/nextor-tc8566af.rom
set -eu

cd "$(dirname "$0")/.."
REPO="$PWD"
KERNEL="$REPO/nextor/source/kernel"
OUT="$REPO/bin"

PATH="$HOME/nextor-tools:$PATH"

N80_FLAGS="--build-type abs --output-file-extension bin \
  --no-string-escapes --no-show-banner --verbosity 0 --output-file-case lower"

[ -f "$KERNEL/nextor_base.dat" ] || {
  echo "ERROR: $KERNEL/nextor_base.dat not found. Run 'make base' there first." >&2
  exit 1
}

mkdir -p "$OUT"

# INCLUDE MACROS.INC/CONST.INC resolve against the cwd, hence the cd.
cd "$KERNEL"

# shellcheck disable=SC2086  # N80_FLAGS is intentionally word-split
N80 "$REPO/driver/tc8566af.mac" "$REPO/driver/tc8566af.bin" $N80_FLAGS
# shellcheck disable=SC2086
#
# Panasonic 7FF0h CHGBNK (not the upstream StandaloneASCII16 6000h version):
# both blueMSX and openMSX accept 7FF0h writes, only blueMSX accepts 6000h,
# so this flavor keeps blueMSX working while making openMSX's TurboRFDC
# device switch banks too.  See driver/chgbnk-panasonic.mac for details.
N80 "$REPO/driver/chgbnk-panasonic.mac" "$REPO/driver/chgbnk_pana.bin" $N80_FLAGS

# Driver file for mknexrom = 256 dummy bytes (kernel page 0 area) + driver body.
dd if=/dev/zero of="$REPO/driver/256.bytes" bs=1 count=256 status=none
cat "$REPO/driver/256.bytes" "$REPO/driver/tc8566af.bin" > "$REPO/driver/_driver.bin"

# mknexrom treats any argument starting with '/' as an option, so absolute
# Unix paths cannot be passed; run from the repo root with relative paths.
cd "$REPO"
mknexrom nextor/source/kernel/nextor_base.dat bin/nextor-tc8566af.rom \
  /d:driver/_driver.bin /m:driver/chgbnk_pana.bin

rm -f "$REPO/driver/256.bytes" "$REPO/driver/_driver.bin"

ls -la "$OUT/nextor-tc8566af.rom"
