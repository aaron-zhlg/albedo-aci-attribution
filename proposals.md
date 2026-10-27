# Research Topic Proposals: What Drives the Recent Decline in Earth's Albedo?

Oct 26, 2026 · Live version: https://claude.ai/artifact/LDCcf5HEshrBTQBMxm42g7 · Background: [`literature/review.md`](literature/review.md)

Earth's energy imbalance has roughly doubled since the early 2000s, mostly because the planet absorbs more sunlight as low clouds reflect less. Whether the cloud loss comes from cleaner air (aerosol–cloud interactions, ACI), from a warming feedback, or from circulation changes is unresolved: published estimates of the aerosol term range from ~0 to ~0.33 W m⁻² per decade. The four topics below each attack this question from a different side; all use public satellite and reanalysis data and need no climate-model runs.

> 自 2000 年代初以来，地球能量失衡大约翻了一倍，主要原因是低云反射减弱、地球吸收了更多太阳光。云的减少究竟来自空气变干净（气溶胶–云相互作用，ACI）、变暖引起的反馈，还是环流变化，目前尚无定论：已发表的气溶胶贡献估计从约 0 到约 0.33 W m⁻²/十年不等。下面四个课题分别从不同角度切入这一问题，全部使用公开的卫星与再分析数据，不需要运行气候模式。

## Proposal 1 — Why do ACI estimates disagree?

- **Question:** Why do Park & Soden (2025), Ceppi et al. (2026) and Yuan et al. (2026) find aerosol contributions of ~0, ~0.05 and ~0.3 W m⁻² per decade?
- **Idea:** Re-derive the estimate on one dataset (CERES, MODIS, ERA5, MERRA-2) and change one methodological choice at a time: aerosol proxy (sulfate, AOD, droplet number), whether cloud adjustments are included, domain (global, oceans, each hemisphere) and period.
- **What is new:** The studies differ in several choices at once; a controlled comparison would show which choice drives the spread. It also tests Park & Soden's claim that Northern and Southern Hemisphere aerosol changes cancel.
- **Main risk:** Results may show that every choice matters a little, without a single clear driver.

> **课题 1 — 为什么各研究对 ACI 的估计不一致？**
>
> - **问题：** 为什么 Park & Soden (2025)、Ceppi 等 (2026) 和 Yuan 等 (2026) 得到的气溶胶贡献分别约为 0、0.05 和 0.3 W m⁻²/十年？
> - **思路：** 在同一套数据（CERES、MODIS、ERA5、MERRA-2）上重新估算，每次只改变一个方法选择：气溶胶指标（硫酸盐、AOD、云滴数）、是否计入云调整、区域（全球、海洋、南北半球）以及时间段。
> - **创新点：** 已有研究同时在多个选择上不同；受控比较可以找出是哪个选择造成了分歧，同时检验 Park & Soden 关于南北半球气溶胶变化相互抵消的观点。
> - **主要风险：** 结果可能显示每个选择都有一些影响，而没有单一的主导因素。

## Proposal 2 — A causal ACI estimate using NO₂ as an emission tracer

- **Question:** How much of the cloud-driven increase in absorbed sunlight is caused by anthropogenic aerosol, once meteorology is controlled?
- **Idea:** Aerosol decline and ocean warming happen in the same places at the same time, so regressions struggle to separate them. Satellite tropospheric NO₂ (OMI, from 2004) shares sources with SO₂, is set mainly by emissions, and was not changed by the 2020 shipping sulfur cap. Using it as an instrumental variable for anthropogenic changes in cloud-droplet number would isolate the emission-driven part of the cloud trend.
- **What is new:** Diamond & Boss (2025) used NO₂ this way for one shipping corridor; to our knowledge no study has applied it to the global or hemispheric trend.
- **Main risk:** NO₂ columns also respond to transport and chemistry, so the instrument's validity must be defended carefully.

> **课题 2 — 以 NO₂ 为排放示踪物的 ACI 因果估计**
>
> - **问题：** 在控制气象条件后，由云引起的太阳吸收增加中有多少是人为气溶胶造成的？
> - **思路：** 气溶胶下降与海洋变暖在同一时间、同一地点发生，回归方法难以将二者分开。卫星对流层 NO₂（OMI，2004 年起）与 SO₂ 同源，主要由排放决定，且不受 2020 年航运限硫令影响。以它作为人为云滴数变化的工具变量，可以分离出云趋势中由排放驱动的部分。
> - **创新点：** Diamond & Boss (2025) 曾在一条航运走廊中这样使用 NO₂；据我们所知，尚无研究将其用于全球或半球尺度的趋势归因。
> - **主要风险：** NO₂ 柱浓度也受传输和化学过程影响，工具变量的有效性需要仔细论证。

