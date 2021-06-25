
<!-- README.md is generated from README.Rmd. Please edit that file -->

# atumWorld

## OD data protobuf example

All of this is a prototype/sketch.

First install the protonbuf compiler. On Ubuntu,
`sudo apt-get install protobuf-compiler`; on other platforms, see
<https://developers.google.com/protocol-buffers/docs/downloads>.

Then generate the Python library as follows:

``` bash
protoc od.proto --python_out=.
```

This creates `od_pb2.py`.

Then run the Python script: `./python_example.py`:

``` python
#!/usr/bin/python3

from google.protobuf.json_format import MessageToJson
import csv
import od_pb2
import sys

# This is Python example code to work with the OD protobuf format.

# First let's read a CSV file and turn it into the protobuf.
dataset = od_pb2.Dataset()
with open('minimal-example-od-dataset.csv') as csv_file:
    # We won't fill out the zones in this example, but we will populate od_trips.

    for row in csv.DictReader(csv_file):
        # The total doesn't actually match the 'all' column?!
        total = 0
        for mode in ['bus', 'taxi', 'car_driver', 'car_passenger', 'bicycle', 'foot']:
            total += int(row[mode])
        if total != int(row['all']):
            print('Summing the columns gives {}, but the all column says {}:'.format(
                total, row['all']))
            print(row)
            print('')

        # Let's add an OD entry for each of the modes here
        for (col_name, mode_enum) in [
                ('train', od_pb2.Mode.RAIL_OTHER),
                ('bus', od_pb2.Mode.BUS),
                ('taxi', od_pb2.Mode.TAXI),
                ('car_driver', od_pb2.Mode.UNKNOWN_CAR_DRIVER),
                ('car_passenger', od_pb2.Mode.UNKNOWN_CAR_DRIVER),
                ('bicycle', od_pb2.Mode.PEDAL_CYCLE),
                ('foot', od_pb2.Mode.WALK),
        ]:
            od = dataset.od_trips.add()
            od.origin_zone = row['geo_code1']
            od.destination_zone = row['geo_code2']
            od.mode = mode_enum
            od.purpose = od_pb2.Purpose.COMMUTE_UNKNOWN
            od.number_trips = int(row[col_name])

# We can print in a human-readable format:
#> Summing the columns gives 946, but the all column says 966:
#> OrderedDict([('geo_code1', 'E02002384'), ('geo_code2', 'E02006875'), ('all', '966'), ('train', '14'), ('bus', '153'), ('taxi', '14'), ('car_driver', '69'), ('car_passenger', '18'), ('bicycle', '13'), ('foot', '679')])
print(dataset)

# Or in JSON
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: RAIL_OTHER
#>   purpose: COMMUTE_UNKNOWN
#>   number_trips: 14
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: BUS
#>   purpose: COMMUTE_UNKNOWN
#>   number_trips: 153
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: TAXI
#>   purpose: COMMUTE_UNKNOWN
#>   number_trips: 14
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: UNKNOWN_CAR_DRIVER
#>   purpose: COMMUTE_UNKNOWN
#>   number_trips: 69
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: UNKNOWN_CAR_DRIVER
#>   purpose: COMMUTE_UNKNOWN
#>   number_trips: 18
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: PEDAL_CYCLE
#>   purpose: COMMUTE_UNKNOWN
#>   number_trips: 13
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: WALK
#>   purpose: COMMUTE_UNKNOWN
#>   number_trips: 679
#> }
print(MessageToJson(dataset))

# Or in the compact binary format
#> {
#>   "odTrips": [
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "RAIL_OTHER",
#>       "purpose": "COMMUTE_UNKNOWN",
#>       "numberTrips": 14
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "BUS",
#>       "purpose": "COMMUTE_UNKNOWN",
#>       "numberTrips": 153
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "TAXI",
#>       "purpose": "COMMUTE_UNKNOWN",
#>       "numberTrips": 14
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "UNKNOWN_CAR_DRIVER",
#>       "purpose": "COMMUTE_UNKNOWN",
#>       "numberTrips": 69
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "UNKNOWN_CAR_DRIVER",
#>       "purpose": "COMMUTE_UNKNOWN",
#>       "numberTrips": 18
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "PEDAL_CYCLE",
#>       "purpose": "COMMUTE_UNKNOWN",
#>       "numberTrips": 13
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "WALK",
#>       "purpose": "COMMUTE_UNKNOWN",
#>       "numberTrips": 679
#>     }
#>   ]
#> }
print(dataset.SerializeToString())
#> b'\x12\x1d\n\tE02002384\x12\tE02006875\x18\xb3\x02 e(\x0e\x12\x1e\n\tE02002384\x12\tE02006875\x18\xb0\x02 e(\x99\x01\x12\x1d\n\tE02002384\x12\tE02006875\x18\x93\x03 e(\x0e\x12\x1d\n\tE02002384\x12\tE02006875\x18\x91\x03 e(E\x12\x1d\n\tE02002384\x12\tE02006875\x18\x91\x03 e(\x12\x12\x1c\n\tE02002384\x12\tE02006875\x18h e(\r\x12\x1d\n\tE02002384\x12\tE02006875\x18e e(\xa7\x05'
with open('output.pb', 'wb') as outfile:
  outfile.write(dataset.SerializeToString())

#> 217
```

