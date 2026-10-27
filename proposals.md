# Research Topic Proposals: What Drives the Recent Decline in Earth's Albedo?

Oct 26, 2026 · Live version: https://claude.ai/artifact/LDCcf5HEshrBTQBMxm42g7 · Background: [`literature/review.md`](literature/review.md)

Earth's energy imbalance has roughly doubled since the early 2000s, mostly because the planet absorbs more sunlight as low clouds reflect less. Whether the cloud loss comes from cleaner air (aerosol–cloud interactions, ACI), from a warming feedback, or from circulation changes is unresolved: published estimates of the aerosol term range from ~0 to ~0.33 W m⁻² per decade. The four topics below each attack this question from a different side; all use public satellite and reanalysis data and need no climate-model runs.

## Proposal 1 — Why do ACI estimates disagree?

- **Question:** Why do Park & Soden (2025), Ceppi et al. (2026) and Yuan et al. (2026) find aerosol contributions of ~0, ~0.05 and ~0.3 W m⁻² per decade?
- **Idea:** Re-derive the estimate on one dataset (CERES, MODIS, ERA5, MERRA-2) and change one methodological choice at a time: aerosol proxy (sulfate, AOD, droplet number), whether cloud adjustments are included, domain (global, oceans, each hemisphere) and period.
- **What is new:** The studies differ in several choices at once; a controlled comparison would show which choice drives the spread. It also tests Park & Soden's claim that Northern and Southern Hemisphere aerosol changes cancel.
- **Main risk:** Results may show that every choice matters a little, without a single clear driver.

## Proposal 2 — A causal ACI estimate using NO₂ as an emission tracer

- **Question:** How much of the cloud-driven increase in absorbed sunlight is caused by anthropogenic aerosol, once meteorology is controlled?
- **Idea:** Aerosol decline and ocean warming happen in the same places at the same time, so regressions struggle to separate them. Satellite tropospheric NO₂ (OMI, from 2004) shares sources with SO₂, is set mainly by emissions, and was not changed by the 2020 shipping sulfur cap. Using it as an instrumental variable for anthropogenic changes in cloud-droplet number would isolate the emission-driven part of the cloud trend.
- **What is new:** Diamond & Boss (2025) used NO₂ this way for one shipping corridor; to our knowledge no study has applied it to the global or hemispheric trend.
- **Main risk:** NO₂ columns also respond to transport and chemistry, so the instrument's validity must be defended carefully.

## Proposal 3 — China's clean-air policy as a natural experiment

- **Question:** Did the sharp drop in Chinese SO₂ emissions after 2013 measurably darken clouds downwind over the NW Pacific?
- **Idea:** Compare the East Asian outflow region with a similar control region before and after 2013 (difference-in-differences), and follow the whole chain step by step: aerosol → droplet number → droplet size → cloud water → cloud cover → albedo.
- **What is new:** Samset et al. (2025) estimated the global warming effect of this cleanup with models (~0.07 K); an observational, step-by-step test of the cloud response in the outflow region has not, to our knowledge, been done.
- **Main risk:** Low. The Pacific decadal variability around 2014–16 (the "blob") overlaps the policy change and must be controlled for.

## Proposal 4 — Which part of ACI matters: droplet size, cloud water or cloud cover?

- **Question:** Of the albedo change caused by fewer cloud droplets, how much comes from the Twomey effect (dimmer clouds at fixed water content) and how much from the clouds then losing water or shrinking?
- **Idea:** Use the 2003–2024 decline in MODIS droplet number together with the IMO 2020 shipping cut as two independent tests, and decompose the cloud-albedo trend into Twomey, liquid-water-path and cloud-fraction terms.
- **What is new:** The water and cover adjustments are the least constrained part of aerosol forcing and decide whether ACI is ~0.05 or ~0.3 W m⁻² per decade; current evidence on them comes mostly from ship tracks, not from the long-term trend.
- **Main risk:** Satellite retrievals of droplet number are biased and the Terra/Aqua orbits drift after ~2022, which can create spurious trends.

## Comparison

Proposal 2 is the most novel; Proposal 3 is the safest start, and its result feeds directly into 1, 2 and 4.

| Proposal | Novelty | Risk | Effort | Answers |
| --- | --- | --- | --- | --- |
| 1. Why estimates disagree | Medium | Medium | Medium | Which method choice drives the 0–0.33 spread |
| 2. Causal NO₂ tracer | High | Medium–high | Medium | The emission-driven ACI share of the trend |
| 3. China natural experiment | Medium | Low | Low | Whether a known emission cut darkened clouds downwind |
| 4. Twomey vs adjustments | High | Medium | High (TB-scale satellite data) | Which part of ACI sets its size |

## Key references

Full reference list: [`literature/review.md`](literature/review.md#references).
