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

# we'll use these same criteria repeatedly
statecriteria<-counties==''&states!='united states'&states!='alaska'&states!='hawaii'
nationcriteria<-states=='united states'

shinyServer(
  function(input, output, session) {
    
    output$plotMap=renderPlot({
      # need to match the fact selected to the questions table to get the index
      qindex=match(input$Fact,questions)
      color=input$Color
      scale=input$Scale

      # this is used in the map legend
      percentage<-results[[qindex]][nationcriteria]

      # select which plot we will show based on scale
      if (scale=='County') {

        # select the appropriate question for the data to plot - we could exlude states here
        # here the grouping is by region+subregion in the data
        # convert to data table with keys
        county_plot_data <- data.table(
          region=states, 
          subregion=counties, 
          percentage=results[[qindex]])
        setkey(county_plot_data,region,subregion)
        
        # join the two tables
        map.df<-map.county[county_plot_data]
        
        # we want the scale to reflect min and max
        min<-min(results[[qindex]])
        max<-max(results[[qindex]])
        
      } else if (scale=='State') {
        
        # select only the states from our data set - and the question
        # note that the map data does not include alaska or hawaii
        # convert to data table with a key
        state_plot_data<-data.table(
          region=states[statecriteria],
          percentage=results[[qindex]][statecriteria])
        setkey(state_plot_data,region)

        # join the two tables
        map.df<-map.state[state_plot_data]
        
        # the min/max is really only needed for the nation map
        min<-min(results[[qindex]][statecriteria])
        max<-max(results[[qindex]][statecriteria])
        
      } else {

        # use the states map but repeat the us value into each state
        # (so we can see state boundaries)
        # convert to data table with a key
        nation_plot_data<-data.table(
          region=states[statecriteria],
          percentage=rep(percentage,length(states[statecriteria])))
        setkey(nation_plot_data,region)
        
        # join the two tables
        map.df<-map.state[nation_plot_data]
               
        # we want the scale to reflect min and max for the states
        min<-min(results[[qindex]][statecriteria])
        max<-max(results[[qindex]][statecriteria])
        
      }

      # plot the data frame we've derived
      ggplot(map.df, aes(x=long, y=lat, group=group, fill=percentage)) + 
        geom_polygon() +
        coord_map('polyconic',xlim=c(-120,-73.5)) +
        theme(axis.text=element_blank(),
              axis.ticks=element_blank(),
              axis.title.y=element_blank(),
              panel.grid.major=element_blank(),
              panel.background=element_blank()) +
        scale_fill_continuous(low='gray97',high=color,limits=c(min, max)) +
        labs(title=questions[qindex], x=paste('nationwide average percentage =',percentage))

    })
  }
)
