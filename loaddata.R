### http://quickfacts.census.gov/qfd/download_data.html
################################################################################
# install and require packages
################################################################################
install <- function(x) {
  if (x %in% installed.packages()[,"Package"] == FALSE) {
    install.packages(x,dep=TRUE)
  }
  if(!require(x,character.only = TRUE)) stop("Package not found")
}

install('devtools')
install('stringr')
install('ggplot2')
install('shiny')
install('maps')
install('mapproj')
install('data.table')
install('shinyapps')


################################################################################
### this is to load the dictionary, parse, and use it later
################################################################################
url<-'http://quickfacts.census.gov/qfd/download/DataDict.txt'
all<-read.table(url,sep='|',header=FALSE,quote='\\')

# get the column names from the first row
colnames<-strsplit(as.character(as.vector(all[1,])),"\\s+")[[1]]

# get the data starting at the third row
d<-all[3:nrow(all),]

# make it a data.frame and give cols the same names as data
col<-length(colnames)
row<-nrow(all)-2
y<-data.frame(matrix(c(rep.int(NA,row*col)),nrow=row,ncol=col))
colnames(y)<-colnames

# first column
y[,1]<-sapply(d,function(x) substring(x,0,9))
# second column, etc.
y[,2]<-sapply(d,function(x) str_trim(substring(x,11,98)))
y[,3]<-sapply(d,function(x) str_trim(substring(x,99,101)))
y[,4]<-sapply(d,function(x) str_trim(substring(x,102,106)))
y[,5]<-sapply(d,function(x) str_trim(substring(x,107,119)))
y[,6]<-sapply(d,function(x) str_trim(substring(x,120,128)))
y[,7]<-sapply(d,function(x) str_trim(substring(x,129,138)))
y[,8]<-sapply(d,function(x) str_trim(substring(x,139,145)))
# convert some to numbers
y[,4]<-as.numeric(y[,4])
y[,5]<-as.numeric(y[,5])
y[,6]<-as.numeric(y[,6])
y[,7]<-as.numeric(y[,7])

# this will tell us which codes are measured as percentages
questioncodes<-y[y$Unit=="PCT",1]
questions<-y[y$Unit=="PCT",2]

################################################################################
# fips<-> county name
################################################################################
url<-'http://quickfacts.census.gov/qfd/download/FIPS_CountyName.txt'
z<-read.table(url,sep='|',header=FALSE,quote='\\')
z<-as.character(z[[1]])
# fix this name: 35013 Do\xb1a Ana County, NM
z[1836]<-"35013 Dona Ana County, NM"

# make it a data.frame and give cols the same names as the data it represents
colnames<-c("fips","county")
col<-length(colnames)
row<-length(z)
zz<-data.frame(matrix(c(rep.int(NA,row*col)),nrow=row,ncol=col))
colnames(zz)<-colnames

# first column
zz[,1]<-sapply(z,function(x) substring(x,0,5))
# second column, etc.
zz[,2]<-sapply(z,function(x) substring(x,7))

# note that fips codes include more than just counties
# this also gives us just the 'county'names
fips<-zz[,1]
countynames<-zz[,2]
nrow<-length(countynames)
counties<-character(nrow)
states<-character(nrow)
for (i in 1:nrow) {
  c<-countynames[i]
  x<-regexpr(",",c)[1]
  if (x>0) {
    # we have a county - we need to remove the word county
    abb<-substr(c,x+2,nchar(c))
    cou<-tolower(substr(c,0,x-1))
    if (grepl(" county$",cou,perl=TRUE)) {
      counties[i]<-gsub(" county","",cou)
    } else if (grepl(" parish$",cou,perl=TRUE)) {
      # but... louisiana counties are called 'Parish'
      counties[i]<-gsub(" parish","",cou)
    } else if (grepl(" city$",cou,perl=TRUE)) {
      counties[i]<-gsub(" city","",cou)
    } else if (grepl(" census area$",cou,perl=TRUE)) {
      counties[i]<-gsub(" census area","",cou)
    } else if (grepl(" municipality$",cou,perl=TRUE)) {
      counties[i]<-gsub(" municipality","",cou)
    } else if (grepl(" city and borough$",cou,perl=TRUE)) {
      counties[i]<-gsub(" city and borough","",cou)
    } else if (grepl(" borough$",cou,perl=TRUE)) {
      counties[i]<-gsub(" borough","",cou)
    }
    if (abb=="DC") {
        states[i]<-"district of columbia"
    } else {
        states[i]<-tolower(state.name[state.abb==abb])
    }
  } else {
    # we have a state
    states[i]<-tolower(c)
  }
}
# something went wrong?
counties[330]<-"district of columbia"

################################################################################
# for each county and question we should have a percentage
################################################################################
# create a new data.frame which crosses the two
# columns are the measures
col<-length(questioncodes)
# rows are the counties/ fips
row<-length(z)
results<-data.frame(matrix(c(rep.int(NA,row*col)),nrow=row,ncol=col))
colnames(results)<-questioncodes


################################################################################
### complete data
################################################################################
url<-'http://quickfacts.census.gov/qfd/download/DataSet.txt'
d<-read.table(url,sep=',',header=TRUE)
# fill in the matric from the big data set - selecting only the codes we want
results<-d[,questioncodes]

# save our tables
save(results,file="results.rda")
save(questions,file="questions.rda")
save(states,file="states.rda")
save(counties,file="counties.rda")
save(fips,file="fips.rda")
