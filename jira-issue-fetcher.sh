#!/bin/bash

set -euo pipefail

FILE="$(find "$HOME/.mozilla/firefox" -name recovery.jsonlz4)"
ISSUE_RE="[A-Z]{3}-[0-9]+"

ISSUE_KEYS_FIREFOX="$(python <<<$'import os, json, lz4.block
with open("'"$FILE"'", "rb") as f:
   magic = f.read(8)
   jdata = json.loads(lz4.block.decompress(f.read()).decode("utf-8"))
for win in jdata["windows"]:
    for tab in win["tabs"]:
        i = int(tab["index"]) - 1
        titles = tab["entries"][i]["title"]
        print(titles)' | grep -E "\[$ISSUE_RE\]")"

# CHROMIUM_OPEN_TABS="$(find "$HOME/.config/chromium/Default/Sessions" -name "Session_*" -print0 | \
# 	xargs -0 ls -tr1 | tail -n 1 | xargs strings | grep -E "^https?://" | sort -u | grep -E "$ISSUE_RE")"

ISSUE_KEYS_ALL="$(echo "$ISSUE_KEYS_FIREFOX" | sort -u)"

CHOICE="$(echo "$ISSUE_KEYS_ALL" | rofi -l 16 -dmenu -p "Jira issue fetcher")"

ISSUE_KEY="$(grep -oE "$ISSUE_RE" <<<"$CHOICE")"
setxkbmap -layout ch -variant de_nodeadkeys -model pc103
xdotool type "$ISSUE_KEY"
