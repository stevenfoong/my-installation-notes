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

1. Goto **IAM Dashboard**
2. Click on **Identity providers**
3. Click **Add provider**
4. Enter the **Provider name**
5. Upload the Federation Metada XML file that download at the step 21 in the previous section
6. Click **Add provider** button to save change
7. Click on **Roles**
8. Click **Create Role**
9. Select **SAML 2.0 federation role**
10. Select the **SAML 2.0–based provider** that created in the step 2
11. Select **Access to be allowed**
12. Select **Non-Regional endpoint**
13. Select **With unique identifiers**
14. Make sure the **Attribute value for non-Regional endpoint** value is **https://signin.aws.amazon.com/saml**
15. Click **Next**
16. Add required **Permissions policies**
17. Click **Next**
18. Enter **Role name**
19. Click **Create Role**
20. Define and create the necessary roles according to organizational needs.
21. Click on **User**
22. Click **Create User**
23. Enter **User name**
24. Click **Next**
25. Select **Attach policies directly**
26. Click **Create policy**
27. Click **JSON** at the Policy editor
28. 

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
