#!/usr/bin/env bash
# Download every input dataset for the ACI decomposition study (Twomey vs cloud water vs cover).
#
# Usage (inside the container):
#   bash scripts/prepare_data.sh --list            # show the steps
#   bash scripts/prepare_data.sh --dry-run         # report sizes and requests, download nothing
#   bash scripts/prepare_data.sh                   # run every step
#   bash scripts/prepare_data.sh era5_daily ceds   # run selected steps
#
# Every step can be re-run: finished files and requests are skipped.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/config.sh"

# Download addresses, dataset IDs and versions come from .env (docker compose passes it in).
SOURCE_VARS=(
  CEDS_URL CEDS_FILES MODIS_ND_URL MODIS_ND_PATTERN
  CDS_ERA5_MONTHLY_SINGLE CDS_ERA5_MONTHLY_PRESSURE CDS_ERA5_DAILY_SINGLE CDS_ERA5_DAILY_PRESSURE
  CDS_CLARA MERRA2_AER MERRA2_VERSION MODIS_AQUA_D3
  MODIS_AQUA_L2 MODIS_VERSION CERES_SSF_DAY CERES_SSF_VERSION
  CERES_EBAF CERES_EBAF_VERSION OMI_NO2 OMI_VERSION
)
missing=()
for v in "${SOURCE_VARS[@]}"; do [[ -n "${!v:-}" ]] || missing+=("$v"); done
if (( ${#missing[@]} )); then
  echo "Missing in .env: ${missing[*]}"
  echo "Copy the 'Download sources' block from .env.example into .env."
  exit 1
fi
LIB="$HERE/lib"

DRY=""
STEPS=(ceds era5_monthly era5_daily clara_a3 merra2 modis_daily modis_nd modis_l2_shipping ceres omi)

nasa() { python "$LIB/nasa_download.py" --threads "$THREADS" $DRY "$@"; }
cds() { python "$LIB/cds_download.py" $DRY "$@"; }

ERA5_SINGLE_VARS=sea_surface_temperature,skin_temperature,2m_temperature,2m_dewpoint_temperature,surface_pressure,10m_u_component_of_wind,10m_v_component_of_wind,total_column_water_vapour
ERA5_PRESSURE_VARS=temperature,relative_humidity,vertical_velocity,u_component_of_wind,v_component_of_wind

# CEDS country- and sector-level emissions, incl. international shipping, 1750-2022.
step_ceds() {
  local out="$DATA_ROOT/ceds"
  mkdir -p "$out"
  for f in $CEDS_FILES; do
    local url="$CEDS_URL/$f/content"
    if [[ -n "$DRY" ]]; then echo "[ceds] would download $f"; continue; fi
    if [[ -f "$out/${f%.zip}.done" ]]; then continue; fi
    curl -fL -C - -o "$out/$f" "$url" && unzip -oq "$out/$f" -d "$out/${f%.zip}" && touch "$out/${f%.zip}.done"
  done
}

# ERA5 monthly means of the cloud-controlling factors, 60S-60N.
step_era5_monthly() {
  cds --dataset "$CDS_ERA5_MONTHLY_SINGLE" \
    --set product_type=monthly_averaged_reanalysis --set variable=$ERA5_SINGLE_VARS \
    --set time=00:00 --set data_format=netcdf --set download_format=unarchived \
    --area="$CDS_AREA" --years "$START_YEAR-$END_YEAR" --split year \
    --out "$DATA_ROOT/era5/monthly_single" --prefix era5_single
  cds --dataset "$CDS_ERA5_MONTHLY_PRESSURE" \
    --set product_type=monthly_averaged_reanalysis --set variable=$ERA5_PRESSURE_VARS \
    --set pressure_level=500,700,850 \
    --set time=00:00 --set data_format=netcdf --set download_format=unarchived \
    --area="$CDS_AREA" --years "$START_YEAR-$END_YEAR" --split year \
    --out "$DATA_ROOT/era5/monthly_pressure" --prefix era5_pressure
}

# ERA5 daily means, 60S-60N: cloud adjustments act within days, so the core analysis is daily.
step_era5_daily() {
  cds --dataset "$CDS_ERA5_DAILY_SINGLE" \
    --set product_type=reanalysis --set variable=$ERA5_SINGLE_VARS \
    --set daily_statistic=daily_mean --set time_zone=utc+00:00 --set frequency=6_hourly \
    --area="$CDS_AREA" --years "$START_YEAR-$END_YEAR" --split month \
    --out "$DATA_ROOT/era5/daily_single" --prefix era5_daily_single
  cds --dataset "$CDS_ERA5_DAILY_PRESSURE" \
    --set product_type=reanalysis --set variable=$ERA5_PRESSURE_VARS \
    --set pressure_level=500,700,850 \
    --set daily_statistic=daily_mean --set time_zone=utc+00:00 --set frequency=6_hourly \
    --area="$CDS_AREA" --years "$START_YEAR-$END_YEAR" --split month \
    --out "$DATA_ROOT/era5/daily_pressure" --prefix era5_daily_pressure
}

# CLARA-A3 (AVHRR) monthly cloud fraction and liquid-cloud properties from 1980, for test C.
step_clara_a3() {
  local tcdr_end=$(( END_YEAR < 2020 ? END_YEAR : 2020 ))
  cds --dataset "$CDS_CLARA" \
    --set product_family=clara_a3 --set origin=eumetsat \
    --set variable=cloud_fraction,cloud_physical_properties_of_the_liquid_phase \
    --set climate_data_record_type=thematic_climate_data_record \
    --set time_aggregation=monthly_mean --day 01 \
    --years "$CLARA_START_YEAR-$tcdr_end" --split year \
    --out "$DATA_ROOT/clara_a3/monthly" --prefix clara_tcdr
  if (( END_YEAR >= 2021 )); then
    cds --dataset "$CDS_CLARA" \
      --set product_family=clara_a3 --set origin=eumetsat \
      --set variable=cloud_fraction,cloud_physical_properties_of_the_liquid_phase \
      --set climate_data_record_type=interim_climate_data_record \
      --set time_aggregation=monthly_mean --day 01 \
      --years "2021-$END_YEAR" --split year \
      --out "$DATA_ROOT/clara_a3/monthly" --prefix clara_icdr
  fi
}

# MERRA-2 monthly aerosol diagnostics (sulfate, AOD), global.
step_merra2() {
  nasa --short-name "$MERRA2_AER" --version "$MERRA2_VERSION" \
    --start "$START_YEAR-01-01" --end "$END_YEAR-12-31" --out "$DATA_ROOT/merra2/M2TMNXAER"
}

# MODIS Aqua level-3 daily cloud properties (liquid water path, cloud fraction, optical depth, re).
step_modis_daily() {
  nasa --short-name "$MODIS_AQUA_D3" --version "$MODIS_VERSION" \
    --start "$(( START_YEAR < 2002 ? 2002 : START_YEAR ))-07-04" --end "$END_YEAR-12-31" \
    --out "$DATA_ROOT/modis/MYD08_D3"
}

# Gryspeerdt et al. (2022) MODIS droplet number, daily 1 deg, Aqua files, 2002-2020 (CEDA, public).
step_modis_nd() {
  local base="$MODIS_ND_URL"
  local last=$(( END_YEAR < 2020 ? END_YEAR : 2020 ))
  for year in $(seq "$(( START_YEAR < 2002 ? 2002 : START_YEAR ))" "$last"); do
    if [[ -n "$DRY" ]]; then
      echo "[modis_nd] $year: $(curl -fs "$base/$year/" | grep -c '\.A\.v1\.nc"') Aqua files"
      continue
    fi
    wget -q -r -np -nH --cut-dirs=4 -c -e robots=off -A "$MODIS_ND_PATTERN" \
      -P "$DATA_ROOT/modis_nd" "$base/$year/"
  done
}

# MODIS Aqua level-2 cloud swaths over the shipping corridor around IMO 2020 (test B).
# Also the input for extending droplet number beyond 2020 in that region.
step_modis_l2_shipping() {
  nasa --short-name "$MODIS_AQUA_L2" --version "$MODIS_VERSION" --bbox="$SHIP_BBOX" \
    --start "$SHIP_START" --end "$SHIP_END" --out "$DATA_ROOT/modis/MYD06_L2_shipping"
}

# CERES daily 1-deg TOA fluxes and clouds (Aqua), plus EBAF monthly.
step_ceres() {
  nasa --short-name "$CERES_SSF_DAY" --version "$CERES_SSF_VERSION" \
    --start "$(( START_YEAR < 2002 ? 2002 : START_YEAR ))-07-01" --end "$END_YEAR-12-31" \
    --out "$DATA_ROOT/ceres/SSF1deg_Day_Aqua"
  nasa --short-name "$CERES_EBAF" --version "$CERES_EBAF_VERSION" \
    --start "2000-03-01" --end "$END_YEAR-12-31" --out "$DATA_ROOT/ceres/EBAF"
}

# OMI daily NO2 columns: shipping-lane and emission tracer.
step_omi() {
  nasa --short-name "$OMI_NO2" --version "$OMI_VERSION" \
    --start "2004-10-01" --end "$END_YEAR-12-31" --out "$DATA_ROOT/omi/OMNO2d"
}

list_steps() { printf '%s\n' "${STEPS[@]}"; }

selected=()
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY="--dry-run" ;;
    --list) list_steps; exit 0 ;;
    -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
    *) selected+=("$arg") ;;
  esac
done
(( ${#selected[@]} )) || selected=("${STEPS[@]}")

failed=()
for step in "${selected[@]}"; do
  if ! declare -F "step_$step" >/dev/null; then
    echo "Unknown step: $step (see --list)"; failed+=("$step"); continue
  fi
  echo "==> $step"
  "step_$step" || failed+=("$step")
done

if (( ${#failed[@]} )); then
  echo "Finished with failures: ${failed[*]} (re-run these steps to resume)"
  exit 1
fi
echo "All steps finished."
