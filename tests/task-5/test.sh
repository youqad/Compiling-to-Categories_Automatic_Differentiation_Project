#!/usr/bin/env bash

set -e

BASE=$1
JOUJOU=../../joujou
COMPILE="ocamlopt -O3"

$JOUJOU --compact $BASE.j # Compact the output or else face a StackOverflow in ocamlopt.
$COMPILE -c category.ml
$COMPILE -c $BASE.ml
$COMPILE -c diffCat.ml
$COMPILE -o "$BASE"_test category.cmx diffCat.cmx $BASE.cmx "$BASE"_test.ml
./"$BASE"_test
