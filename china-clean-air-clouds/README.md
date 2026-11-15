# China's SO₂ cuts and downwind cloud darkening

Did China's SO₂ emission history leave a fingerprint on clouds over the NW Pacific? The design uses the full rise (1980–~2006) and two-step fall (~2006, 2013) of emissions against steady warming, so a cloud signal that reverses with emissions cannot come from climate change alone.

- Proposal (with expert feedback, bilingual): https://claude.ai/artifact/E6Q8dDAVfjaFwty1NUsCeS
- Background review: [`../literature/review.md`](../literature/review.md)

## Data

`scripts/prepare_data.sh` downloads everything below into `/data` inside the container (the host folder `DATA_DIR`). Total ≈ **0.4 TB**.

| Step | Dataset | Coverage | Size | Account |
| --- | --- | --- | --- | --- |
| `ceds` | CEDS v_2024_07_08 emissions by country and sector (Zenodo) | 1750–2022 | < 1 GB | none |
| `era5_monthly` | ERA5 monthly single and pressure levels (SST, stability, humidity, ω, winds) | 1980–2024, 10°S–60°N, 40–180°E | ~5 GB | CDS |
| `clara_a3` | CLARA-A3 AVHRR monthly cloud fraction and liquid-cloud properties incl. droplet number | 1979–present, global | ~10 GB | CDS |
| `merra2` | MERRA-2 monthly aerosol (M2TMNXAER) | 1980–2024, global | 34 GB | Earthdata |
| `modis_monthly` | MODIS L3 monthly (MYD08_M3, MOD08_M3) | 2000/2002–2024, global | 202 GB | Earthdata |
| `ceres_ebaf` | CERES EBAF Ed4.2.1 TOA radiation | 2000–present | 2 GB | Earthdata |
| `omi` | OMI daily NO₂ (OMNO2d) and SO₂ (OMSO2e) | 2004–2024, global | 108 GB | Earthdata |
| `modis_nd` | Gryspeerdt et al. (2022) MODIS droplet number, daily 1°, Aqua (CEDA) | 2002–2020, global | ~60 GB | none |

Sizes for CDS and CEDA steps are estimates; NASA sizes come from `--dry-run`.

## One-time account setup

1. **NASA Earthdata** — register at https://urs.earthdata.nasa.gov. Under *Applications → Authorized Apps*, approve **LAADS Web**, **NASA GESDISC DATA ARCHIVE** and **ASDC** (MODIS, MERRA-2/OMI and CERES respectively).
2. **Copernicus CDS** — register at https://cds.climate.copernicus.eu, copy the API token from your profile, and accept the licences on the *Download* tab of [ERA5 monthly single levels](https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels-monthly-means), [ERA5 monthly pressure levels](https://cds.climate.copernicus.eu/datasets/reanalysis-era5-pressure-levels-monthly-means) and [satellite cloud properties](https://cds.climate.copernicus.eu/datasets/satellite-cloud-properties).
3. Copy `.env.example` to `.env` and fill in `DATA_DIR`, the Earthdata login and the CDS token.

## Run on Windows (Docker Desktop)

Requires Docker Desktop with the WSL 2 backend. In PowerShell, from this folder:

```powershell
Copy-Item .env.example .env          # then edit .env, e.g. DATA_DIR=D:/climate-data/china
docker compose build
docker compose run --rm prep bash scripts/prepare_data.sh --dry-run
docker compose run --rm prep bash scripts/prepare_data.sh
```

Notes for Windows:
- Write `DATA_DIR` with forward slashes (`D:/climate-data/china`). In Docker Desktop, make sure that drive is shared (*Settings → Resources → File sharing*, if shown).
- Downloads to a Windows drive work but file access from the container is slower than inside WSL 2. For heavy analysis, a folder inside the WSL 2 filesystem (e.g. `\\wsl$\Ubuntu\home\<you>\data`) is faster.
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
bash scripts/prepare_data.sh --list                 # steps
bash scripts/prepare_data.sh era5_monthly clara_a3  # selected steps only
```

- Re-running is safe: finished NASA files (checked by size), CDS chunks (`.done` markers) and CEDA files (`wget -c`) are skipped. After a network failure, run the same command again.
- Study period, domain and thread count are set in `scripts/config.sh` and can be overridden in `.env` (`START_YEAR`, `END_YEAR`, `BBOX`, `CDS_AREA`, `THREADS`).
- `docker compose up jupyter` starts JupyterLab on http://localhost:8888 with the data mounted at `/data`.

## Layout

```
docker/               Dockerfile and conda environment
scripts/              prepare_data.sh, config.sh, and Python download helpers in lib/
docker-compose.yml    prep (data download) and jupyter services
.env.example          template for credentials and the data folder
```
