export AWS_DEFAULT_PROFILE=some-profile
export AWS_DEFAULT_REGION=ap-southeast-2

STACK_NAME=test-s3-mirror
CFN_ROLE=arn:aws:iam::123456789012:role/cfnRole
DEPLOYMENT_BUCKET=cf-templates-a1b2c3d4e5f6-${AWS_DEFAULT_REGION}
SOURCE_BUCKET=test-source-bucket
TARGET_BUCKET=backup-test-source-bucket-1234abcd12abc
