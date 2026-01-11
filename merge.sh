#!/bin/bash

set -e

# IPTV-ORG LANGUAGE PLAYLISTS (AUTO UPDATED)
ARABIC="https://iptv-org.github.io/iptv/languages/ara.m3u"
FRENCH="https://iptv-org.github.io/iptv/languages/fra.m3u"

OUT="combined.m3u"

# Write single M3U header
echo "#EXTM3U" > "$OUT"

# Append Arabic channels (skip header)
curl -s "$ARABIC" | tail -n +2 >> "$OUT"

# Append French channels (skip header)
curl -s "$FRENCH" | tail -n +2 >> "$OUT"

echo "✅ Combined Arabic + French playlist created: $OUT"
