"""Download Copernicus CDS datasets (ERA5, CLARA-A3 cloud properties) in yearly or monthly chunks.

Credentials are read from CDSAPI_URL / CDSAPI_KEY. Each chunk leaves a `.done` marker, so the
script can be re-run after an interruption without repeating finished requests. Zip or tar
responses are unpacked into the chunk's folder.

Example:
    python cds_download.py --dataset reanalysis-era5-single-levels-monthly-means \
        --set product_type=monthly_averaged_reanalysis --set variable=sea_surface_temperature \
        --set time=00:00 --set data_format=netcdf --set download_format=unarchived \
        --area 60,40,-10,180 --years 1980-2024 --split year --out /data/era5/monthly_single
"""
import argparse
import calendar
import tarfile
import zipfile
from pathlib import Path


def parse_years(text: str) -> list[int]:
    start, _, end = text.partition("-")
    return list(range(int(start), int(end or start) + 1))


def chunks(years: list[int], split: str, months: list[int]):
    for year in years:
        if split == "year":
            yield f"{year}", {"year": [str(year)], "month": [f"{m:02d}" for m in months]}
        else:
            for m in months:
                days = calendar.monthrange(year, m)[1]
                yield f"{year}{m:02d}", {
                    "year": [str(year)],
                    "month": [f"{m:02d}"],
                    "day": [f"{d:02d}" for d in range(1, days + 1)],
                }


def unpack(path: Path, dest: Path) -> None:
    if zipfile.is_zipfile(path):
        with zipfile.ZipFile(path) as z:
            z.extractall(dest)
        path.unlink()
    elif tarfile.is_tarfile(path):
        with tarfile.open(path) as t:
            t.extractall(dest, filter="data")
        path.unlink()
    else:
        path.rename(path.with_suffix(".nc"))


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--dataset", required=True)
    p.add_argument("--set", action="append", default=[], metavar="KEY=V1,V2",
                   help="request field; comma-separated values become a list")
    p.add_argument("--area", help="N,W,S,E in degrees; omit for global")
    p.add_argument("--years", required=True, help="e.g. 1980-2024")
    p.add_argument("--months", default="1-12", help="e.g. 1-12")
    p.add_argument("--split", choices=["year", "month"], default="year",
                   help="one request per year (monthly data) or per month (daily data)")
    p.add_argument("--day", help="fixed day field for monthly products that require one, e.g. 01")
    p.add_argument("--out", required=True)
    p.add_argument("--prefix", default="cds")
    p.add_argument("--dry-run", action="store_true", help="print the requests without sending them")
    args = p.parse_args()

    base = {}
    for item in args.set:
        key, _, value = item.partition("=")
        values = value.split(",")
        base[key] = values if len(values) > 1 or key in ("variable", "pressure_level") else values[0]
    if args.area:
        base["area"] = [float(x) for x in args.area.split(",")]

    m0, _, m1 = args.months.partition("-")
    months = list(range(int(m0), int(m1 or m0) + 1))
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    todo = []
    for label, fields in chunks(parse_years(args.years), args.split, months):
        if (out / f"{args.prefix}_{label}.done").exists():
            continue
        request = {**base, **fields}
        if args.day:
            request["day"] = [args.day]
        todo.append((label, request))
    print(f"[{args.dataset}] {len(todo)} requests to send")
    if args.dry_run:
        for label, request in todo[:2]:
            print(f"  {label}: {request}")
        return

    import cdsapi

    client = cdsapi.Client()
    for label, request in todo:
        target = out / f"{args.prefix}_{label}.download"
        client.retrieve(args.dataset, request, str(target))
        unpack(target, out)
        (out / f"{args.prefix}_{label}.done").touch()
        print(f"[{args.dataset}] {label} done")


if __name__ == "__main__":
    main()
