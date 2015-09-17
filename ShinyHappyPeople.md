Shiny Happy People
========================================================
author: bartold
date: September 2015

Background
========================================================

- Who wants to be serious? This was a fun project for a fun class.

- This project uses Shiny, it made me happy, and it talks about people.

   - US Census Buearau [Statistics](http://quickfacts.census.gov/qfd/download_data.html)
   - Interactive in a Browser of your choice
   - Colorful and Fun to explore

Are Census Bureau Statistics Fun?
========================================================


```
'data.frame':	3195 obs. of  5 variables:
 $ fips     : int  0 1000 1001 1003 1005 1007 1009 1011 1013 1015 ...
 $ PST045214: int  318857056 4849377 55395 200111 26887 22506 57719 10764 20296 115916 ...
 $ PST040210: int  308758105 4780127 54571 182265 27457 22919 57322 10915 20946 118586 ...
 $ PST120214: num  3.3 1.4 1.5 9.8 -2.1 -1.8 0.7 -1.4 -3.1 -2.3 ...
 $ POP010210: int  308745538 4779736 54571 182265 27457 22915 57322 10914 20947 118572 ...
```

NO!

Introducing a Shiny alternative!
========================================================

![Image](ShinyHappyPeople.png)

The Shiny Happy People app is Fun!
========================================================

The Shiny app takes input from the user for:

- Which scale of map to show (County, State or Nation)
- What statistic to look at (all sorts of facts about people) 
- How the map should be colored (colors make me happy)

The app then selects the data about the chosen fact from the pre-loaded dataset, and displays the data on a map of the US using a color gradient to indicate the percentages recorded for the fact at the scale required.

Try the Shiny Happy People app today!
========================================================

Explore the interface, and have fun! 

Head on over to the [Shiny Happy People app] (http://bartold.shinyapps.io/DevelopingDataProducts/)

Don't forget to smile when you're exploring it. It will only take a short time, and it will make me happy that you played with it.

The complete code for this presentation is at [GitHub](http://github.com/tbartold/DevelopingDataProducts)
