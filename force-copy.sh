#!/bin/bash -exu

# List objects in SOURCE_BUCKET and feed the list to the Copier Lambda
# that will then copy them across to the TARGET_BUCKET just like any other object.
#
# This should be called right after deployment to copy across the existing files.

source config.${1}.sh

LAMBDA_NAME=$(aws cloudformation describe-stacks --stack-name ${STACK_NAME} | jq -r '.Stacks[0].Outputs[]|select(.OutputKey=="CopierLambda").OutputValue')

EVENT_FILE=$(mktemp list-XXXXXXXX.json)

# List objects from the bucket
aws s3api list-objects-v2 --bucket ${SOURCE_BUCKET} | \
	jq ".+={Bucket: \"${SOURCE_BUCKET}\"}" | \
	jq '.Bucket as $Bucket | { "Records": [ .Contents[]|{"eventSource": "aws:s3", "eventName": "ObjectCreated:Put", "s3": { "bucket": { "name": $Bucket }, "object": { "key": .Key } } } ] }' > ${EVENT_FILE}

NUM_OBJECTS=$(jq '.Records|length' ${EVENT_FILE})
echo "Copying ${NUM_OBJECTS} objects from ${SOURCE_BUCKET} to ${TARGET_BUCKET}"

aws lambda invoke --function-name ${LAMBDA_NAME} --invocation-type Event --payload file://${EVENT_FILE} /dev/null

rm -f ${EVENT_FILE}
