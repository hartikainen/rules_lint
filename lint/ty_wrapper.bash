#!/usr/bin/env bash

set -uo pipefail

readonly TY="$1"
readonly STDOUT="$2"
readonly EXIT_CODE="$3"
readonly COLOR="$4"
readonly SEARCH_PATHS_FILE="$5"
readonly TY_ARGS_FILE="$6"

readonly SEARCH_ARGS_FILE="$(mktemp)"
readonly TMP_OUT="$(mktemp)"
trap 'rm -f "$SEARCH_ARGS_FILE" "$TMP_OUT"' EXIT

while IFS= read -r path; do
    if [[ -d "$path" ]]; then
        printf '%s\n' "--extra-search-path" "$path" >> "$SEARCH_ARGS_FILE"
    fi
done < "$SEARCH_PATHS_FILE"

"$TY" check --force-exclude --color "$COLOR" @"$SEARCH_ARGS_FILE" "$TY_ARGS_FILE" > "$TMP_OUT" 2>&1
ret=$?

if [[ "$ret" -eq 0 ]]; then
    : > "$STDOUT"
else
    cp "$TMP_OUT" "$STDOUT"
fi

if [[ -n "$EXIT_CODE" ]]; then
    printf '%s\n' "$ret" > "$EXIT_CODE"
elif [[ "$ret" -ne 0 ]]; then
    cat "$TMP_OUT" >&2
    exit "$ret"
fi
