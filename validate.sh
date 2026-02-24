#!/bin/bash

# usage: ./validate.sh EXECUTABLE

if [ $# -ne 1 ]; then
    echo "Usage: $0 <executable>"
    exit 1
fi

EXEC="$1"

if [ ! -x "$EXEC" ]; then
    echo "Error: '$EXEC' is not executable"
    exit 1
fi

PASS=0
FAIL=0

echo "Running lexer validation..."
echo

for test in tests/*; do
    [[ "$test" == *.expected ]] && continue

    name=$(basename "$test")
    expected="tests/$name.expected"

    if [ ! -f "$expected" ]; then
        echo "⚠ Missing expected file for $name"
        continue
    fi

    "$EXEC" "$test" &> .current.out

    if diff -u .current.out "$expected" > .diff.out; then
        echo "✅ $name PASSED"
        ((PASS++))
    else
        echo "❌ $name FAILED"
        cat .diff.out
        ((FAIL++))
    fi
done

rm -f .current.out .diff.out

echo
echo "Passed: $PASS"
echo "Failed: $FAIL"