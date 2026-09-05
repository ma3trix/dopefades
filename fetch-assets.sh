#!/usr/bin/env bash
# Pull the Dope Fades photos off Booksy's CDN, then generate web-sized copies.
#
#   cd ~/Developer/biyisandbox/dopefades && ./fetch-assets.sh
#
# WHY THIS IS A SCRIPT AND NOT COMMITTED IMAGES
# ---------------------------------------------
# Two separate reasons, both verified 2026-09-05:
#
#   1. The agent sandbox that built this repo cannot reach the CDN. Its egress
#      proxy (localhost:3128) runs a domain allowlist — pypi.org returns 200,
#      cloudfront.net returns 000. Not an outage; just not on the list.
#      Browsers could load the images but the tooling redacts binary payloads,
#      so the bytes could never reach disk. YOUR Mac has no such restriction.
#
#   2. These photos are Dope Fades' property. assets/ is gitignored on purpose
#      and stays that way until they give permission. See README.md.
#
# All 28 URLs below were verified 200 on 2026-09-05 (9.8 MB of originals).
# Booksy rotates these keys eventually — on 403/404, re-scrape the listing:
#   https://booksy.com/en-ca/4367_dope-fades_barbershop_958511_woodbridge
#
# Instagram (@dopefades_) is deliberately NOT here: its CDN URLs are signed and
# expire within hours, so any baked-in list would be dead on arrival. Use
# `gallery-dl "https://www.instagram.com/dopefades_/"` or ask the shop.

set -uo pipefail
cd "$(dirname "$0")"
mkdir -p assets/_original

CDN="https://d2zdpiztbgorvt.cloudfront.net/region1/ca/4367"
FAIL=0

fetch () {  # fetch <output-name> <path-under-CDN>
  local out="assets/_original/$1" url="$CDN/$2"
  if [[ -s "$out" ]]; then printf '  skip  %s\n' "$1"; return 0; fi
  if curl -fsSL --max-time 60 -o "$out" "$url"; then
    printf '  ok    %-16s %s\n' "$1" "$(du -h "$out" | cut -f1)"
  else
    printf '  FAIL  %-16s <- %s\n' "$1" "$url"; rm -f "$out"; FAIL=$((FAIL+1))
  fi
}

echo "1/2  Downloading originals…"

fetch logo.jpeg  "logo/dbe9c69925f2457c81c6e94d98db66-dope-fades-logo-643fcdef321940e5bfb0afe53dd7fb-booksy.jpeg"
fetch hero.jpeg  "biz_photo/cb9ae229d86e4b0da11b30b93dc7d6-dope-fades-biz-photo-a4d7953ad4084985b02d871a753a3a-booksy.jpeg"

# Shop interior / chairs
fetch shop.jpeg     "resource_photos/33871ec9af2349d1a872f988e5fe298d.jpeg"
fetch shop-02.jpeg  "resource_photos/6e52b9517bcc43668895f27779d10d46.jpeg"
fetch shop-03.jpeg  "resource_photos/4af2182b038544b2a45887e9a591090d.jpeg"
fetch shop-04.jpeg  "resource_photos/34072cdc58b44bcaa8ce1ef77e560a90.jpeg"
fetch shop-05.jpeg  "resource_photos/90eff31d437d48a582443b057cb60894.jpeg"
fetch shop-06.jpeg  "resource_photos/785580ce99354eb5bdeb0e4b4f8397ee.jpeg"

