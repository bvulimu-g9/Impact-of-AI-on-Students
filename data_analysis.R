# PROJECT : Impact of AI on Students
# PURPOSE : Data Analysis - Correlation, T-Tests, Regression, and Data Modelling
# DATA    : ai_student_impact_dataset_1.csv  (N = 50,000)
# ALPHA   : 0.05 for all significance decisions

# Install once if needed:
# install.packages(c("tidyverse","broom","car","randomForest","caret","pROC"))

library(tidyverse)
library(broom)        # tidy() model summaries
library(car)          # vif() - multicollinearity check
library(randomForest) # data modelling stage
library(caret)        # train/test split + confusion matrix

set.seed(42)
alpha <- 0.05

# 0. LOAD DATA & FEATURE ENGINEERING
df <- read_csv("C:\\Users\\Kevo De Hercules\\Desktop\\COMPLETE PROJECTS\\Impact of AI on Students\\ai_student_impact_dataset (1).CSV", show_col_types = FALSE)

df <- df %>%
  mutate(
    Paid_Subscription = as.integer(Paid_Subscription),
    GPA_Change         = Post_Semester_GPA - Pre_Semester_GPA,
    High_Burnout       = as.integer(Burnout_Risk_Level == "High"),
    Prompt_Engineering_Skill = factor(Prompt_Engineering_Skill,
                                       levels = c("Beginner","Intermediate","Advanced")),
    Institutional_Policy = factor(Institutional_Policy,
                                   levels = c("Allowed_With_Citation","Actively_Encouraged","Strict_Ban")),
    Burnout_Risk_Level = factor(Burnout_Risk_Level, levels = c("Low","Medium","High")),
    Major_Category      = factor(Major_Category)
  )

str(df)
summary(df)

# 1. CORRELATION ANALYSIS
cat("1. CORRELATION ANALYSIS (Pearson)\n")

num_vars <- c("Weekly_GenAI_Hours","Traditional_Study_Hours","Tool_Diversity",
              "Perceived_AI_Dependency","Anxiety_Level_During_Exams",
              "Post_Semester_GPA","GPA_Change","Skill_Retention_Score")

corr_matrix <- cor(df[num_vars], method = "pearson")
print(round(corr_matrix, 3))

key_pairs <- list(
  c("Weekly_GenAI_Hours","GPA_Change"),
  c("Weekly_GenAI_Hours","Skill_Retention_Score"),
  c("Weekly_GenAI_Hours","Anxiety_Level_During_Exams"),
  c("Perceived_AI_Dependency","Anxiety_Level_During_Exams"),
  c("Traditional_Study_Hours","GPA_Change"),
  c("Tool_Diversity","Skill_Retention_Score")
)

cat("\nKey pairwise correlations with significance (alpha = 0.05):\n")
for (pair in key_pairs) {
  test <- cor.test(df[[pair[1]]], df[[pair[2]]], method = "pearson")
  sig <- ifelse(test$p.value < alpha, "SIGNIFICANT", "not significant")
  cat(sprintf("  %s vs %s: r = %.4f, p = %.4g -> %s\n",
              pair[1], pair[2], test$estimate, test$p.value, sig))
}

# 2. T-TESTS
cat("\n=====================================================================\n")
cat("2. INDEPENDENT SAMPLES T-TESTS\n")
cat("=====================================================================\n")

# 2a. GPA_Change: Paid subscription vs Free (Welch by default in R)
t_test_1 <- t.test(GPA_Change ~ Paid_Subscription, data = df)
cat("\n2a. GPA_Change by Paid_Subscription (Welch's t-test)\n")
print(t_test_1)

# 2b. Skill_Retention_Score: High vs Low AI usage (median split)
median_hours <- median(df$Weekly_GenAI_Hours)
df <- df %>% mutate(Usage_Group = ifelse(Weekly_GenAI_Hours > median_hours, "High", "Low"))
t_test_2 <- t.test(Skill_Retention_Score ~ Usage_Group, data = df)
cat("\n2b. Skill_Retention_Score by AI usage (median split =", median_hours, "hrs/week)\n")
print(t_test_2)

# 3. MULTIPLE LINEAR REGRESSION - PREDICTING GPA CHANGE
cat("3. MULTIPLE LINEAR REGRESSION: GPA_Change ~ AI usage + controls\n")

ols_model <- lm(
  GPA_Change ~ Weekly_GenAI_Hours + Traditional_Study_Hours + Tool_Diversity +
    Perceived_AI_Dependency + Anxiety_Level_During_Exams + Paid_Subscription +
    Prompt_Engineering_Skill + Institutional_Policy,
  data = df
)
summary(ols_model)

# Multicollinearity check
cat("\nVariance Inflation Factors (VIF):\n")
print(vif(ols_model))

# Tidy coefficient table (easy to export to Excel/Word)
write_csv(tidy(ols_model), "ols_regression_results.csv")

# 4. LOGISTIC REGRESSION - PREDICTING HIGH BURNOUT RISK
cat("\n=====================================================================\n")
cat("4. LOGISTIC REGRESSION: High_Burnout ~ AI usage + controls\n")
cat("=====================================================================\n")

logit_model <- glm(
  High_Burnout ~ Weekly_GenAI_Hours + Traditional_Study_Hours + Perceived_AI_Dependency +
    Anxiety_Level_During_Exams + Tool_Diversity + Paid_Subscription + Institutional_Policy,
  data = df,
  family = binomial(link = "logit")
)
summary(logit_model)

cat("\nOdds ratios with 95% CI:\n")
print(exp(cbind(OR = coef(logit_model), confint(logit_model))))

# 5. DATA MODELLING - RANDOM FOREST CLASSIFIER FOR BURNOUT RISK (3-CLASS)
cat("\n=====================================================================\n")
cat("5. DATA MODELLING: Random Forest classifier for Burnout_Risk_Level\n")
cat("=====================================================================\n")

train_index <- createDataPartition(df$Burnout_Risk_Level, p = 0.75, list = FALSE)
train_data  <- df[train_index, ]
test_data   <- df[-train_index, ]

rf_model <- randomForest(
  Burnout_Risk_Level ~ Weekly_GenAI_Hours + Traditional_Study_Hours + Tool_Diversity +
    Perceived_AI_Dependency + Anxiety_Level_During_Exams + Paid_Subscription +
    Prompt_Engineering_Skill + Institutional_Policy + Major_Category,
  data = train_data,
  ntree = 300,
  maxnodes = 32,
  importance = TRUE
)

pred <- predict(rf_model, newdata = test_data)
conf_matrix <- confusionMatrix(pred, test_data$Burnout_Risk_Level)
print(conf_matrix)

cat("\nVariable importance (ranked):\n")
print(importance(rf_model)[order(-importance(rf_model)[, "MeanDecreaseGini"]), ])

# 6. SAVE RESULTS
write_csv(df, "ai_student_impact_with_derived_vars_R.csv")
cat("\nDone. Derived-variable dataset saved to ai_student_impact_with_derived_vars_R.csv\n")
