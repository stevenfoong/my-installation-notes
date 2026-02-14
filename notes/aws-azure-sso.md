These steps is to configure SSO with Azure without using IAM Identity Center. In some case, IAM Identity Center option is not available.  
  
BTW using this method, you will get an app icon in https://myapps.microsoft.com/ , click on it, you will log in directly. From my point of view, this method is faster than IAM Identity Center.   

Overview of steps:  

#### At MS Entra ####   
1. Create a new app in Microsoft Entra. Enterprise Apps -> AWS Single-Account Access
2. Enter Identifier (Entity ID) and Reply URL with the same default value: https://signin.aws.amazon.com/saml.
3. Download the Federation Metadata XML.  
  
#### At AWS Console #### 
1. Create Identity providers
2. Create SAML 2.0 federation role
3. Create a service account that MS Entra able to list roles
4. Create access token for the service account

#### At MS Entra ####   
1. At the Provisioning section, configure the automatic provision.
2. Restart the provisioning.
3. At the Users and groups section, add user with the role. Make sure the AWS role is appear.
  
Now user should be able to login by clicking the icon at https://myapps.microsoft.com/    
  
### This is the reference guide.  ###
https://learn.microsoft.com/en-us/entra/identity/saas-apps/amazon-web-service-tutorial#configure-aws-single-account-access-sso
