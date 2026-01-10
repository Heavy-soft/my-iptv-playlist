#!/bin/bash
set -e

# IPTV-ORG SOURCES
ARABIC="https://iptv-org.github.io/iptv/languages/ara.m3u"
FRENCH="https://iptv-org.github.io/iptv/languages/fra.m3u"
ENGLISH="https://iptv-org.github.io/iptv/languages/eng.m3u"

OUT="combined.m3u"

echo "#EXTM3U" > "$OUT"

# Arabic + French (as-is)
curl -s "$ARABIC" | tail -n +2 >> "$OUT"
curl -s "$FRENCH" | tail -n +2 >> "$OUT"

# English → US + UK + CA only
curl -s "$ENGLISH" | awk '
BEGIN { keep=0 }
/^#EXTINF/ {
  keep = ($0 ~ /tvg-id="[^"]*\.(us|uk|ca)@/)
  if (keep) {
    gsub(/\s*\[(Geo-blocked|Not 24\/7)[^\]]*\]/, "", $0)
  }
}
{
  if (keep) print
}
' >> "$OUT"
