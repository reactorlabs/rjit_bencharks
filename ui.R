# This is the user-interface definition of a Shiny web application.

library(shiny)
library(datasets)

source("global.R", local=FALSE)

shinyUI(navbarPage("RJIT benchmarks",
    tabPanel("Compilation",
            sidebarPanel(
                 selectInput("ipackage", "Package:",
                             choices=names(processed_data$compilation), selectize = FALSE),
                 hr(),
                 selectInput("ifunction", "Function:",
                             choices=function_names, 
                             selectize = FALSE, 
                             selected="parse"),
                 hr()
            ),
            mainPanel(
                 plotOutput("compilationPackageTimes"),
                 plotOutput("compilationFunctionTimes")
            )
    ),
    tabPanel("Execution",
             sidebarPanel(
                 selectInput("iexecution_date", "Date",
                             choices=names(processed_data$execution), selectize = FALSE),
                 hr()
             ),
             mainPanel(
                 plotOutput("executionSummary")
             )
    )
)
)
