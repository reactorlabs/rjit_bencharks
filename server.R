# This is the server logic for a Shiny web application.

library(shiny)
library(ggplot2)

shinyServer(function(input, output, session) {
    output$compilationPackageTimes <- renderPlot({
        package <- input$ipackage
        pc <- processed_data$compilation[[package]]$total
        function_names <<- names(processed_data$compilation[[package]]$functions)
        updateSelectInput(session, "ifunction", choices = function_names)
        barplot(sapply(pc, function(x) as.numeric(x[[2]], units="secs")),
                ylab="time (seconds)",
                xlab="date (commit)",
                main=paste(package, "package compilation time"))
    })
    
    output$compilationFunctionTimes <- renderPlot({
        fname <- input$ifunction
        pname <- input$ipackage
        fc <- processed_data$compilation[[pname]][['functions']][[fname]]
        barplot(sapply(fc, function(x) as.numeric(x[[2]], units="secs") * 1000),
                ylab="time (microseconds)",
                xlab="date (commit)",
                main=paste(fname, "compilation times"))
    })
    
    output$executionSummary <- renderPlot({
        date <- input$iexecution_date
        graphlog(processed_data$execution[[date]], name=date)
    })
})
