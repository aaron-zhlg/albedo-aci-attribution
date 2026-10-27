"""Extract plain text from every PDF in literature/papers into literature/fulltext.

Usage: python scripts/extract_text.py
"""
import re
from pathlib import Path

import pypdf

ROOT = Path(__file__).resolve().parent.parent
PAPERS = ROOT / "literature" / "papers"
OUT = ROOT / "literature" / "fulltext"

OUT.mkdir(parents=True, exist_ok=True)
for pdf in sorted(PAPERS.glob("*.pdf")):
    reader = pypdf.PdfReader(pdf)
    text = " ".join(page.extract_text() or "" for page in reader.pages)
    (OUT / f"{pdf.stem}.txt").write_text(re.sub(r"\s+", " ", text))
    print(f"{pdf.name}: {len(reader.pages)} pages")
