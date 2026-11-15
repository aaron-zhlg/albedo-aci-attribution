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
| 2. Pick a research direction | Done (Nov 2026) — two topics selected from [`proposals.md`](proposals.md) after expert feedback |
| 3. Data preparation | Ready to run — Docker environment and download scripts in each topic folder |
| 4. Analysis | Not started |

## Topics

Each topic is self-contained (own Docker image, data scripts and README) and can be committed separately.

| Folder | Question | Data | Proposal |
| --- | --- | --- | --- |
| [`china-clean-air-clouds/`](china-clean-air-clouds/) | Did China's SO₂ rise and fall leave a fingerprint on NW Pacific clouds? | ~0.4 TB | [doc](https://claude.ai/artifact/E6Q8dDAVfjaFwty1NUsCeS) |
| [`aci-decomposition/`](aci-decomposition/) | Which part of ACI — Twomey, cloud water or cover — sets the albedo response? | ~3.5–4 TB | [doc](https://claude.ai/artifact/QMCKtt1zFbY3uVimQuoB4c) |

## Layout

```
china-clean-air-clouds/   topic: China emission cuts and NW Pacific clouds (Docker + data scripts)
aci-decomposition/        topic: Twomey vs cloud-water vs cloud-cover decomposition (Docker + data scripts)
proposals.md       candidate research topics (for expert review)
literature/
  review.md        literature review (English), with references table
  figures/         figures used in the review
  papers/          PDFs of the reviewed papers (private copies; do not redistribute)
  fulltext/        plain-text extracts of papers/, for grep and agent search
  notes/           working notes (initial Chinese reading list)
scripts/
  extract_text.py  regenerates literature/fulltext from literature/papers (needs pypdf)
```

Live, commentable version of the review: https://claude.ai/artifact/AjVFJ3p3SyWifTf64VFHnf

## Notes

- The repo is private because `literature/papers/` holds publisher PDFs, some of which
  (e.g. the Science author copy) may not be redistributed.
- Missing PDF: Manshausen et al. 2022, *Nature* (paywalled).
