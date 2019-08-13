#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

SHTCOIND=${SHTCOIND:-$SRCDIR/shtcoind}
SHTCOINCLI=${SHTCOINCLI:-$SRCDIR/shtcoin-cli}
SHTCOINTX=${SHTCOINTX:-$SRCDIR/shtcoin-tx}
SHTCOINQT=${SHTCOINQT:-$SRCDIR/qt/shtcoin-qt}

[ ! -x $SHTCOIND ] && echo "$SHTCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
SHTVER=($($SHTCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$SHTCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $SHTCOIND $SHTCOINCLI $SHTCOINTX $SHTCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${SHTVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${SHTVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
