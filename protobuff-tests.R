## ---- include = FALSE----------------------------------------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)


## protoc od.proto --python_out=.


## #!/usr/bin/python3

## 
## from google.protobuf.json_format import MessageToJson

## import csv

## import od_pb2

## import sys

## 
## # This is Python example code to work with the OD protobuf format.

## 
## # First let's read a CSV file and turn it into the protobuf.

## dataset = od_pb2.Dataset()

## with open('minimal-example-od-dataset.csv') as csv_file:

##     # We won't fill out the zones in this example, but we will populate od_trips.

## 
##     for row in csv.DictReader(csv_file):

##         # The total doesn't actually match the 'all' column?!

##         total = 0

##         for mode in ['bus', 'taxi', 'car_driver', 'car_passenger', 'bicycle', 'foot']:

##             total += int(row[mode])

##         if total != int(row['all']):

##             print('Summing the columns gives {}, but the all column says {}:'.format(

##                 total, row['all']))

##             print(row)

##             print('')

## 
##         # Let's add an OD entry for each of the modes here

##         for (col_name, mode_enum) in [

##                 ('train', od_pb2.Mode.RAIL_OTHER),

##                 ('bus', od_pb2.Mode.BUS),

##                 ('taxi', od_pb2.Mode.TAXI),

##                 ('car_driver', od_pb2.Mode.UNKNOWN_CAR_DRIVER),

##                 ('car_passenger', od_pb2.Mode.UNKNOWN_CAR_DRIVER),

##                 ('bicycle', od_pb2.Mode.PEDAL_CYCLE),

##                 ('foot', od_pb2.Mode.WALK),

##         ]:

##             od = dataset.od_trips.add()

##             od.origin_zone = row['geo_code1']

##             od.destination_zone = row['geo_code2']

##             od.mode = mode_enum

##             od.purpose = od_pb2.Purpose.COMMUTING_UNKNOWN

##             od.number_trips = int(row[col_name])

## 
## # We can print in a human-readable format:

## print(dataset)

## 
## # Or in JSON

## print(MessageToJson(dataset))

## 
## # Or in the compact binary format

## print(dataset.SerializeToString())

## 
## with open('output.pb', 'wb') as outfile:

##   outfile.write(dataset.SerializeToString())

## 
## 

## ------------------------------------------------------------------------------------------------------------
library(RProtoBuf)
library(dplyr) # for data manipulation
readProtoFiles(files = "od.proto")
# ls("RProtoBuf:DescriptorPool") # see descriptors
Dataset_new = new(Dataset)

od_df = read.csv("minimal-example-od-dataset.csv")
# Clean data - example ETL pipeline

names(OD)
names(Mode)
names(Purpose)
names(od_df)
od_clean = od_df %>% 
  transmute(
    origin_zone = geo_code1,
    destination_zone = geo_code2,
    UNKNOWN_CAR_DRIVER = car_driver, # currently ignoring car passengers
    UNKNOWN_CAR_PASSENGER = car_passenger, # currently ignoring car passengers
    PEDAL_CYCLE = bicycle,
    WALK = foot,
    RAIL_OTHER = train,
    BUS = bus,
    TAXI = taxi
  )

# Clean data, match names to schema
names(Mode)
names(od_df) 
(modes_in_data = names(Mode)[names(Mode) %in% names(od_clean)])

for(i in 1:nrow(od_df)) {
  for(j in names(Purpose)[1]) { # only one purpose in this dataset
    for(k in names(modes_in_data)) {
      od_new = new(
        OD,
        origin_zone = od_clean$origin_zone[i],
        destination_zone = od$destination_zone[i],
        mode = k,
        purpose = "Commute",
        number_trips = od[[k]][o]
      )
      Dataset_new$add("od_trips", od_new)
    }
  }
}



## ---- echo=FALSE, eval=FALSE---------------------------------------------------------------------------------
## # Protobuffer tests
## library(RProtoBuf)
## od = read.csv("https://github.com/atumworld/atumworld/releases/download/0/minimal-example-od-dataset.csv")
## od[1, ]
## u = "https://github.com/atumworld/atumworld/raw/main/od.proto"
## f = basename(u)
## download.file(url = u, destfile = f)
## readProtoFiles(files = "od.proto")
## odproto = new(OD)
## odproto
## (od_names = names(odproto))
## 
## od_new = new(
##   OD,
##   origin_zone = od$geo_code1[1],
##   destination_zone = od$geo_code2[1],
##   mode = "Walking",
##   purpose = 1,
##   number_trips = od$foot[1]
##   )
## 
## Dataset_new$add("od_trips", od_new)
## Dataset_new$od_trips[[1]]$origin_zone
## Dataset_new$od_trips[[2]]$origin_zone
## 
## (allowed_mode_values = names(Purpose))
## od_new = new(
##   OD,
##   origin_zone = od$geo_code1[1],
##   destination_zone = od$geo_code2[1],
##   # mode = 1,
##   mode = "Walking",
##   purpose = 1,
##   number_trips = od$foot[1]
##   )
## 
## od_new$add(od_new)
## od_new$add(
##   "origin_zone", od$geo_code2[1:3]
##   )
## 
## 
## 
## odproto$descriptor()
## 
## odproto
## odproto$od_trips
## odproto$descriptor()
## odproto$str()
## odproto$fileDescriptor()
## odproto$add()
## as.character(odproto$od_trips)
## 
## 
## serialize_pb(object = od, connection = "odbuf.pb")
## od2 = unserialize("odbuf.pb")
## 
## # tf = tempfile()
## # con = file(tf, open = "rb")
## # od_buf = serialize(od, connection = tf)
## #
## # # reading in the Python version
## # con = file('output.pb', open = "rb")
## # message = read(Dataset, con)
## # cat(as.character(message))
## # # how to get that into a data frame?

