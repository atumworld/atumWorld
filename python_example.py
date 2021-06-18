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
print(dataset)

# Or in JSON
print(MessageToJson(dataset))

# Or in the compact binary format
print(dataset.SerializeToString())

# Some next steps:
# - Write the dataset to a file
# - Read the dataset in R using the rprotobuf package
# - Port this Python example to R, so also transforming the .csv to the protobuf
