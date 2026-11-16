# Which part of ACI sets the albedo response?

When aerosol falls, clouds get fewer, larger droplets: they dim directly (Twomey) and may then lose water or cover (adjustments). This study measures the three terms in three independent natural experiments — the global 2003–2024 droplet decline, the IMO 2020 shipping sulfur cap, and China's staged emission cuts — and tests whether they agree.

- Proposal (with expert feedback, bilingual): https://claude.ai/artifact/QMCKtt1zFbY3uVimQuoB4c
- Background review: [`../literature/review.md`](../literature/review.md)

## Data

`scripts/prepare_data.sh` downloads everything below into `/data` inside the container, which is the folder set by `DATA_PATH` in `.env` (see below). Total ≈ **3.5–4 TB**; the two MODIS steps are ~1.5 TB each.

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

## Where the data goes

`DATA_PATH` in `.env` (step 2 below) is the folder on the workstation that every dataset is downloaded into.

```
DATA_PATH=D:/climate-data/aci        # Windows (forward slashes)
DATA_PATH=/mnt/bigdisk/climate-data   # Linux
```

- The folder needs ~4 TB free. It is created if it does not exist.
- Inside the container the same folder is `/data`; the scripts and JupyterLab only ever see `/data`.
- Without `DATA_PATH`, data goes to `./data` next to this README.
- Each dataset gets its own subfolder (`ceds/`, `era5/`, `modis/`, …). To move the data later, copy the folder and change `DATA_PATH`.

## Download sources

Every download address, dataset ID and version is read from `.env`. The defaults are in the *Download sources* block of [`.env.example`](.env.example), so copying `.env.example` to `.env` gives a working setup:

| Source | Names in `.env` | Default |
| --- | --- | --- |
| Zenodo (CEDS) | `CEDS_URL`, `CEDS_FILES` | `https://zenodo.org/api/records/12803197/files` |
| CEDA (MODIS Nd) | `MODIS_ND_URL`, `MODIS_ND_PATTERN` | `https://dap.ceda.ac.uk/badc/deposited2022/modis_cdnc_sampling_gridded/data` |
| Copernicus CDS | `CDS_ERA5_MONTHLY_SINGLE`, `CDS_ERA5_MONTHLY_PRESSURE`, `CDS_ERA5_DAILY_SINGLE`, `CDS_ERA5_DAILY_PRESSURE`, `CDS_CLARA` | dataset IDs; the API address is `CDSAPI_URL` in `.env` |
| NASA Earthdata | `MERRA2_AER`/`MERRA2_VERSION`, `MODIS_AQUA_D3`, `MODIS_AQUA_L2`/`MODIS_VERSION`, `CERES_SSF_DAY`/`CERES_SSF_VERSION`, `CERES_EBAF`/`CERES_EBAF_VERSION`, `OMI_NO2`/`OMI_VERSION` | short names and versions; `earthaccess` looks up the file URLs in NASA's catalogue (CMR), which point to LAADS, GES DISC or ASDC |

To switch mirror, record or version, edit that line in `.env` (for example `MODIS_VERSION=6.2`). `prepare_data.sh` contains no addresses of its own; if a name is missing from `.env` it stops and lists what to add.

## One-time account setup

1. **NASA Earthdata** — register at https://urs.earthdata.nasa.gov. Under *Applications → Authorized Apps*, approve **LAADS Web**, **NASA GESDISC DATA ARCHIVE** and **ASDC** (MODIS, MERRA-2/OMI and CERES respectively).
2. **Copernicus CDS** — register at https://cds.climate.copernicus.eu, copy the API token from your profile, and accept the licences on the *Download* tab of [ERA5 monthly single levels](https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels-monthly-means), [ERA5 monthly pressure levels](https://cds.climate.copernicus.eu/datasets/reanalysis-era5-pressure-levels-monthly-means), [ERA5 daily single levels](https://cds.climate.copernicus.eu/datasets/derived-era5-single-levels-daily-statistics), [ERA5 daily pressure levels](https://cds.climate.copernicus.eu/datasets/derived-era5-pressure-levels-daily-statistics) and [satellite cloud properties](https://cds.climate.copernicus.eu/datasets/satellite-cloud-properties).

## Download the data

Run these steps on the workstation, from this folder. Docker Desktop with the WSL 2 backend on Windows (PowerShell), or Docker on Linux.

**Step 1 — create `.env`.** Copy the template:

```powershell
Copy-Item .env.example .env     # Windows PowerShell
```
```bash
cp .env.example .env            # Linux
```

**Step 2 — edit `.env` and make sure it contains these lines.** Change `DATA_PATH` to the folder where the data should go (~4 TB free; on Linux e.g. `/mnt/bigdisk/climate-data`) and fill in the three `<...>` values from the account setup. The download sources can stay as shown.

