#!/bin/bash

set -e

# IPTV-ORG LANGUAGE PLAYLISTS (AUTO UPDATED)
ARABIC="https://iptv-org.github.io/iptv/languages/ara.m3u"
FRENCH="https://iptv-org.github.io/iptv/languages/fra.m3u"

OUT="combined.m3u"

echo "#EXTM3U" > $OUT

curl -s "$ARABIC" | tail -n +2 >> $OUT
