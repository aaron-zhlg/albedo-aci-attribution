# Settings for data preparation. Override any of these in .env.

DATA_ROOT="${DATA_ROOT:-/data}"
START_YEAR="${START_YEAR:-1980}"
END_YEAR="${END_YEAR:-2024}"
THREADS="${THREADS:-8}"

# Study domain: East Asia, the NW Pacific outflow, and India / Arabian Sea / Bay of Bengal
# (opposite-sign control). Earthdata uses W,S,E,N; the CDS uses N,W,S,E.
BBOX="${BBOX:-40,-10,180,60}"
CDS_AREA="${CDS_AREA:-60,40,-10,180}"

OMI_VERSION="${OMI_VERSION:-003}"
CEDS_RECORD="${CEDS_RECORD:-12803197}"   # Zenodo record of CEDS v_2024_07_08
