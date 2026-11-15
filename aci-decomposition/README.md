# Which part of ACI sets the albedo response?

When aerosol falls, clouds get fewer, larger droplets: they dim directly (Twomey) and may then lose water or cover (adjustments). This study measures the three terms in three independent natural experiments — the global 2003–2024 droplet decline, the IMO 2020 shipping sulfur cap, and China's staged emission cuts — and tests whether they agree.

- Proposal (with expert feedback, bilingual): https://claude.ai/artifact/QMCKtt1zFbY3uVimQuoB4c
- Background review: [`../literature/review.md`](../literature/review.md)

## Data

`scripts/prepare_data.sh` downloads everything below into `/data` inside the container (the host folder `DATA_DIR`). Total ≈ **3.5–4 TB**; the two MODIS steps are ~1.5 TB each.

| Step | Dataset | Coverage | Size | Account |
| --- | --- | --- | --- | --- |
| `ceds` | CEDS v_2024_07_08 emissions by country and sector, incl. shipping bunkers (Zenodo) | 1750–2022 | < 1 GB | none |
| `era5_monthly` | ERA5 monthly single and pressure levels | 2002–2024, 60°S–60°N | ~10 GB | CDS |
| `era5_daily` | ERA5 daily means, single and pressure levels (SST, stability, humidity, ω, winds) | 2002–2024, 60°S–60°N | ~0.3–0.5 TB | CDS |
| `clara_a3` | CLARA-A3 AVHRR monthly cloud fraction and liquid-cloud properties incl. droplet number (test C) | 1980–present, global | ~10 GB | CDS |
| `merra2` | MERRA-2 monthly aerosol (M2TMNXAER) | 2002–2024, global | 18 GB | Earthdata |
| `modis_daily` | MODIS Aqua L3 daily (MYD08_D3): LWP, cloud fraction, τ, re | 2002–2024, global | 1.46 TB | Earthdata |
| `modis_nd` | Gryspeerdt et al. (2022) MODIS droplet number, daily 1°, Aqua (CEDA) | 2002–2020, global | ~60 GB | none |
| `modis_l2_shipping` | MODIS Aqua L2 cloud swaths (MYD06_L2) over the SE Atlantic shipping corridor (test B) | 2017–2023 | 1.46 TB | Earthdata |
| `ceres` | CERES SSF1deg daily (Aqua, Ed4A) and EBAF Ed4.2.1 | 2002–2024 | 234 GB | Earthdata |
| `omi` | OMI daily NO₂ (OMNO2d) | 2004–2024, global | 85 GB | Earthdata |

Sizes for CDS and CEDA steps are estimates; NASA sizes come from `--dry-run`. The shipping corridor box (`SHIP_BBOX`) and period are set in `scripts/config.sh`.

## One-time account setup

1. **NASA Earthdata** — register at https://urs.earthdata.nasa.gov. Under *Applications → Authorized Apps*, approve **LAADS Web**, **NASA GESDISC DATA ARCHIVE** and **ASDC** (MODIS, MERRA-2/OMI and CERES respectively).
2. **Copernicus CDS** — register at https://cds.climate.copernicus.eu, copy the API token from your profile, and accept the licences on the *Download* tab of [ERA5 monthly single levels](https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels-monthly-means), [ERA5 monthly pressure levels](https://cds.climate.copernicus.eu/datasets/reanalysis-era5-pressure-levels-monthly-means), [ERA5 daily single levels](https://cds.climate.copernicus.eu/datasets/derived-era5-single-levels-daily-statistics), [ERA5 daily pressure levels](https://cds.climate.copernicus.eu/datasets/derived-era5-pressure-levels-daily-statistics) and [satellite cloud properties](https://cds.climate.copernicus.eu/datasets/satellite-cloud-properties).
3. Copy `.env.example` to `.env` and fill in `DATA_DIR`, the Earthdata login and the CDS token.

## Run on Windows (Docker Desktop)

Requires Docker Desktop with the WSL 2 backend. In PowerShell, from this folder:

```powershell
Copy-Item .env.example .env          # then edit .env, e.g. DATA_DIR=D:/climate-data/aci
docker compose build
docker compose run --rm prep bash scripts/prepare_data.sh --dry-run
docker compose run --rm prep bash scripts/prepare_data.sh
```

Notes for Windows:
- Write `DATA_DIR` with forward slashes (`D:/climate-data/aci`). In Docker Desktop, make sure that drive is shared (*Settings → Resources → File sharing*, if shown).
- Downloads to a Windows drive work but file access from the container is slower than inside WSL 2. For heavy analysis, a folder inside the WSL 2 filesystem is faster.
- The full download takes days. Run large steps one at a time (e.g. `... prepare_data.sh modis_daily`) and re-run the same command after any interruption.
- Shell scripts are stored with LF line endings (`.gitattributes`); if you edit them on Windows, keep LF.

## Run on Linux

```bash
cp .env.example .env    # then edit .env
docker compose build
docker compose run --rm prep bash scripts/prepare_data.sh --dry-run
docker compose run --rm prep bash scripts/prepare_data.sh
```

The container runs as root, so downloaded files are owned by root on a Linux host (`sudo chown -R $USER <DATA_DIR>` afterwards if needed).

## Using the scripts

```bash
bash scripts/prepare_data.sh --list                # steps
bash scripts/prepare_data.sh era5_daily ceres      # selected steps only
```

- Re-running is safe: finished NASA files (checked by size), CDS chunks (`.done` markers) and CEDA files (`wget -c`) are skipped.
- Period, domains, shipping box and thread count are set in `scripts/config.sh` and can be overridden in `.env`.
- `docker compose up jupyter` starts JupyterLab on http://localhost:8888 with the data mounted at `/data`.

## Layout

```
docker/               Dockerfile and conda environment
scripts/              prepare_data.sh, config.sh, and Python download helpers in lib/
docker-compose.yml    prep (data download) and jupyter services
.env.example          template for credentials and the data folder
```
