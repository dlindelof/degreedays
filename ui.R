
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("How to Lie with Degree Days"),
  
  # Sidebar with a slider input for number of bins
  sidebarPanel(
    strong("Use the controls below to choose different values for the building's true baseline temperature, its before and after energy performance, and the baseline temperature assumed by the degree-days method."),
    numericInput("baseline",
                 "Building true baseline [C]",
                 value = 21,
                 min = 10,
                 max = 30),
    sliderInput("before.signature",
                "Monthly energy consumption before intervention [kWh/C]",
                min = 30,
                max = 300,
                value = 150,
                step = 10),
    sliderInput("after.signature",
                "Monthly energy consumption after intervention [kWh/C]",
                min = 30,
                max = 300,
                value = 120,
                step = 10),
    numericInput("dd.baseline",
                 "Degree-days baseline [C]",
                 value = 18,
                 min = 10,
                 max = 30)
  ),
  
  mainPanel(
    strong("The plots below show the true energy performance of the building, and the energy performance as estimated with the degree-days method. At the end of the page we give the true and estimated energy savings."),
    plotOutput("signature.plot"),
    plotOutput("dd.plot"),
    h3(textOutput("print.real.savings")),
    h3(textOutput("print.dd.savings"))
  )
))
