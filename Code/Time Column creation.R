library(tidyverse)
df <- read.csv(file = 'data_cleaned.csv')
uniqueBar <- df[!duplicated(df$business_id),]
iid <- df$business_id
allR <- unique(iid)
time <- c()
modelDF <- uniqueBar[,c('business_id','name','is_open','stars_x')]

for (bar in allR){
  temp = df[df$business_id == bar,]
  temp = temp[order(format(as.POSIXct(temp$date_x,format='%Y-%m-%d %H:%M:%S'),format='%Y-%m-%d')),]
  first = format(as.POSIXct(temp$date_x[1],format='%Y-%m-%d %H:%M:%S'),format='%Y-%m-%d')
  last = format(as.POSIXct(tail(temp$date_x,n=1),format='%Y-%m-%d %H:%M:%S'),format='%Y-%m-%d')
  surv <- difftime(last,first,units="weeks")
  print(surv)
  if(is.na(surv) | (surv < 0)){
    surv = 0
  }
  time <- c(time,surv)
  print(bar)
}
big <- read.csv(file = 'final_grouped_business_id.csv')
modelDF <- cbind(modelDF,time)
modelDF <- merge(big,modelDF,by="business_id")

modelDF$is_open <- 1 - modelDF$is_open

modelDF$drink <- modelDF %>%
  pull(drink) %>%
  cut(breaks=c(-Inf,-.3,-.1,.05,.3,Inf),
      labels=c("1","2","3","4","5"))
modelDF$food <- modelDF %>%
  pull(food) %>%
  cut(breaks=c(-Inf,-.3,-.1,.05,.3,Inf),
      labels=c("1","2","3","4","5"))

modelDF$ambience <- modelDF %>%
  pull(ambience) %>%
  cut(breaks=c(-Inf,-.3,-.1,.05,.3,Inf),
      labels=c("1","2","3","4","5"))

modelDF$service <- modelDF %>%
  pull(service) %>%
  cut(breaks=c(-Inf,-.3,-.1,.05,.3,Inf),
      labels=c("1","2","3","4","5"))

modelDF$price <- modelDF %>%
  pull(price) %>%
  cut(breaks=c(-Inf,-.3,-.1,.05,.3,Inf),
      labels=c("1","2","3","4","5"))
write.csv(modelDF, "data_model_closed.csv", row.names=FALSE)

# BIGTEMP <- df[df$name == "Mizu Asian Bistro",]






df <- read.csv(file = 'data_cleaned_open.csv')
uniqueBar <- df[!duplicated(df$business_id),]
iid <- df$business_id
allR <- unique(iid)
time <- c()
modelDF <- uniqueBar[,c('business_id','name','is_open','stars_x')]

for (bar in allR){
  temp = df[df$business_id == bar,]
  temp = temp[order(format(as.POSIXct(temp$date_x,format='%Y-%m-%d %H:%M:%S'),format='%Y-%m-%d')),]
  first = format(as.POSIXct(temp$date_x[1],format='%Y-%m-%d %H:%M:%S'),format='%Y-%m-%d')
  last = format(as.POSIXct(tail(temp$date_x,n=1),format='%Y-%m-%d %H:%M:%S'),format='%Y-%m-%d')
  surv <- difftime("2022-12-7",first,units="weeks")
  print(surv)
  if(is.na(surv) | (surv < 0)){
    surv = 0
  }
  time <- c(time,surv)
  print(bar)
}
big <- read.csv(file = 'final__grouped_business_id_open.csv')
modelDF <- cbind(modelDF,time)
modelDF <- merge(big,modelDF,by="business_id")

modelDF$is_open <- 1 - modelDF$is_open

modelDF$drink <- modelDF %>%
  pull(drink) %>%
  cut(breaks=c(-Inf,-.1,.05,.15,.4,Inf),
      labels=c("1","2","3","4","5"))
modelDF$food <- modelDF %>%
  pull(food) %>%
  cut(breaks=c(-Inf,-.1,.05,.15,.4,Inf),
      labels=c("1","2","3","4","5"))

modelDF$ambience <- modelDF %>%
  pull(ambience) %>%
  cut(breaks=c(-Inf,-.1,.05,.15,.4,Inf),
      labels=c("1","2","3","4","5"))

modelDF$service <- modelDF %>%
  pull(service) %>%
  cut(breaks=c(-Inf,-.1,.05,.15,.4,Inf),
      labels=c("1","2","3","4","5"))

modelDF$price <- modelDF %>%
  pull(price) %>%
  cut(breaks=c(-Inf,-.1,.05,.15,.4,Inf),
      labels=c("1","2","3","4","5"))
write.csv(modelDF, "data_model_open.csv", row.names=FALSE)



