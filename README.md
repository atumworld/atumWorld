
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
                ('train', od_pb2.Mode.PublicTransit),
                ('bus', od_pb2.Mode.PublicTransit),
                ('taxi', od_pb2.Mode.Driving),
                ('car_driver', od_pb2.Mode.Driving),
                ('car_passenger', od_pb2.Mode.Driving),
                ('bicycle', od_pb2.Mode.Cycling),
                ('foot', od_pb2.Mode.Walking),
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
#>   mode: PublicTransit
#>   number_trips: 14
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: PublicTransit
#>   number_trips: 153
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   number_trips: 14
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   number_trips: 69
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   number_trips: 18
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: Cycling
#>   number_trips: 13
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: Walking
#>   number_trips: 679
#> }
print(MessageToJson(dataset))

# Or in the compact binary format
#> {
#>   "odTrips": [
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "PublicTransit",
#>       "numberTrips": 14
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "PublicTransit",
#>       "numberTrips": 153
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "numberTrips": 14
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "numberTrips": 69
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "numberTrips": 18
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "Cycling",
#>       "numberTrips": 13
#>     },
#>     {
#>       "originZone": "E02002384",
#>       "destinationZone": "E02006875",
#>       "mode": "Walking",
#>       "numberTrips": 679
#>     }
#>   ]
#> }
print(dataset.SerializeToString())
#> b'\x12\x1a\n\tE02002384\x12\tE02006875\x18\x03(\x0e\x12\x1b\n\tE02002384\x12\tE02006875\x18\x03(\x99\x01\x12\x18\n\tE02002384\x12\tE02006875(\x0e\x12\x18\n\tE02002384\x12\tE02006875(E\x12\x18\n\tE02002384\x12\tE02006875(\x12\x12\x1a\n\tE02002384\x12\tE02006875\x18\x01(\r\x12\x1b\n\tE02002384\x12\tE02006875\x18\x02(\xa7\x05'
with open('output.pb', 'wb') as outfile:
  outfile.write(dataset.SerializeToString())

#> 192
```

## In R

``` r
library(RProtoBuf)
readProtoFiles(files = "od.proto")
od = read.csv("minimal-example-od-dataset.csv")
con = file('output.pb', open = "rb")
message = read(Dataset, con)
cat(as.character(message))
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: PublicTransit
#>   number_trips: 14
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: PublicTransit
#>   number_trips: 153
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   number_trips: 14
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   number_trips: 69
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   number_trips: 18
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: Cycling
#>   number_trips: 13
#> }
#> od_trips {
#>   origin_zone: "E02002384"
#>   destination_zone: "E02006875"
#>   mode: Walking
#>   number_trips: 679
#> }
# how to get that into a data frame?
```
