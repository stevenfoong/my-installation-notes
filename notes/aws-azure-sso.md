These steps is to configure SSO with Azure without using IAM Identity Center. In some case, IAM Identity Center option is not available.  
  
BTW using this method, you will get an app icon in https://myapps.microsoft.com/ , click on it, you will log in directly. From my point of view, this method is faster than IAM Identity Center.   

Overview of steps:  

#### At MS Entra ####   
1. Create a new app in Microsoft Entra. Enterprise Apps -> New Application -> Amazon Web Services (AWS) -> AWS Single-Account Access 
2. Enter the name of your app.
3. Click **Create**
4. Click on **Single sign-on**
5. Click on **SAML**
6. When prompted to **Save single sign-on setting**, choose **No, I’ll save later.** to proceed without performing the save action at this stage.
7. Click **Edit** at the **Basic SAML Configuration** section
8. Click **Add identifier**
9. In the Identifier field, enter: **https://signin.aws.amazon.com/saml** .  
   If you plan to configure multiple AWS SSO applications within the same Microsoft Entra tenant, use the following format instead: **https://signin.aws.amazon.com/saml#abc**  
   Append a # to the end of the base Identifier URL and add a unique ID (for example, abc). This ID must be unique within the Entra tenant and must not be duplicated across other AWS SSO configurations.
10. Click **Add reply URL**
11. Enter **https://signin.aws.amazon.com/saml**
12. Click **Save** button and close the **Basic SAML Configuration** page.
13. When prompted to test Single Sign-On, choose **No, I’ll test later.** to proceed without performing the test at this stage.
14. Download the Federation Metadata XML.  
  
#### At AWS Console #### 

1. Goto **IAM Dashboard**
2. Click on **Identity providers**
3. Click **Add provider**
4. Enter the **Provider name**
5. Upload the Federation Metada XML file that download at the step 15 in the previous section
6. Click **Add provider** button to save change
7. Click on **Roles**
8. Click **Create Role**
9. Select **SAML 2.0 federation role**
10. Select the **SAML 2.0–based provider** that created in the step 2
11. Select **Access to be allowed**
12. Select **Non-Regional endpoint**
13. Select **Without unique identifiers**
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
28. Enter this into the Policy editor
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:ListRoles"
            ],
            "Resource": "*"
        }
    ]
}
```
29. Click **Next**
30. Enter the Policy name
31. Click **Create policy**
32. Switch back to the page at step 25
33. Click Refresh button next to the Create policy
34. Search and select the Role created at step 31
35. Click **Next**
36. Click **Create User**
37. Once the user account created, click on **View User** button
38. Clik on **Security credentials**
39. Click **Create access key**
40. Select **Command Line Interface (CLI)** for the Use case
41. Click **Next** 
42. Click **Create access key**
43. Record the **Access Key** and the **Secret access key**
44. Click **Done**

#### At MS Entra ####   
1. Click on Provisioning
2. Click **New configuration**
3. Enter the **Client secret** and **Secret token** that generated at the step 43 in previous section.
4. Click **Test connection**
5. Once the test is success, click **Create**
6. Click **Start provisioning** and click **Yes**
7. Once the Initial sync completed, close the provisioning page
8. Click **Users and groups** , click **Add user/group**
9. Select User and make sure role had been selected. Click **Assign**
  
Now user should be able to login by clicking the icon at https://myapps.microsoft.com/    
  
### This is the reference guide.  ###
https://learn.microsoft.com/en-us/entra/identity/saas-apps/amazon-web-service-tutorial#configure-aws-single-account-access-sso
