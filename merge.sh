#!/bin/bash

set -e

# IPTV-ORG PLAYLIST SOURCES
ARABIC="https://iptv-org.github.io/iptv/languages/ara.m3u"

FRANCE="https://iptv-org.github.io/iptv/countries/fr.m3u"
UK="https://iptv-org.github.io/iptv/countries/gb.m3u"
CANADA="https://iptv-org.github.io/iptv/countries/ca.m3u"
BELGIUM="https://iptv-org.github.io/iptv/countries/be.m3u"

# Your custom single stream
CUSTOM_STREAM="http://176.65.146.103:8033/playlist.m3u8"

OUT="combined.m3u"

# Write single M3U header
echo "#EXTM3U" > "$OUT"

# Function to append playlist without duplicate header
append_playlist () {
  echo "➕ Adding $1"
  curl -s "$2" | tail -n +2 >> "$OUT"
}

append_playlist "Arabic" "$ARABIC"
append_playlist "France" "$FRANCE"
append_playlist "United Kingdom" "$UK"
append_playlist "Canada" "$CANADA"
append_playlist "Belgium" "$BELGIUM"

# Add single custom stream manually
echo "➕ Adding Custom Stream"
echo '#EXTINF:-1 tvg-name="Custom Stream" group-title="Custom",Custom Stream' >> "$OUT"
echo "$CUSTOM_STREAM" >> "$OUT"

echo "✅ Combined playlist created: $OUT"
