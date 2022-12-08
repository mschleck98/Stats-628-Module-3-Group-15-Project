rm(list =ls())

#install.packages(c("survival", "survminer"))

library("survival")
library("survminer")

dfFull <- read.csv("full_model_cat.csv")
vet <- mutate(dfFull, SEN = ifelse((sentiment_score < 0), "LT3", "OV3"),
              SEN = factor(SEN))
#full.cox <- coxph(Surv(time, is_open) ~ SEN + food + drink + ambience + price + service, data = vet)

temp.cox <- coxph(Surv(time, is_open) ~ food + drink + ambience + price + strata(service), data = dfFull)
temp.cox

#Assumption Checking
full.ph <- cox.zph(temp.cox)
full.ph

# ggcoxzph(full.ph)[1]

ggcoxzph(full.ph)


#Influential Observations
ggcoxdiagnostics(full.cox, type = "dfbeta",
                 linear.predictions = FALSE, ggtheme = theme_bw())

#Linear relationship of log(predictors)

ggcoxfunctional(Surv(time, is_open) ~ food + log(food) + sqrt(food), data = dfFull)
ggcoxfunctional(Surv(time, is_open) ~ drink + log(drink) + sqrt(drink), data = dfFull)
ggcoxfunctional(Surv(time, is_open) ~ price + log(price) + sqrt(price), data = dfFull)
ggcoxfunctional(Surv(time, is_open) ~ service + log(service) + sqrt(service), data = dfFull)
ggcoxfunctional(Surv(time, is_open) ~ ambience + log(ambience) + sqrt(ambience), data = dfFull)



