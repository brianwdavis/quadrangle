library(shiny)
if (!requireNamespace("quadrangle")) {
  devtools::install_github("brianwdavis/quadrangle")
}
library(quadrangle)
library(ggplot2)
library(magick)

ui <- fluidPage(
  titlePanel(tags$h1(tags$code("{quadrangle}") ," demo"), "{quadrangle} demo"),
  tags$h4(
    "An interactive walk-through of QR-code detection and reading within R. See ", 
    tags$a(
      "github.com/brianwdavis/quadrangle", 
      href = "https://github.com/brianwdavis/quadrangle"
    ),
    " for more details."
  ),
  sidebarLayout(
    sidebarPanel(
      fileInput(
        "file", 
        "Choose an image", 
        accept = c("image/jpeg", "image/png"),
        multiple = F)
    ),
    mainPanel(
      fluidRow(
        column(6, imageOutput("original"), tags$br()),
        column(6, plotOutput("annotated"), tags$br())
      ),
      fluidRow(
        column(6, tableOutput("values")),
        column(6, tableOutput("points"))
      )
    )
  )
)

server <- function(input, output, session) {
  options(shiny.maxRequestSize = 15*1024^2)
  
  prg <- eventReactive(input$file, {
    Progress$new(session, min = 0, max = 1)
  })
  
  mgk <- eventReactive(input$file, {
    prg()$set(message = "Reading image", value = 0.3)
    
    image_read(input$file$datapath[1])
  })
  
  output$original <- renderPlot({image_ggplot(mgk())})
  
  
  decoded_reactive <- reactive({
    prg()$set(
      value = 0.6, message = "Starting to decode",
      detail = "(there are more informative messages at the console)"
    )
    
    decoded_object <- qr_scan(mgk(), flop = F)
    
    prg()$set(value = 0.9, message = "Rendering",  detail = "")
    
    output$annotated <<- renderPlot({
      if (nrow(decoded_object$points) == 0) {
        image_ggplot(image_colorize(mgk(), 50, "red"))
      } else {
        qr_plot(mgk(), decoded_object)
      }
    })
    
    prg()$close()
    
    decoded_object
  })
  
  output$values <- renderTable(decoded_reactive()$values, digits = 0)
  output$points <- renderTable(decoded_reactive()$points, digits = 0)
}

shinyApp(ui, server)
