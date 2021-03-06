
library ("RSQLite")
library ("ggmap")

#
# The dbConnect function is peculiar in that it creates an empty database for
# you if it does not find one at the specified location.  This function, in other 
# words, never throws an error.  If you don't specify a full path for the dbname 
# parameter, dbConnect appends the working directory path.  Use getwd() to query
# this value.  You can also display the contents of con to see the database file
# that dbConnect either opened or created.  
#
# If you run a SELECT statement against a newly created database, dbGetQuery throws 
# an error, indicating that the table or view does not exist.  When this happens, 
# take a look at the location of the database file in the con object.  Best practice
# here is to specify the full pathname to the database file in the dbname argument
# so you don't have to deal with the unintended consequences of new but empty 
# database.
#

# Connect to the database.
con <- dbConnect(drv = SQLite(), dbname = "c:/informatics/gnv_crime.db")

# Check the connection & validate with a query.
row_cnt <- dbGetQuery(con, 'select count(*) from crime')

# Run the query to retrieve hour from the crime_hour view.
df_hour <- dbGetQuery(con, 'select hour from crime_hour')

hist(as.numeric(df_hour$hour),
     col  = 'lightblue', 
     xlab = 'Hour (Military)', 
     main = 'Gainesville Crime',
     ylim = c(0, 20000), 
     xlim = c(0, 25)) 

# ------------------------------------------------------------------------------------
# For some reason, the hist() function combines the first two values of df_hour (0 & 1) 
# into the 0 bin, thereby increasing the frequency count of that bin.
#
# See the following stackoverflow question w/response to use barplot() instead:
# https://stackoverflow.com/questions/22428992/histogram-in-r-combining-first-two-values
# ------------------------------------------------------------------------------------

barplot(table(df_hour), col = 'lightblue', 
                       main = 'Gainesville Crime', 
                       xlab = 'Hour',
                       ylab = 'Frequency')

# ------------------------------------------------------------------------------------
# Get the bbox lat/long coordinates from http://bboxfinder.com. See http://maps.stamen.com 
# to view other options for get_stamenmap's maptype argument.
# ------------------------------------------------------------------------------------

# Set bbox coordinates for Gainesville and surrounding area.
bbox <- c(left = -82.495995, bottom = 29.591670, right = -82.252922, top = 29.717874)

map <- get_stamenmap(bbox, zoom = 14)

ggmap(map)

# Geocode Haile Plantation
gc <- data.frame('place' = 'Haile Plantation' , 'lon' = -82.439, 'lat' = 29.624)

# Render the map with a red dot on Haile Plantation.
ggmap(map) +
  geom_point(aes(x = lon, y = lat), data = gc, color = 'red', size = 1)

dbDisconnect(con)
