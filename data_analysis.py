PROJECT : Impact of AI on Students
PURPOSE : Data Analysis - Correlation, T-Tests, Regression, and Data Modelling
DATA    : ai_student_impact_dataset_1.csv  (N = 50,000)
ALPHA   : 0.05 for all significance decisions

import pandas as pd
import numpy as np
from scipy import stats
import statsmodels.api as sm
import statsmodels.formula.api as smf
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score, classification_report

ALPHA = 0.05
DATA_PATH = "ai_student_impact_dataset_1.csv"   # << update path if needed

# 0. LOAD DATA & FEATURE ENGINEERING
df = pd.read_csv(DATA_PATH)
df["Paid_Subscription"] = df["Paid_Subscription"].astype(int)
df["GPA_Change"] = df["Post_Semester_GPA"] - df["Pre_Semester_GPA"]
df["High_Burnout"] = (df["Burnout_Risk_Level"] == "High").astype(int)

print(df.shape)
print(df.dtypes)

# 1. CORRELATION ANALYSIS
print("\n" + "=" * 70)
print("1. CORRELATION ANALYSIS (Pearson)")
print("=" * 70)

num_vars = [
    "Weekly_GenAI_Hours", "Traditional_Study_Hours", "Tool_Diversity",
    "Perceived_AI_Dependency", "Anxiety_Level_During_Exams",
    "Post_Semester_GPA", "GPA_Change", "Skill_Retention_Score",
]

corr_matrix = df[num_vars].corr(method="pearson")
print("\nFull correlation matrix:")
print(corr_matrix.round(3))

# Significance testing for the key relationships of interest
pairs_of_interest = [
    ("Weekly_GenAI_Hours", "GPA_Change"),
    ("Weekly_GenAI_Hours", "Skill_Retention_Score"),
    ("Weekly_GenAI_Hours", "Anxiety_Level_During_Exams"),
    ("Perceived_AI_Dependency", "Anxiety_Level_During_Exams"),
    ("Traditional_Study_Hours", "GPA_Change"),
    ("Tool_Diversity", "Skill_Retention_Score"),
]

print("\nKey pairwise correlations with significance (alpha = 0.05):")
for a, b in pairs_of_interest:
    r, p = stats.pearsonr(df[a], df[b])
    sig = "SIGNIFICANT" if p < ALPHA else "not significant"
    print(f"  {a} vs {b}: r = {r:.4f}, p = {p:.4g}  -> {sig}")

# 2. T-TESTS
print("\n" + "=" * 70)
print("2. INDEPENDENT SAMPLES T-TESTS")
print("=" * 70)

# 2a. GPA_Change: Paid subscription vs Free
paid = df.loc[df["Paid_Subscription"] == 1, "GPA_Change"]
free = df.loc[df["Paid_Subscription"] == 0, "GPA_Change"]
t1, p1 = stats.ttest_ind(paid, free, equal_var=False)  # Welch's t-test
print("\n2a. GPA_Change by Paid_Subscription (Welch's t-test)")
print(f"    Paid: n={len(paid)}, mean={paid.mean():.4f}, sd={paid.std():.4f}")
print(f"    Free: n={len(free)}, mean={free.mean():.4f}, sd={free.std():.4f}")
print(f"    t = {t1:.4f}, p = {p1:.4g} -> {'SIGNIFICANT' if p1 < ALPHA else 'not significant'}")

# 2b. Skill_Retention_Score: High vs Low AI usage (median split)
median_hours = df["Weekly_GenAI_Hours"].median()
high_usage = df.loc[df["Weekly_GenAI_Hours"] > median_hours, "Skill_Retention_Score"]
low_usage = df.loc[df["Weekly_GenAI_Hours"] <= median_hours, "Skill_Retention_Score"]
t2, p2 = stats.ttest_ind(high_usage, low_usage, equal_var=False)
print(f"\n2b. Skill_Retention_Score by AI usage (median split = {median_hours} hrs/week)")
print(f"    High usage: n={len(high_usage)}, mean={high_usage.mean():.4f}, sd={high_usage.std():.4f}")
print(f"    Low usage:  n={len(low_usage)}, mean={low_usage.mean():.4f}, sd={low_usage.std():.4f}")
print(f"    t = {t2:.4f}, p = {p2:.4g} -> {'SIGNIFICANT' if p2 < ALPHA else 'not significant'}")

# 3. MULTIPLE LINEAR REGRESSION - PREDICTING GPA CHANGE
print("\n" + "=" * 70)
print("3. MULTIPLE LINEAR REGRESSION: GPA_Change ~ AI usage + controls")
print("=" * 70)

ols_model = smf.ols(
    "GPA_Change ~ Weekly_GenAI_Hours + Traditional_Study_Hours + Tool_Diversity + "
    "Perceived_AI_Dependency + Anxiety_Level_During_Exams + Paid_Subscription + "
    "C(Prompt_Engineering_Skill) + C(Institutional_Policy)",
    data=df,
).fit()
print(ols_model.summary())

# 4. LOGISTIC REGRESSION - PREDICTING HIGH BURNOUT RISK
print("\n" + "=" * 70)
print("4. LOGISTIC REGRESSION: High_Burnout ~ AI usage + controls")
print("=" * 70)

logit_model = smf.logit(
    "High_Burnout ~ Weekly_GenAI_Hours + Traditional_Study_Hours + Perceived_AI_Dependency + "
    "Anxiety_Level_During_Exams + Tool_Diversity + Paid_Subscription + C(Institutional_Policy)",
    data=df,
).fit(disp=0)
print(logit_model.summary())

print("\nOdds ratios:")
odds_ratios = np.exp(logit_model.params)
print(odds_ratios.round(4))

# 5. DATA MODELLING - RANDOM FOREST CLASSIFIER FOR BURNOUT RISK (3-CLASS)
print("\n" + "=" * 70)
print("5. DATA MODELLING: Random Forest classifier for Burnout_Risk_Level")
print("=" * 70)

le_skill = LabelEncoder()
le_policy = LabelEncoder()
le_major = LabelEncoder()
df["Prompt_Skill_Enc"] = le_skill.fit_transform(df["Prompt_Engineering_Skill"])
df["Policy_Enc"] = le_policy.fit_transform(df["Institutional_Policy"])
df["Major_Enc"] = le_major.fit_transform(df["Major_Category"])

features = [
    "Weekly_GenAI_Hours", "Traditional_Study_Hours", "Tool_Diversity",
    "Perceived_AI_Dependency", "Anxiety_Level_During_Exams", "Paid_Subscription",
    "Prompt_Skill_Enc", "Policy_Enc", "Major_Enc",
]
X = df[features]
y = df["Burnout_Risk_Level"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.25, random_state=42, stratify=y
)

rf_model = RandomForestClassifier(
    n_estimators=300, max_depth=8, random_state=42, class_weight="balanced"
)
rf_model.fit(X_train, y_train)
y_pred = rf_model.predict(X_test)

print(f"\nTest set accuracy: {accuracy_score(y_test, y_pred):.4f}")
print("\nClassification report:")
print(classification_report(y_test, y_pred))

print("Feature importance (ranked):")
importance = pd.Series(rf_model.feature_importances_, index=features).sort_values(ascending=False)
print(importance.round(4))

# 6. SAVE RESULTS
df.to_csv("ai_student_impact_with_derived_vars.csv", index=False)
print("\nDone. Derived-variable dataset saved to ai_student_impact_with_derived_vars.csv")
