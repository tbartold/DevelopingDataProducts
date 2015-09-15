library(shiny)

# need to display the questions in the sidebar
load('questions.rda')

# allow selection of different colors for the map
colors<-c("red2","darkgreen","purple","gray10","blue")

shinyUI(pageWithSidebar(
  headerPanel("State & County QuickFacts"),
  sidebarPanel(
    helpText("Choose a Fact"),
    selectInput(
      'questions',
      'What:',
      questions,
      selected=questions[1]
      ),
    selectInput(
      'Colors',
      'Color',
      colors,
      selected=colors[1]
      )
  ),
  mainPanel(
    h1("United States Census Bureau Map",align="center"),
    plotOutput('plotMap')
  )
))
