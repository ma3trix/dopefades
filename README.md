# Dope Fades — concept site

**Status: unsolicited spec pitch. Not authorised, not deployed, not shown to anyone yet.**

A one-page site for [DOPE FADES](https://booksy.com/en-ca/4367_dope-fades_barbershop_958511_woodbridge),
a barbershop and braiding studio at 5308 Hwy 7 #4, Woodbridge (Vaughan). Built
2026-09-03 from the northfade template as a pitch piece for the web micro-service
stream — see `../web-service-playbook.md`.

## Run it

```bash
./fetch-assets.sh          # pulls photos off Booksy's CDN into assets/
python3 -m http.server 8777
```

Then <http://localhost:8777/>. Without the assets step the page still renders —
every image has an `onerror` that hides it, and the hero falls back to a flat
dark panel. It looks unfinished, not broken.

## Where the content came from

Everything is scraped from the public Booksy listing on 2026-09-03: name,
address, geo, hours, the full service list with prices, the 4.9/453 rating, the
staff names, the amenities, and the "if you cherish your look, value your time"
line, which is their own copy. The `<h1>` — *the art of hair, literally* — is
also theirs, lifted from the listing bio.

`index.html` carries a `<script type="application/ld+json">` block rebuilt from
their Booksy schema, so hours and geo are structured correctly if this ever goes
live.

## Instagram — @dopefades_ (checked 2026-09-05)

**Booksy's listed handle is wrong.** It points at `@hairbydope_`; the live account
is [`@dopefades_`](https://www.instagram.com/dopefades_/) — 348 posts, 3,779
followers — with `@dopefadestoronto` as a second handle. The site now links to
`@dopefades_`.

What the Instagram says that Booksy doesn't:

- **Tagline is stronger there.** *"WE GUARANTEE YOUR BEST HAIRCUT EVER!"* — now
  quoted in the hero. Booksy's "if you cherish your look, value your time" is the
  about heading.
- **They do toupees and hair units, and it is not on the Booksy menu at all.**
  There's a `TOUPE/HAIRUNIT` story highlight and repeated posts — *"Get a fitting
  toupee, seamless and undetectable"*, *"Real human hair unit BEFORE AFTER"*,
  free consultation by DM. This is a whole revenue line with no online booking
  path. New `#units` section on the page covers it. **No prices exist for it** —
  the cards say "Quoted" and there's an HTML comment flagging that.
- **Colour is bigger than Booksy suggests.** A `COLOUR` highlight and colour
  posts, against a single "Hair Dye (Black) $60" line on Booksy.
- **The braiding side is co-branded.** `@shinbraidsandlocs` is Shin's own handle.
  Other barbers post under `@slattysnips`, `@fades_byshhhhhh`, `@_fadeverse_`,
  `@j.buoy`.

### The Instagram photos could not be downloaded

Not a permission problem — a technical one, and it will not be solved by retrying:

| Route | Why it fails |
|---|---|
| Server-side fetch | The build sandbox has no network route to Instagram, and Instagram blocks non-browser clients anyway |
| Read the image URLs from the page | Instagram CDN URLs are signed and expire within hours; the browser tooling redacts them as credential-bearing |
| Read pixels off a canvas | Works — the images aren't CORS-tainted — but the tooling redacts base64 image payloads |
| Right-click → Save As | Browsers are read-only to the desktop-control tooling |

**So `assets/` gets filled by `fetch-assets.sh` (Booksy) only.** Those 26 photos
are the same shop, the same work, unsigned URLs, full resolution — they are the
better source regardless.

If you specifically want the Instagram set, the options are: save them by hand
from your own browser, run a dedicated tool locally (`gallery-dl
"https://www.instagram.com/dopefades_/"`), or — the right answer for a real
engagement — **ask the shop for the originals.** Instagram re-compresses
everything; the files on the barbers' phones are better than anything scraped.

## Four things to fix before this is shown to anyone

1. **Photo permission.** `assets/` is gitignored and the images are the shop's
   property, served off Booksy's CDN. Fine for a private mockup on your laptop.
   Not fine on a public URL without written permission. Get it first.
2. **There is no phone number.** Booksy does not publish one and none was
   invented. Every CTA points at their Booksy booking page instead. If they
   engage, get the real number and swap the CTAs to `tel:`.
3. **Prices drift and are per-barber.** The listing shows the same service at
   different prices for different staff — Dope Fade is $49.99 with one barber
   and $50.00 with another, and the $79.99 tier is a different service. The page
   uses `$49.99+` style ranges to stay honest. Confirm before quoting.
4. **The footer disclaimer stays** until they say yes: *"Concept site by
   BIYISANDBOX STUDIOS — not affiliated with or authorised by Dope Fades."*
   Remove it only after engagement.

## Pitch angle

They have 453 reviews at 4.9 and no website — Booksy is the whole web presence.
That's the argument: they rank on Booksy's domain, not their own, and every
search for "dope fades woodbridge" sends traffic to a directory that also lists
their competitors. A $500–800 one-pager on their own domain fixes that.

The braiding side is the differentiator worth leading with — most barbershop
sites in Vaughan don't cover cornrows, locs and wig work, and Shin's service
list is deeper than the barbering menu.

## Lineage

Cloned from `../northfade/` (the retired demo, made private 2026-09-03). This is
a fresh git history — it does **not** share a remote with northfade. `assets/`
is gitignored; the repo is text-only.
