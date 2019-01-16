#!/usr/bin/env bash

set -e

INPUT=$1
BASE=`echo $INPUT | sed s/.j//`
JOUJOU=../../joujou

$JOUJOU $INPUT
ocamlc -c "$BASE".ml
ocamlc -c "$BASE"_test.ml
ocamlc -o "$BASE"_test category.cmo "$BASE".cmo "$BASE"_test.cmo
./"$BASE"_test