## In R

``` r
library(RProtoBuf)
library(dplyr) # for data manipulation
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
readProtoFiles(files = "od.proto")
# ls("RProtoBuf:DescriptorPool") # see descriptors
Dataset_new = new(Dataset)

od_df = read.csv("minimal-example-od-dataset.csv")
# Clean data - example ETL pipeline

names(OD)
#> [1] "origin_zone"      "destination_zone" "mode"             "purpose"         
#> [5] "number_trips"
names(Mode)
#>  [1] "UNKNOWN_MODE"                  "WALK"                         
#>  [3] "JOG"                           "PUSH_SCOOTER"                 
#>  [5] "PEDAL_CYCLE"                   "PEDAL_CYCLE_PASSENGER"        
#>  [7] "ELECTRIC_CYCLE"                "ELECTRIC_CYCLE_PASSENGER"     
#>  [9] "MICROMOBILITY_OTHER"           "ELECTRIC_SCOOTER"             
#> [11] "MOBILITY_SCOOTER"              "MOTORCYCLE"                   
#> [13] "MOTORCYCLE_PASSENGER"          "PUBLIC_TRANSPORT_OTHER"       
#> [15] "AUTO_RICKSHAW"                 "MINIBUS"                      
#> [17] "BUS"                           "LIGHT_RAIL"                   
#> [19] "SUBWAY"                        "RAIL_OTHER"                   
#> [21] "UNKNOWN_CAR_DRIVER"            "UNKNOWN_CAR_PASSENGER"        
#> [23] "TAXI"                          "CARPOOL"                      
#> [25] "MICRO_CAR_DRIVER"              "MICRO_CAR_PASSENGER"          
#> [27] "SMALL_CAR_DRIVER"              "SMALL_CAR_PASSENGER"          
#> [29] "MEDIUM_CAR_DRIVER"             "MEDIUM_CAR_PASSENGER"         
#> [31] "LARGE_CAR_DRIVER"              "LARGE_CAR_PASSENGER"          
#> [33] "VAN_DRIVER"                    "VAN_PASSENGER"                
#> [35] "TRUCK_DRIVER"                  "TRUCK_PASSENGER"              
#> [37] "HEAVY_GOODS_VEHICLE_DRIVER"    "HEAVY_GOODS_VEHICLE_PASSENGER"
#> [39] "HORSE"                         "HORSE_DRAWN_CARRIAGE"
names(Purpose)
#>  [1] "UNKNOWN_PURPOSE"           "COMMUTE_UNKNOWN"          
#>  [3] "COMMUTE_OUTBOUND"          "COMMUTE_INBOUND"          
#>  [5] "COMMUTE_OTHER"             "EDUCATION_UNKNOWN"        
#>  [7] "EDUCATION_OUTBOUND"        "EDUCATION_INBOUND"        
#>  [9] "EDUCATION_OTHER"           "EDUCATION_ESCORT_UNKNOWN" 
#> [11] "EDUCATION_ESCORT_OUTBOUND" "EDUCATION_ESCORT_INBOUND" 
#> [13] "EDUCATION_ESCORT_OTHER"    "SHOPPING_UNKNOWN"         
#> [15] "SHOPPING_OUTBOUND"         "SHOPPING_INBOUND"         
#> [17] "SHOPPING_OTHER"            "SOCIAL_UNKNOWN"           
#> [19] "SOCIAL_OUTBOUND"           "SOCIAL_INBOUND"           
#> [21] "SOCIAL_OTHER"              "LEISURE_UNKNOWN"          
#> [23] "LEISURE_OUTBOUND"          "LEISURE_INBOUND"          
#> [25] "LEISURE_OTHER"             "HOLIDAY_UNKNOWN"          
#> [27] "HOLIDAY_OUTBOUND"          "HOLIDAY_INBOUND"          
#> [29] "HOLIDAY_OTHER"             "BUSINESS_UNKNOWN"         
#> [31] "BUSINESS_OUTBOUND"         "BUSINESS_INBOUND"         
#> [33] "BUSINESS_OTHER"            "OTHER_UNKNOWN"            
#> [35] "OTHER_OUTBOUND"            "OTHER_INBOUND"            
#> [37] "OTHER_OTHER"
names(od_df)
#>  [1] "geo_code1"     "geo_code2"     "all"           "train"        
#>  [5] "bus"           "taxi"          "car_driver"    "car_passenger"
#>  [9] "bicycle"       "foot"
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
#>  [1] "UNKNOWN_MODE"                  "WALK"                         
#>  [3] "JOG"                           "PUSH_SCOOTER"                 
#>  [5] "PEDAL_CYCLE"                   "PEDAL_CYCLE_PASSENGER"        
#>  [7] "ELECTRIC_CYCLE"                "ELECTRIC_CYCLE_PASSENGER"     
#>  [9] "MICROMOBILITY_OTHER"           "ELECTRIC_SCOOTER"             
#> [11] "MOBILITY_SCOOTER"              "MOTORCYCLE"                   
#> [13] "MOTORCYCLE_PASSENGER"          "PUBLIC_TRANSPORT_OTHER"       
#> [15] "AUTO_RICKSHAW"                 "MINIBUS"                      
#> [17] "BUS"                           "LIGHT_RAIL"                   
#> [19] "SUBWAY"                        "RAIL_OTHER"                   
#> [21] "UNKNOWN_CAR_DRIVER"            "UNKNOWN_CAR_PASSENGER"        
#> [23] "TAXI"                          "CARPOOL"                      
#> [25] "MICRO_CAR_DRIVER"              "MICRO_CAR_PASSENGER"          
#> [27] "SMALL_CAR_DRIVER"              "SMALL_CAR_PASSENGER"          
#> [29] "MEDIUM_CAR_DRIVER"             "MEDIUM_CAR_PASSENGER"         
#> [31] "LARGE_CAR_DRIVER"              "LARGE_CAR_PASSENGER"          
#> [33] "VAN_DRIVER"                    "VAN_PASSENGER"                
#> [35] "TRUCK_DRIVER"                  "TRUCK_PASSENGER"              
#> [37] "HEAVY_GOODS_VEHICLE_DRIVER"    "HEAVY_GOODS_VEHICLE_PASSENGER"
#> [39] "HORSE"                         "HORSE_DRAWN_CARRIAGE"
names(od_clean) 
#> [1] "origin_zone"           "destination_zone"      "UNKNOWN_CAR_DRIVER"   
#> [4] "UNKNOWN_CAR_PASSENGER" "PEDAL_CYCLE"           "WALK"                 
#> [7] "RAIL_OTHER"            "BUS"                   "TAXI"
(modes_in_data = names(Mode)[names(Mode) %in% names(od_clean)])
#> [1] "WALK"                  "PEDAL_CYCLE"           "BUS"                  
#> [4] "RAIL_OTHER"            "UNKNOWN_CAR_DRIVER"    "UNKNOWN_CAR_PASSENGER"
#> [7] "TAXI"

for(i in 1:nrow(od_df)) {
  for(j in names(Purpose)[1]) { # only one purpose in this dataset
    for(k in modes_in_data) {
      od_new = new(
        OD,
        origin_zone = od_clean$origin_zone[i],
        destination_zone = od_clean$destination_zone[i],
        mode = k,
        purpose = "COMMUTE_UNKNOWN",
        number_trips = od_clean[[k]][i]
      )
      Dataset_new$add("od_trips", od_new)
    }
  }
}

Dataset_new$od_trips
#> [[1]]
#> message of type 'OD' with 5 fields set
#> 
#> [[2]]
#> message of type 'OD' with 5 fields set
#> 
#> [[3]]
#> message of type 'OD' with 5 fields set
#> 
#> [[4]]
#> message of type 'OD' with 5 fields set
#> 
#> [[5]]
#> message of type 'OD' with 5 fields set
#> 
#> [[6]]
#> message of type 'OD' with 5 fields set
#> 
#> [[7]]
#> message of type 'OD' with 5 fields set
```