## Proposal 3 — China's clean-air policy as a natural experiment

- **Question:** Did the sharp drop in Chinese SO₂ emissions after 2013 measurably darken clouds downwind over the NW Pacific?
- **Idea:** Compare the East Asian outflow region with a similar control region before and after 2013 (difference-in-differences), and follow the whole chain step by step: aerosol → droplet number → droplet size → cloud water → cloud cover → albedo.
- **What is new:** Samset et al. (2025) estimated the global warming effect of this cleanup with models (~0.07 K); an observational, step-by-step test of the cloud response in the outflow region has not, to our knowledge, been done.
- **Main risk:** Low. The Pacific decadal variability around 2014–16 (the "blob") overlaps the policy change and must be controlled for.

> **课题 3 — 以中国清洁空气政策为自然实验**
>
> - **问题：** 2013 年后中国 SO₂ 排放大幅下降，是否使下风向西北太平洋的云可测量地变暗？
> - **思路：** 比较 2013 年前后东亚外流区与相似对照区的变化（双重差分），并逐环追踪整条链条：气溶胶 → 云滴数 → 云滴大小 → 云水 → 云量 → 反照率。
> - **创新点：** Samset 等 (2025) 用模式估计了这次减排的全球增温效应（约 0.07 K）；据我们所知，尚无研究在外流区用观测逐环检验云的响应。
> - **主要风险：** 较低。2014–16 年前后的太平洋年代际变率（“blob”）与政策变化时间重叠，必须加以控制。

## Proposal 4 — Which part of ACI matters: droplet size, cloud water or cloud cover?

- **Question:** Of the albedo change caused by fewer cloud droplets, how much comes from the Twomey effect (dimmer clouds at fixed water content) and how much from the clouds then losing water or shrinking?
- **Idea:** Use the 2003–2024 decline in MODIS droplet number together with the IMO 2020 shipping cut as two independent tests, and decompose the cloud-albedo trend into Twomey, liquid-water-path and cloud-fraction terms.
- **What is new:** The water and cover adjustments are the least constrained part of aerosol forcing and decide whether ACI is ~0.05 or ~0.3 W m⁻² per decade; current evidence on them comes mostly from ship tracks, not from the long-term trend.
- **Main risk:** Satellite retrievals of droplet number are biased and the Terra/Aqua orbits drift after ~2022, which can create spurious trends.

> **课题 4 — ACI 的哪一部分起主导作用：云滴大小、云水还是云量？**
>
> - **问题：** 云滴减少引起的反照率变化中，有多少来自 Twomey 效应（云水不变时云变暗），又有多少来自云随后失去水分或缩小？
> - **思路：** 以 2003–2024 年 MODIS 云滴数的下降和 IMO 2020 航运减排作为两个独立检验，将云反照率趋势分解为 Twomey、液水路径和云量三项。
> - **创新点：** 云水与云量调整是气溶胶强迫中约束最弱的部分，决定了 ACI 是约 0.05 还是约 0.3 W m⁻²/十年；目前的证据主要来自船迹，而非长期趋势。
> - **主要风险：** 卫星云滴数反演存在偏差，且 Terra/Aqua 轨道在约 2022 年后漂移，可能造成虚假趋势。

## Comparison

Proposal 2 is the most novel; Proposal 3 is the safest start, and its result feeds directly into 1, 2 and 4.

| Proposal | Novelty | Risk | Effort | Answers |
| --- | --- | --- | --- | --- |
| 1. Why estimates disagree | Medium | Medium | Medium | Which method choice drives the 0–0.33 spread |
| 2. Causal NO₂ tracer | High | Medium–high | Medium | The emission-driven ACI share of the trend |
| 3. China natural experiment | Medium | Low | Low | Whether a known emission cut darkened clouds downwind |
| 4. Twomey vs adjustments | High | Medium | High (TB-scale satellite data) | Which part of ACI sets its size |


> 课题 2 最具新意；课题 3 是最稳妥的起点，其结果可直接用于课题 1、2 和 4。
>
> | 课题 | 新意 | 风险 | 工作量 | 回答的问题 |
> | --- | --- | --- | --- | --- |
> | 1. 估计为何不一致 | 中 | 中 | 中 | 哪个方法选择造成了 0–0.33 的分歧 |
> | 2. NO₂ 因果示踪 | 高 | 中–高 | 中 | 排放驱动的 ACI 在趋势中占多少 |
> | 3. 中国自然实验 | 中 | 低 | 低 | 已知的减排是否使下风向的云变暗 |
> | 4. Twomey 与调整项 | 高 | 中 | 高（TB 级卫星数据） | ACI 的哪一部分决定其大小 |

## Key references

Full reference list: [`literature/review.md`](literature/review.md#references).
