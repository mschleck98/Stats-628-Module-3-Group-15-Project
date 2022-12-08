library(ggplot2)
library(survival)
library(survminer)
library(ranger)
library(ggplot2)
library(dplyr)
library(ggfortify)




dfClosed <- read.csv(file = 'data_model_closed.csv')
dfOpen <- read.csv(file = 'data_model_open.csv')

dfFull <- rbind(dfClosed,dfOpen)

dfFull$time[is.na(dfFull$time)] <- 0
dfFull <- dfFull[dfFull$time >0,]

# vet <- mutate(dfFull, SEN = ifelse((sentiment_score < 0), "LT3", "OV3"),
#               SEN = factor(SEN))
#dfFull$is_open <- 1 - dfFull$is_open
dfFull$food <- dfFull$food
# full.cox <- coxph(Surv(time, is_open) ~ SEN + food + drink + ambience + price + service, data = vet)
full.cox <- coxph(Surv(time, is_open) ~ drink + ambience + price + strata(service), data = dfFull)
summary(full.cox)


write.csv(dfFull, "full_model_cat.csv", row.names=FALSE)

autoplot(survfit(full.cox))


vet <- mutate(dfFull, AG = ifelse((stars_x < 3), "LT3", "OV3"),
              AG = factor(AG))
km_AG_fit <- survfit(Surv(time, is_open) ~ AG, data=vet)
autoplot(km_AG_fit)

temp <- survfit(full.cox)
temp
ggsurvplot(temp, color = "#2E9FDF",
           ggtheme = theme_minimal(),data = dfFull)


#Assumption Checking

full.ph <- cox.zph(full.cox)
full.ph

ggcoxzph(full.ph)


#Influential Observations
ggcoxdiagnostics(full.cox, type = "dfbeta",linear.predictions = FALSE, ggtheme = theme_bw())

#Linear relationship of log(predictors)

ggcoxfunctional(Surv(time, is_open) ~ log(food), data = dfFull)
ggcoxfunctional(Surv(time, is_open) ~ log(drink), data = dfFull)
ggcoxfunctional(Surv(time, is_open) ~ log(price), data = dfFull)
ggcoxfunctional(Surv(time, is_open) ~ log(service), data = dfFull)
ggcoxfunctional(Surv(time, is_open) ~ log(ambience), data = dfFull)





