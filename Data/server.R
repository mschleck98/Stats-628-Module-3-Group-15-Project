#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(tidyverse)
library(zipcodeR)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  lab <- c("Food", "*Drinks*", "Service", "*Price*", "*Atmosphere*")
  lval <- c(0,0,0,0,0)
  Reccomendations <- c("","","")
  loc <- reactiveValues(lat = 39.8283, lng = -98.5795)
  tableInfoData <- reactiveValues(d1 = as.data.frame(matrix(c(lab,lval),ncol=2)))
  tableRecData <- reactiveValues(d2 = as.data.frame(Reccomendations))
  cityMean <- read.csv(file = 'city_mean.csv')
  observeEvent(input$enter, {
    error <- FALSE
    tryCatch( { zipper <- geocode_zip(input$zip); error <<- FALSE }
              , error = function(e) {error <<- TRUE},
              warning = function(w) {error <<- TRUE})
    if(error){
      helpText("Please Enter Valid PA Zip")
    }
    else{
    zipper <- geocode_zip(input$zip)
    temp <- reverse_zipcode(input$zip)
    stateTemp <- temp$state
    cityTemp <- temp$major_city
    tempDf = tableInfoData$d1
    tempRec = tableRecData$d2
    lowscore = ""
    if (TRUE %in% (cityMean$city %in% cityTemp)){
       tempDf[1,2] <- trunc(cityMean$food[cityMean$city == cityTemp]*10^2)/10^2
       tempDf[2,2] <- trunc(cityMean$drink[cityMean$city == cityTemp]*10^2)/10^2
       tempDf[3,2] <- trunc(cityMean$service[cityMean$city == cityTemp]*10^2)/10^2
       tempDf[4,2] <- trunc(cityMean$price[cityMean$city == cityTemp]*10^2)/10^2
       tempDf[5,2] <- trunc(cityMean$ambience[cityMean$city == cityTemp]*10^2)/10^2
       if (tempDf[2,2] == min(tempDf[2,2],tempDf[4,2],tempDf[5,2])){
         tempRec[1,1] <- "Drinks are consistenly being rated overpriced, Drink deals and specials are an easy way to increase positive sentiment towards drinks, while also helping your price score!"
         tempRec[2,1] <- "Seasonal Menus are an easy way to increase variety of drinks and keep people coming back."
         tempRec[3,1] <- "Encouraging Bartenders to interact with customers on drink choices and reccomendations can improve sentiment for both service and drinks!"
       }
       if (tempDf[4,2] == min(tempDf[2,2],tempDf[4,2],tempDf[5,2])){
         tempRec[1,1] <- "Drinks are consistenly being rated overpriced, Drink deals and specials such as happy hour are an easy way to increase positive sentiment towards price, while also helping your drink score!"
         tempRec[2,1] <- "Creating combo meals, IE. deals that include both a drink and a snack, help customers feel they are getting the best value for their Dollar"
         tempRec[3,1] <- "If you are unable to offer discounts at all, try using higher quality cocktail additions, while not increasing the bottom line price of alcohol this can increase the quality of the product and increase your price score!"
       }
       if (tempDf[5,2] == min(tempDf[2,2],tempDf[4,2],tempDf[5,2])){
         tempRec[1,1] <- "Ambience is one of the most important factors where you are struggling, Happy hour is a industry standard addition you can begin to increase ambience, along with many of your other scores"
         tempRec[2,1] <- "Seasonal Menus are an easy way to increase variety of drinks and keep people coming back."
         tempRec[3,1] <- "Encouraging Bartenders to interact with customers not only about drinks, but also engage in conversation can increase ambience score"
       }
       names(tempDf)=c("** Represents Important Categories",paste(sep = "", "Average Score for Bars in: ",cityTemp,", ",stateTemp) )
    }
    else{
      tempDf[1,2] <- trunc(mean(cityMean$food*10^2))/10^2
      tempDf[2,2] <- trunc(mean(cityMean$drink*10^2))/10^2
      tempDf[3,2] <- trunc(mean(cityMean$service*10^2))/10^2
      tempDf[4,2] <- trunc(mean(cityMean$price*10^2))/10^2
      tempDf[5,2] <- trunc(mean(cityMean$ambience*10^2))/10^2
      if (tempDf[2,2] == min(tempDf[2,2],tempDf[4,2],tempDf[5,2])){
        tempRec[1,1] <- "Drinks are consistenly being rated overpriced, Drink deals and specials are an easy way to increase positive sentiment towards drinks, while also helping your price score!"
        tempRec[2,1] <- "Seasonal Menus are an easy way to increase variety of drinks and keep people coming back."
        tempRec[3,1] <- "Encouraging Bartenders to interact with customers on drink choices and reccomendations can improve sentiment for both service and drinks!"
      }
      if (tempDf[4,2] == min(tempDf[2,2],tempDf[4,2],tempDf[5,2])){
        tempRec[1,1] <- "Drinks are consistenly being rated overpriced, Drink deals and specials such as happy hour are an easy way to increase positive sentiment towards price, while also helping your drink score!"
        tempRec[2,1] <- "Creating combo meals, IE. deals that include both a drink and a snack, help customers feel they are getting the best value for their Dollar"
        tempRec[3,1] <- "If you are unable to offer discounts at all, try using higher quality cocktail additions, while not increasing the bottom line price of alcohol this can increase the quality of the product and increase your price score!"
      }
      if (tempDf[5,2] == min(tempDf[2,2],tempDf[4,2],tempDf[5,2])){
        tempRec[1,1] <- "Ambience is one of the most important factors where you are struggling, Happy hour is a industry standard addition you can begin to increase ambience, along with many of your other scores"
        tempRec[2,1] <- "Seasonal Menus are an easy way to increase variety of drinks and keep people coming back."
        tempRec[3,1] <- "Encouraging Bartenders to interact with customers not only about drinks, but also engage in conversation can increase ambience score"
      }
      names(tempDf)=c("** Represents Important Categories",paste(sep = "", "Average Score for Bars in: PA") )
    }
    tableInfoData$d1 = tempDf
    tableRecData$d2 = tempRec
    lb <- c("Drinks", "Price", "Atmosphere")
    big = -Inf
    # for (fun in lb){
    #   if (big < meanTemp$lb){
    #     big <- meanTemp$lb
    #   }
    # }
    
    loc$lng <- zipper$lng
    loc$lat <- zipper$lat
    leafletProxy("map") %>%
      setView(lng = loc$lng,
              lat = loc$lat,
              zoom = 11)
    # }
  }})
  
  
  output$tableInfo=renderTable({
    tableInfoData$d1
  })
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = isolate(loc$lng),
              lat = isolate(loc$lat),
              zoom = 3)
    
  })
  output$tableRec = renderTable({
    tableRecData$d2
  })
  
  # loc <- eventReactive(input$enter, {
  #   geocode_zip(input$zip)
  # })%>% debounce(1000)
  # 
  # output$map <- renderLeaflet({
  #   leaflet() %>%
  #     addTiles() %>%
  #     setView(lng = isolate(input$longitude),
  #             lat = isolate(input$latitude),
  #             zoom = 3)
  # })
  # 
  # 
  # # update Input with delay
  # map_long <- eventReactive(input$map_center$lng, {
  #   input$map_center$lng
  # })%>% debounce(1000)
  # map_lat <- eventReactive(input$map_center$lat, {
  #   input$map_center$lat
  # })%>% debounce(1000)
  # 
  # observe({
  #   updateNumericInputIcon(session = session,
  #                          inputId = "longitude",
  #                          value = round(map_long(), 1))
  #   updateNumericInputIcon(session = session,
  #                          inputId = "latitude",
  #                          value = round(map_lat(), 1))
  # })
  
  
  
})
