#!/bin/bash -ex

pushd source-account
export AWS_DEFAULT_PROFILE=eitnz-sandpit
export AWS_DEFAULT_REGION=us-west-2
aws cloudformation package \
	--template-file template.yml \
	--output-template-file .template.packaged.yml \
	--s3-bucket cf-templates-7wjanqqzs0ok-${AWS_DEFAULT_REGION}
aws cloudformation deploy \
	--template-file .template.packaged.yml \
	--stack-name s3-copier-src \
	--capabilities CAPABILITY_IAM \
	--parameter-overrides TargetBucket=s3-copier-dst-bucket-nenh96t5716k
popd

#export AWS_DEFAULT_PROFILE=eit-sandpit
#export AWS_DEFAULT_REGION=ap-southeast-2
