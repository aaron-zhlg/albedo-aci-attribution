# Albedo decline and recent warming: aerosol vs cloud vs ACI attribution

Research project on why Earth's planetary albedo has been falling and how much of the
resulting increase in absorbed sunlight comes from aerosol–radiation interactions (ARI),
aerosol–cloud interactions (ACI), and cloud changes driven by warming, circulation or
internal variability.

**Core question:** can these contributions be separated with observations — or can one of
them (in particular ACI from recent emission cuts) be shown to dominate?

## Status

| Stage | Status |
| --- | --- |
| 1. Literature review | Done (Oct 2026) — [`literature/review.md`](literature/review.md) |
| 2. Pick a research direction | Open — candidates in review §7 |
| 3. Data and analysis | Not started |

## Layout

```
literature/
  review.md        literature review (English), with references table
  figures/         figures used in the review
  papers/          PDFs of the reviewed papers (private copies; do not redistribute)
  fulltext/        plain-text extracts of papers/, for grep and agent search
scripts/
  extract_text.py  regenerates literature/fulltext from literature/papers (needs pypdf)
```

Live, commentable version of the review: https://claude.ai/artifact/AjVFJ3p3SyWifTf64VFHnf

## Notes

- The repo is private because `literature/papers/` holds publisher PDFs, some of which
  (e.g. the Science author copy) may not be redistributed.
- Missing PDF: Manshausen et al. 2022, *Nature* (paywalled).
