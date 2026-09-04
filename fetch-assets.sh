#!/usr/bin/env bash
# Pull the Dope Fades photos off Booksy's CDN into ./assets/.
#
# Why this is a script and not committed images: the agent sandbox that built
# this repo has no route to the CDN, and these photos are the shop's property —
# keeping them out of git until permission exists is deliberate. Run it on your
# own machine.
#
#   cd ~/Developer/biyisandbox/dopefades && ./fetch-assets.sh
#
# Source listing:
#   https://booksy.com/en-ca/4367_dope-fades_barbershop_958511_woodbridge
# Captured 2026-09-03. Booksy rotates these keys — if you get 403/404, re-scrape
# the listing for fresh URLs.

set -euo pipefail
cd "$(dirname "$0")"
mkdir -p assets

CDN="https://d2zdpiztbgorvt.cloudfront.net/region1/ca/4367"

fetch () {  # fetch <output-name> <path-under-CDN>
  local out="assets/$1" url="$CDN/$2"
  if [[ -f "$out" ]]; then
    printf '  skip  %s (exists)\n' "$1"; return 0
  fi
  if curl -fsSL --max-time 30 -o "$out" "$url"; then
    printf '  ok    %-16s %s\n' "$1" "$(du -h "$out" | cut -f1)"
  else
    printf '  FAIL  %s\n' "$1"; rm -f "$out"
  fi
}

echo "Fetching Dope Fades assets…"

# Brand + hero
fetch logo.jpeg  "logo/dbe9c69925f2457c81c6e94d98db66-dope-fades-logo-643fcdef321940e5bfb0afe53dd7fb-booksy.jpeg"
fetch hero.jpeg  "biz_photo/cb9ae229d86e4b0da11b30b93dc7d6-dope-fades-biz-photo-a4d7953ad4084985b02d871a753a3a-booksy.jpeg"

# Shop interior / staff
fetch shop.jpeg     "resource_photos/33871ec9af2349d1a872f988e5fe298d.jpeg"
fetch shop-02.jpeg  "resource_photos/6e52b9517bcc43668895f27779d10d46.jpeg"
fetch shop-03.jpeg  "resource_photos/4af2182b038544b2a45887e9a591090d.jpeg"
fetch shop-04.jpeg  "resource_photos/34072cdc58b44bcaa8ce1ef77e560a90.jpeg"
fetch shop-05.jpeg  "resource_photos/90eff31d437d48a582443b057cb60894.jpeg"
fetch shop-06.jpeg  "resource_photos/785580ce99354eb5bdeb0e4b4f8397ee.jpeg"

# Work gallery (service photos) — work-01..08 are the ones index.html renders
fetch work-01.jpeg  "service_photos/fe9be2b0b119495c995d01c205c82730.jpeg"
fetch work-02.jpeg  "service_photos/ea9516851a6a4d48b172ca43f49ab145.jpeg"
fetch work-03.jpeg  "service_photos/3c889dc735fd462da963d464ab3ac390.jpeg"
fetch work-04.jpeg  "service_photos/3e58ef21c3fc45b5a3bbbd0ebb2f29eb.jpeg"
fetch work-05.jpeg  "service_photos/4ad30bc570b2486190869e101b00f3fa.jpeg"
fetch work-06.jpeg  "service_photos/91c1c79e9b724f6ba078a905bf0f0d77.jpeg"
fetch work-07.jpeg  "service_photos/0345eb8f03e3402baa1ebeba2f024afe.jpeg"
fetch work-08.jpeg  "service_photos/3c58b160796d4270974ffd36566894d4.jpeg"

# Overflow — not referenced by index.html, kept for swapping in
fetch work-09.jpeg  "service_photos/48ba701b59b7472f8e6a3a547fcf745e.jpeg"
fetch work-10.jpeg  "service_photos/8dced730e8ea4305a480f73a16836482.jpeg"
fetch work-11.jpeg  "service_photos/16f6efe2042d4f7bb7cb9093f5af88f3.jpeg"
fetch work-12.jpeg  "service_photos/04162e72cc1c4f03af57ee34abffec1c.jpeg"
fetch work-13.jpeg  "service_photos/37acff4b192445619c11f10b5f9927c4.jpeg"
fetch work-14.jpeg  "service_photos/e01d21da5a664d678559e4a20b874538.jpeg"
fetch work-15.jpeg  "service_photos/4cdcfe4cacf44cba884fff7816398a9d.jpeg"
fetch work-16.jpeg  "service_photos/5e876082ea97458ca8cf0b44c993fdc8.jpeg"
fetch work-17.jpeg  "service_photos/f0fc5ac2ee174b14bde4a9d406d2c11a.jpeg"
fetch work-18.jpeg  "service_photos/63d73ea1a69c4eefbd6e363cd2a6a148.jpeg"
fetch work-19.jpeg  "service_photos/7812c7ede76e45c4a336d7df1e84a146.jpeg"
fetch work-20.jpeg  "service_photos/92fa2d29b0c9425b9783b9b094e0c323.jpeg"

echo
echo "Done. $(ls -1 assets 2>/dev/null | wc -l | tr -d ' ') files in assets/"
echo "Preview:  python3 -m http.server 8777   →  http://localhost:8777/"
