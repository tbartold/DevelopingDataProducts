library(shiny)

# need to display the questions in the sidebar
load('questions.rda')

# allow selection of different colors for the map
colors<-c("red", "darkorange1", "yellow2", "green3", "blue", "violet", "black")

# allow selection of different 'scales' to the maps
scale<-c("County", "State", "Nation")

shinyUI(
  pageWithSidebar(
    headerPanel("State & County QuickFacts"),
    sidebarPanel(
      helpText("Choose a Scale"),
      radioButtons('Scale', 'Which?', scale, selected=scale[2]),
      helpText("Choose a Fact"),
      selectInput('Fact', 'What?', questions, selected=questions[1]),
      helpText("Choose a Color"),
      radioButtons('Color', 'How?', colors, selected=colors[4]),
      helpText("The datasource for this app is the State & County QuickFacts website. The data can be found here: http://quickfacts.census.gov/qfd/download_data.html")
    ),
    mainPanel(
      h1("United States Census Bureau Map", align="center"),
      plotOutput('plotMap')
    )
  )
)
