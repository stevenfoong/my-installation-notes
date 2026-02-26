These steps is to configure SSO with Azure without using IAM Identity Center. In some case, IAM Identity Center option is not available.  
  
BTW using this method, you will get an app icon in https://myapps.microsoft.com/ , click on it, you will log in directly. From my point of view, this method is faster than IAM Identity Center.   

Overview of steps:  

#### At MS Entra ####   
1. Create a new app in Microsoft Entra. Enterprise Apps -> New Application -> Create your own application 
2. Enter the name of your app.
3. Select **Integrate any other application you don't find in the gallery (Non-gallery)**
4. Click on **Single sign-on**
5. Click on **SAML**
6. Click **Edit** at the **Basic SAML Configuration** section
7. Click **Add identifier**
8. In the Identifier field, enter: **https://signin.aws.amazon.com/saml** .  
   If you plan to configure multiple AWS SSO applications within the same Microsoft Entra tenant, use the following format instead: **https://signin.aws.amazon.com/saml#abc**  
   Append a # to the end of the base Identifier URL and add a unique ID (for example, abc). This ID must be unique within the Entra tenant and must not be duplicated across other AWS SSO configurations.
9. Click **Add reply URL**
10. Enter **https://signin.aws.amazon.com/saml**
11. Click **Save** button and close the **Basic SAML Configuration** page.
12. When prompted to test Single Sign-On, choose **No, I’ll test later.** to proceed without performing the test at this stage.
13. Click **Edit** at the **Attributes & Claims** section
14. Click on **Add new claim**
15. Enter the following details.
    Name: Role  
    Source: Attribute  
    Source attribute: user.assignedroles  
17. Click **Save** button
18. Repeat step 14 to create two additionals claims with the following details.
    Name: RoleSessionName
    Source: Attribute
    Source Attribute: user.userprincipalname

    Name : SessionDuration
    Source: Attribute
    Source Attribute: "43200"
20. Close the **Attributes & Claims** page.
21. Download the Federation Metadata XML.  
  
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
