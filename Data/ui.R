#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(dplyr)
library(shinycssloaders)
library(rgdal)
library(plotly)
library(htmltools)
library(DT)
library(shinyjs)
library(shinyWidgets)
library(tidyverse)
library(zipcodeR)


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  setBackgroundColor(
    color = c("#F7FBFF", "#2171B5"),
    gradient = "radial",
    direction = c("top", "left")
  ),
  title = "Bar Closure",
  fluidRow(
    column(12,align="center",
           numericInputIcon(inputId = "zip",
                            label = "Enter Zip to Search for Reccomendations!",
                            min = 10000,
                            max = 99999,
                            value = 53703),
           actionButton("enter","Search!")
    ),
    # column(4,style = "background-color:#F7FBFF",
    #        #RECCOMENDATION GO HERE
    #        tableOutput('tableInfo')
    # ),
    # column(6,
    #        tableOutput('tableRec') 
    # )
  ),
   ## no tabs with statistics info, slow down the App way too much.
  leafletOutput("map"),
  column(5,style = "background-color:#F7FBFF",align="center",
         #RECCOMENDATION GO HERE
         tableOutput('tableInfo')
  ),
  column(7,align="center", style = "background-color:#E3EAFF",
         tableOutput('tableRec') 
  )
  # fluidRow(
  #   column(6,style = "background-color:#F7FBFF",
  #          #RECCOMENDATION GO HERE
  #          tableOutput('tableInfo')
  #   ),
  #   column(6,
  #          tableOutput('tableRec') 
  #   )
  # )
)
)
# column(4,style = "background-color:#F7FBFF",
#        #RECCOMENDATION GO HERE
#        tableOutput('tableInfo')
# ),
# column(6,
#        tableOutput('tableRec') 
# )

# Application title
#titlePanel("Old Faithful Geyser Data"),

# Sidebar with a slider input for number of bins
#sidebarLayout(
#    sidebarPanel(
#        sliderInput("bins",
#                    "Number of bins:",
#                    min = 1,
#                    max = 50,
#                    value = 30)
#    ),

# Show a plot of the generated distribution
#    mainPanel(
#        plotOutput("distPlot")
#    )
#)