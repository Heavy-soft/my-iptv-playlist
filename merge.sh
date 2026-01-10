#!/bin/bash
set -e

#####################################
# PHASE 1 — BUILD PLAYLIST
#####################################

ARABIC="https://iptv-org.github.io/iptv/languages/ara.m3u"
FRENCH="https://iptv-org.github.io/iptv/languages/fra.m3u"
ENGLISH="https://iptv-org.github.io/iptv/languages/eng.m3u"

COMBINED="combined.m3u"

echo "#EXTM3U" > "$COMBINED"

# Arabic + French
curl -s "$ARABIC" | tail -n +2 >> "$COMBINED"
curl -s "$FRENCH" | tail -n +2 >> "$COMBINED"

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
' >> "$COMBINED"

echo "✔ Playlist built: $COMBINED"

#####################################
# PHASE 2 — SAFE STREAM TESTING
#####################################

WORKING="working.m3u"
UNVERIFIED="unverified.m3u"
DEAD="dead.m3u"

echo "#EXTM3U" > "$WORKING"
echo "#EXTM3U" > "$UNVERIFIED"
echo "#EXTM3U" > "$DEAD"

test_stream() {
  url="$1"

  # HEAD check
  if curl -I -L --max-time 8 "$url" 2>/dev/null | grep -qE 'HTTP/.* (200|301|302|401|403)'; then
    return 0
  fi

  sleep 2

  # Retry HEAD
  if curl -I -L --max-time 8 "$url" 2>/dev/null | grep -qE 'HTTP/.* (200|301|302|401|403)'; then
    return 0
  fi

  # Partial GET (2KB)
  if curl -L --range 0-2048 --max-time 10 "$url" 2>/dev/null \
     | grep -qE '#EXTM3U|EXTINF|EXT-X|\.ts|\.m4s'; then
    return 0
  fi

  # Server responds but blocks
  if curl -I -L --max-time 8 "$url" 2>/dev/null | grep -q 'HTTP/'; then
    return 2
  fi

  return 1
}

prev=""
while IFS= read -r line; do
  if [[ "$line" == \#EXTINF* ]]; then
    prev="$line"
    continue
  fi

  if [[ "$line" == http* ]]; then
    if test_stream "$line"; then
      echo "$prev" >> "$WORKING"
      echo "$line" >> "$WORKING"
    else
      rc=$?
      if [[ $rc -eq 2 ]]; then
        echo "$prev" >> "$UNVERIFIED"
        echo "$line" >> "$UNVERIFIED"
      else
        echo "$prev" >> "$DEAD"
        echo "$line" >> "$DEAD"
      fi
    fi
  fi
done < "$COMBINED"

echo "✔ Stream testing finished"
echo "✔ Output:"
echo "  - $WORKING"
echo "  - $UNVERIFIED"
echo "  - $DEAD"
