* PROJECT : Impact of AI on Students
* PURPOSE : Data summarization - descriptive statistics, frequency tables,
*           and contingency (cross-tab) tables
* DATA    : ai_student_impact_dataset_1.csv  (N = 50,000)
* AUTHOR  :
* DATE    : 11 July 2026

version 18
clear all
set more off
capture log close
cd "C:\Users\YourName\AI_Student_Impact"      
log using "data_summarization_log.log", replace text


* 1. IMPORT AND INSPECT DATA
import delimited "ai_student_impact_dataset_1.csv", clear varnames(1) case(preserve)

describe
codebook, compact

* Check for missing values across all variables
misstable summarize

* Encode string categoricals so they can be tabulated/coded numerically
encode major_category,           gen(major_cat)
encode year_of_study,            gen(year_study)
encode primary_use_case,         gen(use_case)
encode prompt_engineering_skill, gen(prompt_skill)
encode institutional_policy,     gen(inst_policy)
encode burnout_risk_level,       gen(burnout_risk)

* Order the ordinal categoricals sensibly for clean tables later
label define skill_ord 1 "Beginner" 2 "Intermediate" 3 "Advanced", replace
label define burnout_ord 1 "Low" 2 "Medium" 3 "High", replace

* 2. DESCRIPTIVE STATISTICS - NUMERIC VARIABLES
* Quick summary (matches the Excel "Descriptive Stats" sheet)
summarize pre_semester_gpa post_semester_gpa weekly_genai_hours ///
    traditional_study_hours tool_diversity perceived_ai_dependency ///
    anxiety_level_during_exams skill_retention_score

* Detailed summary with percentiles (mean, sd, min, p25, p50, p75, max)
summarize pre_semester_gpa post_semester_gpa weekly_genai_hours ///
    traditional_study_hours tool_diversity perceived_ai_dependency ///
    anxiety_level_during_exams skill_retention_score, detail

* Export a clean summary table to Word/Excel using -tabstat-
tabstat pre_semester_gpa post_semester_gpa weekly_genai_hours ///
    traditional_study_hours tool_diversity perceived_ai_dependency ///
    anxiety_level_during_exams skill_retention_score, ///
    statistics(n mean sd min p25 p50 p75 max) columns(statistics) ///
    save

* Create the GPA change variable used throughout the analysis
gen gpa_change = post_semester_gpa - pre_semester_gpa
label variable gpa_change "GPA Change (Post - Pre)"
summarize gpa_change, detail

* One-sample t-test: is the average GPA change significantly different from 0?
ttest gpa_change == 0

* 3. FREQUENCY TABLES - CATEGORICAL VARIABLES
tabulate major_category, missing
tabulate year_of_study, missing
tabulate primary_use_case, missing
tabulate prompt_engineering_skill, missing
tabulate paid_subscription, missing
tabulate institutional_policy, missing
tabulate burnout_risk_level, missing

* Frequencies with percentages and cumulative percentages saved to a table
foreach v of varlist major_category year_of_study primary_use_case ///
    prompt_engineering_skill paid_subscription institutional_policy ///
    burnout_risk_level {
    tabulate `v', missing sort
}

* 4. CONTINGENCY (CROSS-TAB) TABLES
* 4a. Burnout Risk Level x Institutional Policy
*     - row/column/cell percentages + chi-square test of independence
tabulate burnout_risk_level institutional_policy, chi2 row column cell ///
    expected

* Association strength (Cramer's V) for the above table
tabulate burnout_risk_level institutional_policy, chi2 V

* 4b. Burnout Risk Level x Major Category
tabulate burnout_risk_level major_category, chi2 row

* 4c. Prompt Engineering Skill x Primary Use Case
tabulate prompt_engineering_skill primary_use_case, chi2 row

* 5. GROUP SUMMARIES - GPA CHANGE BY MAJOR CATEGORY
* Mean pre-GPA, post-GPA, and GPA change by major (matches Excel cross-tab 2)
tabstat pre_semester_gpa post_semester_gpa gpa_change, ///
    by(major_category) statistics(n mean sd) columns(statistics)

* Test whether GPA change differs significantly across majors (alpha = 0.05)
oneway gpa_change major_cat, tabulate

* Post-hoc pairwise comparison (Bonferroni-adjusted) if the ANOVA is significant
oneway gpa_change major_cat, bonferroni

* 6. GROUP SUMMARIES - BURNOUT RISK BY AI USAGE INTENSITY
tabstat weekly_genai_hours perceived_ai_dependency anxiety_level_during_exams, ///
    by(burnout_risk_level) statistics(n mean sd) columns(statistics)

* ANOVA: does weekly GenAI usage differ significantly by burnout risk level?
oneway weekly_genai_hours burnout_risk, tabulate

* 7. CORRELATION MATRIX (preview ahead of the regression stage)
correlate pre_semester_gpa post_semester_gpa gpa_change weekly_genai_hours ///
    traditional_study_hours tool_diversity perceived_ai_dependency ///
    anxiety_level_during_exams skill_retention_score

pwcorr pre_semester_gpa post_semester_gpa gpa_change weekly_genai_hours ///
    traditional_study_hours tool_diversity perceived_ai_dependency ///
    anxiety_level_during_exams skill_retention_score, sig star(0.05)

* 8. SAVE CLEANED / PREPPED DATA FOR THE MODELLING STAGE (Python / R)
save "ai_student_impact_cleaned.dta", replace
export delimited using "ai_student_impact_cleaned.csv", replace

log close
* END OF DO-FILE
