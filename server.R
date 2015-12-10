# This is the server logic for a Shiny web application.

library(shiny)
library(ggplot2)

shinyServer(function(input, output, session) {
    output$packageTimes <- renderPlot({
        package <- input$ipackage
        pc <- process_package(package)
        function_data <<- benchmark_data[[package]][["functions"]]
        function_data <<- function_data[order(names(function_data))]
        # process package graph
        updateSelectInput(session, "ifunction", choices = names(function_data))
        barplot(sapply(pc, function(x) as.numeric(x[[2]], units="secs")),
                ylab="time (seconds)",
                xlab="date (commit)",
                main=paste(package, "package compilation time"))
    })
    
    output$functionTimes <- renderPlot({
        func <- input$ifunction
        fc <- process_function(func)
        barplot(sapply(fc, function(x) as.numeric(x[[2]], units="secs") * 1000),
                ylab="time (microseconds)",
                xlab="date (commit)",
                main=paste(func, "compilation times"))
    })
})
