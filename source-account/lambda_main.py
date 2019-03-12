#!/usr/bin/env python3

# Copy objects from one bucket to another

import os
import json
import boto3

s3 = boto3.resource('s3')
destination = s3.Bucket(os.getenv('TARGET_BUCKET'))

def lambda_handler(event, context):
    print(json.dumps(event))
    for record in event['Records']:
        try:
            assert(record['eventSource'] == 'aws:s3' and record['eventName'] == 'ObjectCreated:Put')
        except:
            print("ERROR: Unexpected event record!")
            print(json.dumps(record))
            continue

        source = {
            'Bucket': record['s3']['bucket']['name'],
            'Key': record['s3']['object']['key']
        }
        # copy() doesn't return anything
        destination.copy(source, source['Key'],
            ExtraArgs = {'ACL': 'bucket-owner-full-control'})
