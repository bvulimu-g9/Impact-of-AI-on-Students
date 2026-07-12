# AI Impact on Students — Analysis Project

A complete statistical and predictive analysis of how Generative AI usage relates to academic performance, skill retention, and student well-being, based on a dataset of 50,000 students.

## Headline Finding

> **AI usage intensity is a weak lever for academic grades but a strong lever for student well-being.** AI usage barely moves GPA (r ≈ −0.05), but it meaningfully and consistently predicts burnout risk (odds ratio = 1.12 per additional weekly hour) — confirmed across correlation, t-tests, logistic regression, and a Random Forest classifier.

---

## Dataset

| | |
|---|---|
| **File** | `ai_student_impact_dataset_1.csv` |
| **Records** | 50,000 students |
| **Variables** | 16 (academic profile, AI usage behaviour, study behaviour, institutional context, mental health & well-being) |
| **Missing values** | 0 |

See **Appendix A** of the final report for the full variable dictionary.

---

## Project Files

| File | Type | Description |
|---|---|---|
| `AI_Student_Impact_Report.pdf` | Report | **Start here.** 26-page comprehensive report: all hypotheses, statistical tests, regression/model outputs, every dashboard chart, and answers to all research questions. |
| `AI_Student_Impact_Analysis.pptx` | Slides | 12-slide summary presentation of the full analysis, suitable for presenting to stakeholders. |
| `AI_Student_Impact_Dashboards.html` | Dashboard | Interactive, self-contained dashboard (open in any browser). Three tabs: Academic Performance, Well-Being & Burnout, Usage Patterns & Segments. |
| `AI_Student_Impact_Summary.xlsx` | Spreadsheet | Raw data + descriptive stats, categorical frequencies, and cross-tabulations, all built with live Excel formulas. |
| `data_summarization.do` | Stata | Do-file for descriptive statistics, frequency tables, contingency tables, ANOVA, and correlation. |
| `ai_student_impact_cleaned.dta` | Stata data | Cleaned dataset with encoded categoricals and the derived `GPA_Change` variable, ready to load in Stata. |
| `data_analysis.py` | Python | Full script: correlation, t-tests, multiple linear regression, logistic regression, Random Forest classifier. Verified to run end-to-end. |
| `data_analysis.R` | R | Equivalent analysis in R (`cor.test`, `t.test`, `lm`, `glm`, `randomForest`). |

---

## Recommended Reading Order

1. **`AI_Student_Impact_Report.pdf`** — the full narrative: methodology, every hypothesis test with its H0/H1, all charts, and the answers to each research question.
2. **`AI_Student_Impact_Dashboards.html`** — explore the results interactively.
3. **`AI_Student_Impact_Analysis.pptx`** — condensed version for a presentation or meeting.
4. The **Excel / Stata / Python / R** files are the working analysis layer — open these if you want to verify a number, rerun a test, or extend the analysis.

---

## Analytical Workflow

```
Raw CSV (50,000 students)
        │
        ▼
Excel  ──────────────►  Data cleaning, pivot tables, descriptive stats, cross-tabs
        │
        ▼
Stata  ──────────────►  Data summarization, contingency tables, chi-square, ANOVA
        │
        ▼
Python + R  ──────────►  Correlation • T-Tests • Linear & Logistic Regression • Random Forest
        │
        ▼
Dashboards (HTML) ────►  3 interactive dashboards
        │
        ▼
PDF Report + PPTX  ───►  Final interpreted deliverables
```

All hypothesis tests use a significance threshold of **α = 0.05**.

---

## Key Results Summary

| Test | Result | Significant? |
|---|---|---|
| Weekly AI Hours ↔ GPA Change | r = −0.047 | Yes, but negligible effect |
| Weekly AI Hours ↔ Skill Retention | r = −0.118 | Yes, small effect |
| Weekly AI Hours ↔ Exam Anxiety | r = +0.269 | Yes, moderate effect |
| Traditional Study Hours ↔ GPA Change | r = +0.376 | Yes, strongest relationship found |
| GPA Change: Paid vs Free subscription (t-test) | t = 3.82, p < .001 | Yes, but practically negligible gap |
| Skill Retention: High vs Low AI usage (t-test) | t = −4.09, p < .001 | Yes, small effect |
| Burnout Risk × Institutional Policy (χ²) | χ² = 153.4, p < .001 | Yes, but weak association (Cramér's V = 0.04) |
| Linear Regression — GPA Change | R² = 0.167 | Model significant; study hours & prompt skill dominate |
| Logistic Regression — High Burnout | Pseudo R² = 0.20 | Model significant; AI hours & dependency dominate (OR 1.12, 1.13) |
| Random Forest — Burnout classifier | 49.2% accuracy (33% baseline) | Weekly AI Hours = 62% of feature importance |

Full detail, interpretation, and hypothesis statements for every row above are in the PDF report (Sections 5–10).

---

## Reproducing the Analysis

**Excel:** Open `AI_Student_Impact_Summary.xlsx` — all values are formulas referencing the Raw Data sheet, so they recalculate automatically if the underlying data changes.

**Stata:**
```stata
do "data_summarization.do"
```
Update the `cd` path at the top of the file to point to your working directory first.

**Python:**
```bash
pip install pandas numpy scipy statsmodels scikit-learn
python3 data_analysis.py
```

**R:**
```r
install.packages(c("tidyverse","broom","car","randomForest","caret"))
source("data_analysis.R")
```

**Dashboards:** Just open `AI_Student_Impact_Dashboards.html` in any modern browser — no server or install required (Chart.js is bundled directly into the file).

---

## Limitations

- All relationships are correlational; causal claims cannot be confirmed from this observational dataset alone.
- Self-reported measures (perceived dependency, anxiety, prompt skill) are subject to self-report bias.
- The Random Forest model's 49.2% accuracy indicates real but incomplete predictive signal — other unmeasured factors (sleep, workload, personal circumstances) likely also affect burnout risk.

---

## Recommendations

1. **Don't rely on outright AI bans** — Strict Ban policies correlate with both worse GPA outcomes and higher burnout risk.
2. **Invest in prompt-engineering training** — the skill gap has a bigger GPA effect than raw usage volume.
3. **Monitor usage intensity and self-reported dependency** as early-warning signals for burnout.
4. **Encourage tool diversity** over single-tool reliance to support skill retention.
5. **Keep investing in traditional study-skills support** — it remains the strongest predictor of GPA improvement.

---

*Report generated 11 July 2026. Dataset: `ai_student_impact_dataset_1.csv` (N = 50,000). All statistical tests use α = 0.05.*
