#!/usr/bin/env bash
# Download every input dataset for the China clean-air / NW Pacific clouds study.
#
# Usage (inside the container):
#   bash scripts/prepare_data.sh --list            # show the steps
#   bash scripts/prepare_data.sh --dry-run         # report sizes and requests, download nothing
#   bash scripts/prepare_data.sh                   # run every step
#   bash scripts/prepare_data.sh era5_monthly ceds # run selected steps
#
# Every step can be re-run: finished files and requests are skipped.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/config.sh"
LIB="$HERE/lib"

DRY=""
STEPS=(ceds era5_monthly clara_a3 merra2 modis_monthly ceres_ebaf omi modis_nd)

nasa() { python "$LIB/nasa_download.py" --threads "$THREADS" $DRY "$@"; }
cds() { python "$LIB/cds_download.py" $DRY "$@"; }

# CEDS country- and sector-level SO2 / NOx emissions, 1750-2022.
step_ceds() {
  local out="$DATA_ROOT/ceds"
  mkdir -p "$out"
  for f in CEDS_v_2024_07_08_aggregate.zip CEDS_v_2024_07_08_detailed.zip; do
    local url="https://zenodo.org/api/records/$CEDS_RECORD/files/$f/content"
    if [[ -n "$DRY" ]]; then echo "[ceds] would download $f"; continue; fi
    if [[ -f "$out/${f%.zip}.done" ]]; then continue; fi
    curl -fL -C - -o "$out/$f" "$url" && unzip -oq "$out/$f" -d "$out/${f%.zip}" && touch "$out/${f%.zip}.done"
  done
}

# ERA5 monthly means: cloud-controlling factors (SST, stability, humidity, subsidence, winds).
step_era5_monthly() {
  cds --dataset reanalysis-era5-single-levels-monthly-means \
    --set product_type=monthly_averaged_reanalysis \
    --set variable=sea_surface_temperature,skin_temperature,2m_temperature,2m_dewpoint_temperature,surface_pressure,10m_u_component_of_wind,10m_v_component_of_wind,total_column_water_vapour \
    --set time=00:00 --set data_format=netcdf --set download_format=unarchived \
    --area="$CDS_AREA" --years "$START_YEAR-$END_YEAR" --split year \
    --out "$DATA_ROOT/era5/monthly_single" --prefix era5_single
  cds --dataset reanalysis-era5-pressure-levels-monthly-means \
    --set product_type=monthly_averaged_reanalysis \
    --set variable=temperature,relative_humidity,vertical_velocity,u_component_of_wind,v_component_of_wind \
    --set pressure_level=500,700,850 \
    --set time=00:00 --set data_format=netcdf --set download_format=unarchived \
    --area="$CDS_AREA" --years "$START_YEAR-$END_YEAR" --split year \
    --out "$DATA_ROOT/era5/monthly_pressure" --prefix era5_pressure
}

# CLARA-A3 (AVHRR) monthly cloud fraction and liquid-cloud properties incl. droplet number,
# from 1979. The thematic record ends in 2020; the interim record continues it.
step_clara_a3() {
  local tcdr_end=$(( END_YEAR < 2020 ? END_YEAR : 2020 ))
  cds --dataset satellite-cloud-properties \
    --set product_family=clara_a3 --set origin=eumetsat \
    --set variable=cloud_fraction,cloud_physical_properties_of_the_liquid_phase \
    --set climate_data_record_type=thematic_climate_data_record \
    --set time_aggregation=monthly_mean --day 01 \
    --years "$(( START_YEAR < 1979 ? 1979 : START_YEAR ))-$tcdr_end" --split year \
    --out "$DATA_ROOT/clara_a3/monthly" --prefix clara_tcdr
  if (( END_YEAR >= 2021 )); then
    cds --dataset satellite-cloud-properties \
      --set product_family=clara_a3 --set origin=eumetsat \
      --set variable=cloud_fraction,cloud_physical_properties_of_the_liquid_phase \
      --set climate_data_record_type=interim_climate_data_record \
      --set time_aggregation=monthly_mean --day 01 \
      --years "2021-$END_YEAR" --split year \
      --out "$DATA_ROOT/clara_a3/monthly" --prefix clara_icdr
  fi
}

# MERRA-2 monthly aerosol diagnostics (sulfate, AOD), global, from 1980.
step_merra2() {
  nasa --short-name M2TMNXAER --version 5.12.4 \
    --start "$START_YEAR-01-01" --end "$END_YEAR-12-31" --out "$DATA_ROOT/merra2/M2TMNXAER"
}

# MODIS level-3 monthly cloud and aerosol properties (Aqua from 2002, Terra from 2000).
step_modis_monthly() {
  nasa --short-name MYD08_M3 --version 6.1 \
    --start "2002-07-01" --end "$END_YEAR-12-31" --out "$DATA_ROOT/modis/MYD08_M3"
  nasa --short-name MOD08_M3 --version 6.1 \
    --start "2000-02-01" --end "$END_YEAR-12-31" --out "$DATA_ROOT/modis/MOD08_M3"
}

# CERES EBAF top-of-atmosphere radiation (single file, 2000 to present).
step_ceres_ebaf() {
  nasa --short-name CERES_EBAF --version Edition4.2.1 \
    --start "2000-03-01" --end "$END_YEAR-12-31" --out "$DATA_ROOT/ceres/EBAF"
}

# OMI daily NO2 and SO2 columns, from October 2004: the emission tracers.
step_omi() {
  nasa --short-name OMNO2d --version "$OMI_VERSION" \
    --start "2004-10-01" --end "$END_YEAR-12-31" --out "$DATA_ROOT/omi/OMNO2d"
  nasa --short-name OMSO2e --version "$OMI_VERSION" \
    --start "2004-10-01" --end "$END_YEAR-12-31" --out "$DATA_ROOT/omi/OMSO2e"
}

# Gryspeerdt et al. (2022) MODIS droplet number, daily 1 deg, Aqua files, 2002-2020 (CEDA, public).
step_modis_nd() {
  local base="https://dap.ceda.ac.uk/badc/deposited2022/modis_cdnc_sampling_gridded/data"
  local last=$(( END_YEAR < 2020 ? END_YEAR : 2020 ))
  for year in $(seq 2002 "$last"); do
    if [[ -n "$DRY" ]]; then
      echo "[modis_nd] $year: $(curl -fs "$base/$year/" | grep -c '\.A\.v1\.nc"') Aqua files"
      continue
    fi
    wget -q -r -np -nH --cut-dirs=4 -c -e robots=off -A "modis_nd.*.A.v1.nc" \
      -P "$DATA_ROOT/modis_nd" "$base/$year/"
  done
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
