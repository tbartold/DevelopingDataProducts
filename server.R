library(shiny)

shinyServer(
  function(input, output, session) {
  require(ggplot2)
    load('results.rda')
    load('questions.rda')
    load('counties.rda')
    selectedMap=reactive({
      # need to match the question selected to the questions table to get the index
    question.ind=match(input$questions,questions,0)
      c(question.ind)
    })
    observe({
      choice=input$questions
      ind=match(input$questions,questions)
    })    
    output$plotMap=renderPlot({
      inds=selectedMap()
      color=input$Colors
      plotmap(inds[1],color)
    })
  }
)

plotmap<-function(quest=1,color="blue") {
  require(ggplot2)
  require(data.table)
  load('results.rda')
  load('counties.rda')
  load('states.rda')
  map.county <- map_data('county')
  plot_data <- data.frame(
    state_names=states, 
    county_names=counties, 
    percentage= results[[quest]])
  
  map.county <- data.table(map_data('county'))
  setkey(map.county,region,subregion)
  plot_data <- data.table(plot_data)
  setkey(plot_data,state_names,county_names)
  map.df <- map.county[plot_data]
  
  usmap<-ggplot(map.df, aes(x=long, y=lat, group=group, fill=percentage)) + 
    geom_polygon()+coord_map()+
    coord_map("polyconic",xlim=c(-120,-73.5))+
    theme(axis.text=element_blank(),
          axis.ticks=element_blank(),
          axis.title=element_blank(),
          panel.grid.major=element_blank(),
          panel.background=element_blank())+
    scale_fill_gradient(low='white', high=color)+
    labs(title=questions[quest])
  
  return(usmap)
}
