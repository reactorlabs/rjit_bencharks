# This is the user-interface definition of a Shiny web application.

library(shiny)
library(datasets)

source("global.R", local=FALSE)

shinyUI(navbarPage("RJIT benchmarks",
    tabPanel("Compilation",
            sidebarPanel(
                 selectInput("ipackage", "Package:",
                             choices=names(benchmark_data), selectize = FALSE),
                 hr(),
                 selectInput("ifunction", "Function:",
                             choices=names(function_data), 
                             selectize = FALSE, 
                             selected="parse"),
                 hr()
            ),
            mainPanel(
                 plotOutput("packageTimes"),
                 plotOutput("functionTimes")
            )
    ),
    tabPanel("Execution"
        # dataTableOutput('mytable')
    )
)
)
