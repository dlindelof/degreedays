
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(lattice)

make.signature <- function(baseline, signature, type, dd.baseline) {
  degrees <- runif(50, -5, 25)
  energy <- (baseline - degrees) * signature + rnorm(length(degrees), sd = 50)
  energy[energy < 0] <- 0
  dd <- 30 * (dd.baseline - degrees)
  dd[dd < 0] <- 0
  data.frame(Degrees = degrees,
             Control = type,
             Energy = energy)
}

make.df <- function(input) {
  df <- rbind(make.signature(input$baseline,
                             input$before.signature,
                             "BEFORE",
                             input$baseline),
              make.signature(input$baseline,
                             input$after.signature,
                             "AFTER",
                             input$baseline))
  df
}

savings <- function(before, after) (before - after) / before

colors.transp <- c(rgb(1,0,0,.2),
                   rgb(0,0,1,.2))
colors <- c(rgb(1,0,0),
            rgb(0,0,1))

shinyServer(function(input, output) {
  df <- reactive({ make.df(input) })
  df.with.dd <- reactive({ transform(df(),
                                     Day.Degrees = pmax(0,
                                                        30 * (input$dd.baseline - Degrees))) })
  output$signature.plot <- renderPlot({
    print(xyplot(Energy ~ Degrees,
                 df(),
                 groups = Control,
                 type = c("r", "p"),
                 par.settings = list(superpose.symbol = list(col = colors),
                                     superpose.line = list(col = colors)),
                 grid = TRUE,
                 ylab = "Monthly energy [kWh]",
                 xlab = "Mean monthly outdoor temperature [C]",
                 auto.key = list(columns = 2,
                                 title = "True energy performance")))
  })
  output$dd.plot <- renderPlot({
    print(histogram(~ Energy / Day.Degrees,
                    groups = Control,
                    df.with.dd(),
                    breaks = seq(0, 2000, by = 0.1),
                    xlim = c(0, 10),
                    par.settings = list(superpose.polygon = list(col = colors)),
                    panel = panel.superpose,
                    panel.groups = function(x, col, ...) {
                      panel.histogram(x, col, ...)
                    },
                    auto.key = list(columns = 2,
                                    title = "Energy performance\nfrom degree-days"),
                    col = colors,
                    xlab = "Energy demand per degree-day [kWh]"))
  })
  real.savings <- reactive({
    savings(input$before.signature, input$after.signature)
  })
  dd.savings <- reactive({
    means <- aggregate(Energy / Day.Degrees ~ Control,
                       df.with.dd(),
                       subset = Day.Degrees > 10,
                       FUN = mean)
    savings(means[1,2], means[2,2])
  })
  output$print.real.savings <- renderText(paste("Real savings:", format(100 * real.savings(), digits = 3), "%"))
  output$print.dd.savings <- renderText(paste("Degree-day savings:", format(100 * dd.savings(), digits = 3), "%"))
})
