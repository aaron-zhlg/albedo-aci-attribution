# Settings for data preparation. Override any of these in .env.

DATA_ROOT="${DATA_ROOT:-/data}"
START_YEAR="${START_YEAR:-2002}"
END_YEAR="${END_YEAR:-2024}"
THREADS="${THREADS:-8}"

# Test A (global droplet decline): 60S-60N oceans. The CDS uses N,W,S,E.
CDS_AREA="${CDS_AREA:-60,-180,-60,180}"

# Test B (IMO 2020): pixel-level MODIS clouds over the SE Atlantic shipping corridor, W,S,E,N.
# Adjust to the corridor definition chosen for the analysis.
SHIP_BBOX="${SHIP_BBOX:--15,-25,15,0}"
SHIP_START="${SHIP_START:-2017-01-01}"
SHIP_END="${SHIP_END:-2023-12-31}"

# Test C (China's emission cuts) uses CLARA-A3 back to 1980.
CLARA_START_YEAR="${CLARA_START_YEAR:-1980}"

OMI_VERSION="${OMI_VERSION:-003}"
CEDS_RECORD="${CEDS_RECORD:-12803197}"   # Zenodo record of CEDS v_2024_07_08
