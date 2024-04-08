This note is about sharing AWS resoruces across account.  

# Share AMI

The Shared AMI can only deploy within same region , if need to deploy to different region will need to copy the AMI to another region first.  

### Share an AMI with specific AWS accounts
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/sharingamis-explicit.html

### Copy an AMI
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/CopyingAMIs.html

# Share DB snapshot

If the DB is encrypted by AWS manage key , perform the following steps  

1. Create a Customer managed key and shared it.
2. Create the snapshot of the encrypted DB.
3. Copy the encrypted DB snapshot with the shared customer managed key
4. Then share this customer managed key's encrypted DB snapshot

### Sharing a DB snapshot
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ShareSnapshot.html

