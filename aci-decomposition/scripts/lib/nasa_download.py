"""Search and download NASA Earthdata granules (MODIS, CERES, MERRA-2, OMI) with earthaccess.

Credentials are read from EARTHDATA_USERNAME / EARTHDATA_PASSWORD (or EARTHDATA_TOKEN).
Files already on disk with the expected size are skipped, so the script can be re-run after
an interruption.

Example:
    python nasa_download.py --short-name MYD08_M3 --version 6.1 \
        --start 2002-07-01 --end 2024-12-31 --out /data/modis/MYD08_M3 --dry-run
"""
import argparse
from pathlib import Path

import earthaccess


def size_mb(granule) -> float:
    # `size` is a method in older earthaccess releases and a property in newer ones.
    size = granule.size
    return float(size() if callable(size) else size or 0)


def is_complete(path: Path, expected_mb: float) -> bool:
    if not path.exists():
        return False
    if not expected_mb:
        return True
    return abs(path.stat().st_size / 2**20 - expected_mb) <= max(0.01 * expected_mb, 0.1)


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--short-name", required=True)
    p.add_argument("--version")
    p.add_argument("--start", required=True, help="YYYY-MM-DD")
    p.add_argument("--end", required=True, help="YYYY-MM-DD")
    p.add_argument("--bbox", help="W,S,E,N in degrees; omit for global")
    p.add_argument("--out", required=True)
    p.add_argument("--threads", type=int, default=8)
    p.add_argument("--dry-run", action="store_true", help="only report granule count and size")
    args = p.parse_args()

    query = dict(short_name=args.short_name, temporal=(args.start, args.end), count=-1)
    if args.version:
        query["version"] = args.version
    if args.bbox:
        query["bounding_box"] = tuple(float(x) for x in args.bbox.split(","))

    granules = earthaccess.search_data(**query)
    total_gb = sum(size_mb(g) for g in granules) / 1024
    print(f"[{args.short_name}] {len(granules)} granules, {total_gb:.1f} GB")
    if args.dry_run or not granules:
        return

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    todo = [g for g in granules if not is_complete(out / Path(g.data_links()[0]).name, size_mb(g))]
    print(f"[{args.short_name}] {len(todo)} to download, {len(granules) - len(todo)} already complete")
    if not todo:
        return

    earthaccess.login(strategy="environment")
    earthaccess.download(todo, local_path=str(out), threads=args.threads)


if __name__ == "__main__":
    main()
