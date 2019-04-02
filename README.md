# S3 Mirror

_Continuously mirror objects from one bucket to another._

The existing _S3 Replication_ doesn't work within the same region which
means it is not possible to mirror buckets between accounts when both
buckets are in the same region.

This little lambda enables just that. It listens for events from
_source bucket_ and propagates them to the _target bucket_. The
supported events include `ObjectCreate:Put`, `ObjectCreate:Copy` and
`ObjectRemoved:*`.

**Versioning** is enabled in the _target bucket_ and deletes therefore
don't permanently delete the objects. Deleting specific versions in
the target bucket is not propagated / supported as a prevention
from incidental or intentional wiping of the remote bucket.

## Deployment

1. Manually deploy the CloudFormation template `destination-account/template.yml`
   into the destination account. The only parameter it needs is the
   source _Account ID_.

   Wait for the deployment and note the new _Bucket Name_ from the
   stack outputs.

2. Create `config.{source-account-name}.sh` with the following
   contents:

        export AWS_DEFAULT_PROFILE={source-account-name}
        export AWS_DEFAULT_REGION=ap-southeast-2
        
        STACK_NAME=mirror-s3-to-somewhere-else
        CFN_ROLE=arn:aws:iam::123456789012:role/CloudformationRole
        DEPLOYMENT_BUCKET=cf-templates-a1b2c3d4e5f6g-${AWS_DEFAULT_REGION}
        SOURCE_BUCKET={existing-source-bucket-name}
        TARGET_BUCKET={target-bucket-from-step-1}

3. Run `./deploy.sh {source-account-name}` and wait for the deployment.

4. Run `./force-copy.sh {source-account-name}` to copy all the
   existing files from the _source bucket_ to the _target bucket_. This
   is one-off task.

5. Verify that all the objects propagated to the _target bucket_. Test
   some deletes too.

## Author

Michael Ludvig @ enterprise-IT
