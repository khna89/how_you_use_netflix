library(shiny)
library(chron)
library(extrafont)
library(dplyr)
library(gvlma)

ui <- fluidPage(fluidRow(
    column(3,sliderInput(inputId="num",
                            label = "Choose the number of the shows included in the top",
                            value = 10, min = 1, max = 30), 
            fileInput(inputId = "file",
                      label = "Please upload your ViewingActivity.csv",
                      accept=".csv"),
           htmlOutput("total_hrs")),
    column(9, plotOutput("barpl"))),
    fluidRow(column(4, plotOutput("dur_per_year")),
             column(4, plotOutput("dur_per_time")),
             column(4, verbatimTextOutput("assumptions")))
                )

server <- function(input,output) {
    data <- reactive({
        #preprocessing data
        data <- read.csv(input$file$datapath)
        
        #transforming times and dates into appropriate formats
        data$Duration <- as.times(data$Duration)
        data$Start.Time <- as.Date(data$Start.Time)
        data$dur_in_min <- round(hours(data$Duration)*60+minutes(data$Duration) + 
                                     seconds(data$Duration)/60, 1)
        #loading fonts
        loadfonts(device = "postscript", quiet = TRUE)
        
        #filtering the titles
        data$general_title=NULL
        for (i in 1:length(data$Title)) {
            ind = regexpr("Seizoen",data$Title[i])
            if (ind<0) {
                ind=regexpr("Season",data$Title[i])
            }
            if (ind<0) {
                ind=regexpr("Miniserie",data$Title[i])
            }
            if (ind>0){
                sub=substr(data$Title[i],1,ind-3)
                data$general_title[i]=sub
            } else {
                data$general_title[i]=data$Title[i]
            }
        }
        data
    })
    mod <- reactive({
        data <- data()
        mod <- lm(dur_in_min~Start.Time,data)
    })
    output$total_hrs <- renderUI({
        data <- data()
        total_hrs_num <- round(sum(data$dur_in_min)/60)
        tags$div(p(tags$b("Total hours watched: ")),
                 p(style = "color:#4D4D4D; font-size:60px; 
                     text-align:center; font-family:Century Gothic", 
                   tags$b(total_hrs_num))
        )
    })
    output$barpl <- renderPlot({
        
        #aggregating data according to the titles
        data <- data()
        aggr_by_title = data %>%
            group_by(general_title) %>% 
            summarise(total_dur_in_min = sum(dur_in_min))
        aggr_by_title = aggr_by_title[order(-aggr_by_title$total_dur_in_min),]
        
        #plotting
        par(mar=c(15,4,4,1.5))
        bp = barplot(aggr_by_title$total_dur_in_min[1:input$num]/60,
                     names.arg=aggr_by_title$general_title[1:input$num],  
                     xlab="",
                     ylab="total hours",
                     ylim = c(0,160),
                     yaxt="n",
                     col="deepskyblue3", border = "deepskyblue3",
                     las=2,
                     main="What you watched",
                     fg="gray30",
                     cex.main=1.8,col.main="gray30",
                     cex.lab = 1.4, col.lab = "gray40", font.lab=2, 
                     cex.axis = 1.5, col.axis = "gray30",
                     family = "Century Gothic")
        bp
        text(bp, aggr_by_title$total_dur_in_min[1:input$num]/60+12,
             labels=as.character(round(aggr_by_title$total_dur_in_min[1:input$num]/60,1)),
             col = "gray30",
             family = "Century Gothic")
    })
    output$dur_per_year <- renderPlot({
        #aggregating data per years
        data <- data()
        data$years <- years(data$Start.Time)
        aggr_by_year = data %>%
            group_by(years) %>% 
            summarise(total_dur_in_min = sum(dur_in_min))
        aggr_by_year$years_as_f <- as.factor(aggr_by_year$years)
        
        #plotting
        barplot(aggr_by_year$total_dur_in_min/60,
                names.arg=aggr_by_year$years_as_f,  
                xlab="year",
                ylab="hours watched",
                col="deepskyblue3", border = "deepskyblue3",
                main="How much you watched per year",
                fg="gray30",
                cex.main=1.4,col.main="gray30",
                cex.lab = 1.2, col.lab = "gray40", font.lab=2, 
                cex.axis = 1.1, col.axis = "gray30",
                family="Century Gothic")
    })
    output$dur_per_time <- renderPlot({
        data <- data()
        mod <- mod()
        coefs <- mod$coefficients
        
        #plotting
        plot(data$Start.Time, data$dur_in_min, 
             xlab="year",ylab="minutes per view",
             pch=16, col="deepskyblue3",
             bty="l",fg="gray30",
             main="For how long you watched it every time",
             cex.main=1.4,col.main="gray30",
             cex.lab = 1.2, col.lab = "gray40", font.lab=2, 
             cex.axis = 1.1, col.axis = "gray30",
             family="Century Gothic")
        abline(coefs[1],coefs[2],col="sienna1",lwd=3)
    })
    output$assumptions <- renderPrint({
        mod <- mod()
        gvlma(mod)
    })
}
shinyApp(ui, server)