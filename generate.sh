#!/bin/bash

# usage: ./generate.sh EXECUTABLE

if [ $# -ne 1 ]; then
    echo "Usage: $0 <executable>"
    exit 1
fi

EXEC="$1"

if [ ! -x "$EXEC" ]; then
    echo "Error: '$EXEC' is not executable"
    exit 1
fi

echo "Generating expected outputs..."

for test in tests/*; do
    # skip already-generated expected files
    [[ "$test" == *.expected ]] && continue

    name=$(basename "$test")
    out="tests/$name.expected"

    echo "  -> $name"
    "$EXEC" "$test" &> "$out"
done

echo "Done."