# Work gallery — work-01..08 are what index.html renders
fetch work-01.jpeg  "service_photos/fe9be2b0b119495c995d01c205c82730.jpeg"
fetch work-02.jpeg  "service_photos/ea9516851a6a4d48b172ca43f49ab145.jpeg"
fetch work-03.jpeg  "service_photos/3c889dc735fd462da963d464ab3ac390.jpeg"
fetch work-04.jpeg  "service_photos/3e58ef21c3fc45b5a3bbbd0ebb2f29eb.jpeg"
fetch work-05.jpeg  "service_photos/4ad30bc570b2486190869e101b00f3fa.jpeg"
fetch work-06.jpeg  "service_photos/91c1c79e9b724f6ba078a905bf0f0d77.jpeg"
fetch work-07.jpeg  "service_photos/0345eb8f03e3402baa1ebeba2f024afe.jpeg"
fetch work-08.jpeg  "service_photos/3c58b160796d4270974ffd36566894d4.jpeg"
# Overflow — not rendered, kept for swapping in
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
echo "2/2  Generating web-sized copies…"
# Originals run up to 2340x2340 / 1 MB each — ~9.8 MB total, far too heavy to
# ship. Downscale to a 1000px long edge at q70. sips is built into macOS, so
# there is nothing to install.
if command -v sips >/dev/null 2>&1; then
  for f in assets/_original/*.jpeg; do
    b=$(basename "$f")
    [[ -s "assets/$b" ]] && { printf '  skip  %s\n' "$b"; continue; }
    sips -Z 1000 -s format jpeg -s formatOptions 70 "$f" --out "assets/$b" >/dev/null 2>&1 \
      && printf '  ok    %-16s %s\n' "$b" "$(du -h "assets/$b" | cut -f1)" \
      || printf '  FAIL  %s\n' "$b"
  done
elif command -v magick >/dev/null 2>&1; then
  for f in assets/_original/*.jpeg; do
    b=$(basename "$f")
    [[ -s "assets/$b" ]] && continue
    magick "$f" -resize '1000x1000>' -quality 70 "assets/$b" \
      && printf '  ok    %s\n' "$b"
  done
else
  echo "  no sips or magick found — copying originals through unoptimised"
  cp -n assets/_original/*.jpeg assets/ 2>/dev/null || true
fi

# --- gallery pass ------------------------------------------------------------
# The #work grid is auto-fit minmax(180px,1fr) inside a ~1100px wrap, so a cell
# is never wider than ~355px. 1000px sources pushed the page over its 2 MB
# budget for detail no one can see; 720px still covers a 2x display.
GALLERY=(work-01 shop-03 work-02 work-03 shop-04 work-04 work-08 work-06 work-10 work-13 work-05 work-12)
if command -v sips >/dev/null 2>&1; then
  for b in "${GALLERY[@]}"; do
    [[ -s "assets/_original/$b.jpeg" ]] || continue
    sips -Z 720 -s format jpeg -s formatOptions 68 "assets/_original/$b.jpeg" \
      --out "assets/$b.jpeg" >/dev/null 2>&1
  done
  printf '  ok    %-16s %s  (gallery pass: 12 images at 720px)\n' "gallery" \
    "$(du -ch $(printf 'assets/%s.jpeg ' "${GALLERY[@]}") 2>/dev/null | tail -1 | cut -f1)"
fi

# --- hero override -----------------------------------------------------------
# Booksy's own hero art is a 1108x623 promo crop on flat yellow: too soft for a
# full-bleed background and it fights the dark gradient over it. shop-06 is a
# 2340x2340 in-chair shot against the dark geometric wall, which is what the
# gradient was built for. 1600px q68 — it sits under a 95%-to-55% dark gradient,
# so extra fidelity is invisible and costs page weight. Delete to restore Booksy's.
if [[ -s assets/_original/shop-06.jpeg ]] && command -v sips >/dev/null 2>&1; then
  sips -Z 1600 -s format jpeg -s formatOptions 68 assets/_original/shop-06.jpeg \
    --out assets/hero.jpeg >/dev/null 2>&1 \
    && printf '  ok    %-16s %s  (hero override: shop-06)\n' hero.jpeg "$(du -h assets/hero.jpeg | cut -f1)"
fi

echo
printf 'originals : %s files, %s\n' "$(ls -1 assets/_original 2>/dev/null | wc -l | tr -d ' ')" "$(du -sh assets/_original 2>/dev/null | cut -f1)"
printf 'web-sized : %s files, %s\n' "$(ls -1 assets/*.jpeg 2>/dev/null | wc -l | tr -d ' ')" "$(du -ch assets/*.jpeg 2>/dev/null | tail -1 | cut -f1)"
[[ $FAIL -gt 0 ]] && echo "WARNING: $FAIL download(s) failed — Booksy may have rotated those keys."
echo
echo "Preview:  python3 -m http.server 8777   ->  http://localhost:8777/"
