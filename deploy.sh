#!/bin/bash -exu

source config.${1}.sh

pushd source-account

TEMPLATE_FILE=$(mktemp template-XXXXXXXX.yml)

aws cloudformation package \
	--template-file template.yml \
	--output-template-file ${TEMPLATE_FILE} \
	--s3-bucket ${DEPLOYMENT_BUCKET}

aws cloudformation deploy \
	--template-file ${TEMPLATE_FILE} \
	--stack-name ${STACK_NAME} \
	--capabilities CAPABILITY_IAM \
	${CFN_ROLE:+--role-arn ${CFN_ROLE}} \
	--parameter-overrides \
      SourceBucket=${SOURCE_BUCKET} \
      TargetBucket=${TARGET_BUCKET}

rm -f ${TEMPLATE_FILE}

LAMBDA_ARN=$(aws cloudformation describe-stacks --stack-name ${STACK_NAME} | jq -r '.Stacks[0].Outputs[]|select(.OutputKey=="CopierLambdaArn").OutputValue')

NOTIFICATION_FILE=$(mktemp notification-XXXXXXXX.json)

cat > ${NOTIFICATION_FILE} << __EOF__
{
  "LambdaFunctionConfigurations": [
    {
      "Id": "${STACK_NAME}",
      "LambdaFunctionArn": "${LAMBDA_ARN}",
      "Events": ["s3:ObjectCreated:*","s3:ObjectRemoved:*"]
    }
  ]
}
__EOF__

NOTIFICATION_CONFIG=$(aws s3api get-bucket-notification-configuration --bucket ${SOURCE_BUCKET})
if [ -n "${NOTIFICATION_CONFIG}" ]; then
	set +x
	echo -e "\e[1m"
	echo "-------"
	echo "Bucket ${SOURCE_BUCKET} has non-empty notification configuration!"
	echo "Add the following config manually"
	cat ${NOTIFICATION_FILE}
	echo -e "\e[0m"
else
	aws s3api put-bucket-notification-configuration --bucket ${SOURCE_BUCKET} --notification-configuration file://${NOTIFICATION_FILE}
fi

rm -f ${NOTIFICATION_FILE}
popd