```
# DATA_PATH: folder on this machine where all data is downloaded (needs ~4 TB free). Windows example: D:/climate-data/aci
DATA_PATH=D:/climate-data/aci

# NASA Earthdata login (https://urs.earthdata.nasa.gov) for MODIS, CERES, MERRA-2 and OMI
EARTHDATA_USERNAME=<your Earthdata username>
EARTHDATA_PASSWORD=<your Earthdata password>

# Copernicus Climate Data Store API token (https://cds.climate.copernicus.eu, profile page)
CDSAPI_URL=https://cds.climate.copernicus.eu/api
CDSAPI_KEY=<your CDS API token>

# ---------------------------------------------------------------------------
# Download sources. prepare_data.sh reads every address, dataset ID and version
# from here; change a line to switch mirror, record or version.
# ---------------------------------------------------------------------------

# CEDS emissions (Zenodo, no account): each file is downloaded from CEDS_URL/<file>/content
CEDS_URL=https://zenodo.org/api/records/12803197/files
CEDS_FILES=CEDS_v_2024_07_08_aggregate.zip CEDS_v_2024_07_08_detailed.zip CEDS_v_2024_07_08_supplementary_bunkers.zip

# MODIS droplet number, Gryspeerdt et al. 2022 (CEDA, no account): files under MODIS_ND_URL/<year>/
MODIS_ND_URL=https://dap.ceda.ac.uk/badc/deposited2022/modis_cdnc_sampling_gridded/data
MODIS_ND_PATTERN=modis_nd.*.A.v1.nc

# Copernicus CDS dataset IDs (requests go to CDSAPI_URL above)
CDS_ERA5_MONTHLY_SINGLE=reanalysis-era5-single-levels-monthly-means
CDS_ERA5_MONTHLY_PRESSURE=reanalysis-era5-pressure-levels-monthly-means
CDS_ERA5_DAILY_SINGLE=derived-era5-single-levels-daily-statistics
CDS_ERA5_DAILY_PRESSURE=derived-era5-pressure-levels-daily-statistics
CDS_CLARA=satellite-cloud-properties

# NASA Earthdata short names and versions. earthaccess looks up the file URLs in NASA's
# catalogue (CMR), which point to LAADS (MODIS), GES DISC (MERRA-2, OMI) or ASDC (CERES).
MERRA2_AER=M2TMNXAER
MERRA2_VERSION=5.12.4
MODIS_AQUA_D3=MYD08_D3
MODIS_AQUA_L2=MYD06_L2
MODIS_VERSION=6.1
CERES_SSF_DAY=CER_SSF1deg-Day_Aqua-MODIS
CERES_SSF_VERSION=Edition4A
CERES_EBAF=CERES_EBAF
CERES_EBAF_VERSION=Edition4.2.1
OMI_NO2=OMNO2d
OMI_VERSION=003
```

**Step 3 — build the image** (once, and again after changing `docker/`):

```bash
docker compose build
```

**Step 4 — check.** Lists every request and its size without downloading. It stops with "Missing in .env: …" if a line from step 2 is missing.

```bash
docker compose run --rm prep bash scripts/prepare_data.sh --dry-run
```

**Step 5 — download.** Everything lands in `DATA_PATH`. Re-run the same command after any interruption; finished files are skipped.

```bash
docker compose run --rm prep bash scripts/prepare_data.sh
```

Notes for Windows:
- Write `DATA_PATH` with forward slashes (`D:/climate-data/aci`). In Docker Desktop, make sure that drive is shared (*Settings → Resources → File sharing*, if shown).
- Downloads to a Windows drive work but file access from the container is slower than inside WSL 2. For heavy analysis, a folder inside the WSL 2 filesystem is faster.
- The full download takes days. Run large steps one at a time (e.g. `... prepare_data.sh modis_daily`).
- Shell scripts are stored with LF line endings (`.gitattributes`); if you edit them on Windows, keep LF.

Note for Linux: the container runs as root, so downloaded files are owned by root (`sudo chown -R $USER <DATA_PATH>` afterwards if needed).

## Using the scripts

```bash
bash scripts/prepare_data.sh --list                # steps
bash scripts/prepare_data.sh era5_daily ceres      # selected steps only
```

- Re-running is safe: finished NASA files (checked by size), CDS chunks (`.done` markers) and CEDA files (`wget -c`) are skipped.
- Period, domains, shipping box and thread count are set in `scripts/config.sh` and can be overridden in `.env`; download sources are set in `.env`.
- `docker compose up jupyter` starts JupyterLab on http://localhost:8888 with the data mounted at `/data`.

## Layout

```
docker/               Dockerfile and conda environment
scripts/              prepare_data.sh, config.sh (study settings), and Python download helpers in lib/
docker-compose.yml    prep (data download) and jupyter services
.env.example          template for the data folder, credentials and download sources
```
