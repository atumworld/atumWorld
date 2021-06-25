
<!-- README.md is generated from README.Rmd. Please edit that file -->

# atumWorld

## OD data protobuf example

All of this is a prototype/sketch.

First install the protobuf compiler. On Ubuntu,
`sudo apt-get install protobuf-compiler`; on other platforms, see
<https://developers.google.com/protocol-buffers/docs/downloads>.

Then generate the Python library as follows:

``` bash
protoc od.proto --python_out=.
#> bash: /home/robin/.local/share/r-miniconda/envs/r-reticulate/lib/libtinfo.so.6: no version information available (required by bash)
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
                ('train', od_pb2.Mode.RAIL),
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
            od.purpose = od_pb2.Purpose.Work
            od.number_trips = int(row[col_name])

# We can print in a human-readable format:
#> Summing the columns gives 946, but the all column says 966:
#> OrderedDict([('geo_code1', 'E02002384'), ('geo_code2', 'E02006875'), ('all', '966'), ('train', '14'), ('bus', '153'), ('taxi', '14'), ('car_driver', '69'), ('car_passenger', '18'), ('bicycle', '13'), ('foot', '679')])
print(dataset)

# Or in JSON
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: RAIL
#>   number_trips: 14
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: BUS
#>   number_trips: 153
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: TAXI
#>   number_trips: 14
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: UNKNOWN_CAR_DRIVER
#>   number_trips: 69
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: UNKNOWN_CAR_DRIVER
#>   number_trips: 18
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: PEDAL_CYCLE
#>   number_trips: 13
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   number_trips: 679
#> }
print(MessageToJson(dataset))

# Or in the compact binary format
#> {
#>   "odTrips": [
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "RAIL",
#>       "numberTrips": 14
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "BUS",
#>       "numberTrips": 153
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "TAXI",
#>       "numberTrips": 14
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "UNKNOWN_CAR_DRIVER",
#>       "numberTrips": 69
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "UNKNOWN_CAR_DRIVER",
#>       "numberTrips": 18
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "PEDAL_CYCLE",
#>       "numberTrips": 13
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "numberTrips": 679
#>     }
#>   ]
#> }
print(dataset.SerializeToString())
#> b'\x12\x1a\n\tE02002384\x12\tE02006875\x18\x13(\x0e\x12\x1b\n\tE02002384\x12\tE02006875\x18\x11(\x99\x01\x12\x1a\n\tE02002384\x12\tE02006875\x18\x16(\x0e\x12\x1a\n\tE02002384\x12\tE02006875\x18\x14(E\x12\x1a\n\tE02002384\x12\tE02006875\x18\x14(\x12\x12\x1a\n\tE02002384\x12\tE02006875\x18\x03(\r\x12\x19\n\tE02002384\x12\tE02006875(\xa7\x05'
with open('output.pb', 'wb') as outfile:
  outfile.write(dataset.SerializeToString())

#> 196
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
#>  [1] "WALK"                          "JOG"                          
#>  [3] "PUSH_SCOOTER"                  "PEDAL_CYCLE"                  
#>  [5] "PEDAL_CYCLE_PASSENGER"         "ELECTRIC_CYCLE"               
#>  [7] "ELECTRIC_CYCLE_PASSENGER"      "HORSE"                        
#>  [9] "HORSE_DRAWN_CARRIAGE"          "MICROMOBILITY_UNKNOWN"        
#> [11] "ELECTRIC_SCOOTER"              "MOBILITY_SCOOTER"             
#> [13] "MOTORCYCLE"                    "MOTORCYCLE_PASSENGER"         
#> [15] "PUBLIC_TRANSPORT_OTHER"        "AUTO_RICKSHAW"                
#> [17] "MINIBUS"                       "BUS"                          
#> [19] "LIGHT_RAIL"                    "RAIL"                         
#> [21] "UNKNOWN_CAR_DRIVER"            "UNKNOWN_CAR_PASSENGER"        
#> [23] "TAXI"                          "CARPOOL"                      
#> [25] "MICRO_CAR_DRIVER"              "MICRO_CAR_PASSENGER"          
#> [27] "SMALL_CAR_DRIVER"              "SMALL_CAR_PASSENGER"          
#> [29] "MEDIUM_CAR_DRIVER"             "MEDIUM_CAR_PASSENGER"         
#> [31] "LARGE_CAR_DRIVER"              "LARGE_CAR_PASSENGER"          
#> [33] "VAN_DRIVER"                    "VAN_PASSENGER"                
#> [35] "TRUCK_DRIVER"                  "TRUCK_PASSENGER"              
#> [37] "HEAVY_GOODS_VEHICLE_DRIVER"    "HEAVY_GOODS_VEHICLE_PASSENGER"
names(Purpose)
#> [1] "Work"     "Home"     "Shopping" "Leisure"  "Social"
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
    UNKNOWN_PUBLIC_TRANSPORT = train + bus
  )

# Clean data, match names to schema
names(Mode)
#>  [1] "WALK"                          "JOG"                          
#>  [3] "PUSH_SCOOTER"                  "PEDAL_CYCLE"                  
#>  [5] "PEDAL_CYCLE_PASSENGER"         "ELECTRIC_CYCLE"               
#>  [7] "ELECTRIC_CYCLE_PASSENGER"      "HORSE"                        
#>  [9] "HORSE_DRAWN_CARRIAGE"          "MICROMOBILITY_UNKNOWN"        
#> [11] "ELECTRIC_SCOOTER"              "MOBILITY_SCOOTER"             
#> [13] "MOTORCYCLE"                    "MOTORCYCLE_PASSENGER"         
#> [15] "PUBLIC_TRANSPORT_OTHER"        "AUTO_RICKSHAW"                
#> [17] "MINIBUS"                       "BUS"                          
#> [19] "LIGHT_RAIL"                    "RAIL"                         
#> [21] "UNKNOWN_CAR_DRIVER"            "UNKNOWN_CAR_PASSENGER"        
#> [23] "TAXI"                          "CARPOOL"                      
#> [25] "MICRO_CAR_DRIVER"              "MICRO_CAR_PASSENGER"          
#> [27] "SMALL_CAR_DRIVER"              "SMALL_CAR_PASSENGER"          
#> [29] "MEDIUM_CAR_DRIVER"             "MEDIUM_CAR_PASSENGER"         
#> [31] "LARGE_CAR_DRIVER"              "LARGE_CAR_PASSENGER"          
#> [33] "VAN_DRIVER"                    "VAN_PASSENGER"                
#> [35] "TRUCK_DRIVER"                  "TRUCK_PASSENGER"              
#> [37] "HEAVY_GOODS_VEHICLE_DRIVER"    "HEAVY_GOODS_VEHICLE_PASSENGER"
names(od_df) 
#>  [1] "geo_code1"     "geo_code2"     "all"           "train"        
#>  [5] "bus"           "taxi"          "car_driver"    "car_passenger"
#>  [9] "bicycle"       "foot"
(modes_in_data = names(Mode)[names(Mode) %in% names(od_clean)])
#> [1] "WALK"                  "PEDAL_CYCLE"           "UNKNOWN_CAR_DRIVER"   
#> [4] "UNKNOWN_CAR_PASSENGER"

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
```
