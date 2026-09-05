# Prompt for Claude Code (run on the Mac)

Cowork's sandbox can't fetch these images — its egress proxy returns
`403 blocked-by-allowlist` for Booksy's CDN, and binary payloads are redacted at
the tool boundary. Claude Code running locally has neither restriction.

Paste everything below the line into Claude Code from `~/Developer/biyisandbox`.

---

Work in `~/Developer/biyisandbox/dopefades`. It's a git repo on `main` with its own
remote (`ma3trix/dopefades`, private) and three commits already. Read `README.md`
first — it explains that this is an **unsolicited spec pitch** for a real barbershop
that has not engaged me, and lists the constraints that go with that.

## 1. Fetch the Booksy photos

Run `./fetch-assets.sh`. All 28 URLs in it were verified HTTP 200 on 2026-09-05
(9.8 MB of originals, most 2340×2340). It downloads to `assets/_original/` and
generates 1000px q70 web copies into `assets/` via `sips`.

If any URL 404s, Booksy rotated its keys — re-scrape
`https://booksy.com/en-ca/4367_dope-fades_barbershop_958511_woodbridge`
for fresh ones and update the script.

## 2. Add the Instagram photos

Booksy's listed handle `@hairbydope_` is stale. The live account is
**`@dopefades_`** (348 posts, ~3.8k followers); `@dopefadestoronto` is a second
handle. Instagram CDN URLs are signed and expire within hours, so nothing can be
hardcoded — pull them at runtime:

```bash
brew install gallery-dl        # or: pipx install gallery-dl
gallery-dl -D assets/_instagram "https://www.instagram.com/dopefades_/"
```

Then pick the best 8–12 **work shots** and downscale them into `assets/` as
`ig-01.jpeg`…`ig-NN.jpeg` (1000px long edge, q70, same as the Booksy pass).

Skip the flyers and promo graphics — a lot of that account is text-over-image
marketing posts. Keep clean before/after and finished-cut photos. Aim for a mix:
fades, braids/locs, colour, and hair units.

If `gallery-dl` needs auth or gets rate-limited, don't fight it. Say so and stop —
manual saves from a logged-in browser are a fine fallback.

## 3. Wire them into the page

`index.html` renders `assets/work-01.jpeg` … `work-08.jpeg` in the `#work` gallery,
plus `assets/hero.jpeg` (hero background) and `assets/shop.jpeg` (about section).
Every `<img>` has an `onerror` that hides it, so missing files degrade quietly.

Once the Instagram set exists, rebuild the gallery from the strongest images across
**both** sources — Booksy and Instagram — rather than just appending. Keep it to
8–12. Quality over count.

Also check the hero: the Booksy `hero.jpeg` is only 1108×623, which is soft for a
full-bleed background. If a sharper Instagram shot works better, swap it.

## 4. Verify before you claim done

- `python3 -m http.server 8777` and load `http://localhost:8777/` — confirm **no**
  broken images and no horizontal scroll at 375px width
- Total page weight under ~2 MB
- `git status` clean, and confirm `assets/` and `assets/_original/` are still
  ignored — **the photos must never be committed**, they're the shop's property

## Rules

- **Don't commit any image.** `.gitignore` covers `assets/` and `assets/_original/`.
  Keep it that way.
- **Don't invent a phone number.** Booksy publishes none, so every CTA points at
  their Booksy booking page. This is deliberate.
- **Leave the footer disclaimer** — "not affiliated with or authorised by Dope
  Fades" — until they actually engage.
- **The `#units` section has placeholder pricing.** Toupee/hair-unit work is all
  over their Instagram but absent from Booksy, so no real prices exist. The cards
  say "Quoted" and there's an HTML comment flagging it. Get real numbers or cut
  the section before this is shown to anyone.
- Don't push. Leave commits local.
- Update `~/Developer/biyisandbox/TODO.md` in the same turn, with
  `<!-- due:YYYY-MM-DD -->` tags on anything new.
