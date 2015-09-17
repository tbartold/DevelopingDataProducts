library(shiny)

require(ggplot2)
require(maps)
require(mapproj)
require(data.table)

load('results.rda')
load('questions.rda')
load('counties.rda')
load('states.rda')

# set the key we need to join the tables
map.state <- data.table(map_data('state'))
setkey(map.state,region)

# only need to do this once
map.county <- data.table(map_data('county'))
setkey(map.county,region,subregion)

shinyServer(
  function(input, output, session) {
    
    selectedMap=reactive({
      # need to match the question selected to the questions table to get the index
      qindex=match(input$Fact,questions,0)
    })
    
    observe({
      choice=input$questions
      qindex=match(input$Fact,questions)
    })
    
    output$plotMap=renderPlot({
      qindex=selectedMap()
      color=input$Color
      scale=input$Scale
      
      # select which plot we will show based on scale
      if (scale=='County') {
        
        # select the appropriate question for the data to plot
        plot_data <- data.frame(
          region=states, 
          subregion=counties, 
          percentage=results[[qindex]])
        
        # convert to data table with keys
        plot_data <- data.table(plot_data)
        setkey(plot_data,region,subregion)
        
        # join the two tables
        map.df<-map.county[plot_data]
        
        # here the grouping is by region+subregion in the data
        ggplot(map.df, aes(x=long, y=lat, group=group, fill=percentage)) + 
          geom_polygon() +
          coord_map('polyconic',xlim=c(-120,-73.5)) +
          theme(axis.text=element_blank(),
                axis.ticks=element_blank(),
                axis.title=element_blank(),
                panel.grid.major=element_blank(),
                panel.background=element_blank()) +
          scale_fill_continuous(low='white',high=color) +
          labs(title=questions[qindex])
        
      } else if (scale=='State') {
        
        # select only the states from our data set - and the question
        # note that the map data does not include alaska or hawaii
        plot_data<-data.frame(
          region=states[counties==''&states!='united states'&states!='alaska'&states!='hawaii'],
          percentage=results[[qindex]][counties==''&states!='united states'&states!='alaska'&states!='hawaii'])
        
        # convert to data table with a key
        plot_data <- data.table(plot_data)
        setkey(plot_data,region)
        
        # join the two tables
        map.df<-map.state[plot_data]
        
        # here the grouping is by the region key in the data
        ggplot(map.df, aes(x=long, y=lat, group=group, fill=percentage)) + 
          geom_polygon() +
          coord_map('polyconic',xlim=c(-120,-73.5)) +
          theme(axis.text=element_blank(),
                axis.ticks=element_blank(),
                axis.title=element_blank(),
                panel.grid.major=element_blank(),
                panel.background=element_blank()) +
          scale_fill_continuous(low='white',high=color) +
          labs(title=questions[qindex])
      } else {
        
        # use the states map but repeat the us value into each state (so we can see state boundaries)
        # need to round the percentage to an integer
        percentage<-round(results[[qindex]][states=='united states'])
        count<-length(states[counties==''&states!='united states'&states!='alaska'&states!='hawaii'])
        plot_data<-data.frame(
          region=states[counties==''&states!='united states'&states!='alaska'&states!='hawaii'],
          percentage=rep(percentage,count))
        
        # convert to data table with a key
        plot_data <- data.table(plot_data)
        setkey(plot_data,region)

        # we want the scale to reflect min and max for the states
        min<-min(results[[qindex]][counties==''])
        max<-max(results[[qindex]][counties==''])
 
        # join the two tables
        map.df<-map.state[plot_data]
               
        ggplot(map.df, aes(x=long, y=lat, group=group, fill=percentage)) + 
          geom_polygon() +
          coord_map('polyconic',xlim=c(-120,-73.5)) +
          theme(axis.text=element_blank(),
                axis.ticks=element_blank(),
                axis.title.y=element_blank(),
                panel.grid.major=element_blank(),
                panel.background=element_blank()) +
          scale_fill_continuous(low='white',high=color,limits=c(min, max)) +
          labs(title=questions[qindex], x=paste('nationwide average percentage =',percentage))
      }
    })
  }
)
