git clone using ssh from gitlab with different ssh port number  
```
git clone ssh://git@123.123.123.123:8022/project-or-group/repo-name.git
```  

You will need to create a self sign cert , if you plan to use reverse proxy and let the reverse proxy to handle the cert. you will also need to rename all three files with the domain name of gitlab
```
mkdir -p /data/gitlab/config/ssl
cd /data/gitlab/config/ssl
openssl genrsa -out gitlab.example.com.key 2048
openssl req -new -key gitlab.example.com.key -out gitlab.example.com.csr
openssl x509 -in gitlab.example.com.csr -out gitlab.example.com.crt -req -signkey gitlab.example.com.key -days 3650
```

# To configure SSO with MS Entra #  
  
## Modify gitlab.rb ##
  
Append these links into the gitlab.rb. 
```
gitlab_rails['omniauth_allow_single_sign_on'] = ['saml']
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['omniauth_auto_link_saml_user'] = true
```
Append this block as well, but replace these items

| gitlab.rb setting | Microsoft Entra ID field | Remark |
|---|---|---|  
|issuer|Identifier (Entity ID)|Copy this from gitlab.rb and enter to the Entra's Entity ID. This should be the URL of the gitlab|
|assertion_consumer_service_url|Reply URL (Assertion Consumer Service URL)|Copy this from gitlab.rb to the Entra's Reply URL| Replace the domain name with the gitlab domain name.|
|idp_sso_target_url|Login URL| Copy this from SAML configuration Section 4 Login URL. You will need start new app registration in Entra, then only you will find this URL|
|idp_cert_fingerprint|Thumbprint| Copy this from SAML configuration section 3 Thumbprint. It will be a long string without colon. Again You will need start new app registration in Entra, then only you will find this URL|

```
gitlab_rails['omniauth_providers'] = [
  {
    name: "saml", # This must be lowercase.
    label: "MS365", # optional label for login button, defaults to "Saml"
    args: {
      assertion_consumer_service_url: "https://gitlab.example.com/users/auth/saml/callback",
      idp_cert_fingerprint: "2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6",
      idp_sso_target_url: "https://login.example.com/idp",
      issuer: "https://gitlab.example.com",
      name_identifier_format: "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
    }
  }
]
```

## Register New app in Entra ##
1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com/)  
2. Entra ID > Enterprise Apps > New application > Create your own application  
3. Enter a name for your apps and select **Integrate any other application you don't find in the gallery (Non-gallery)**  
4. Set up single sign on > Basic SAML Configuration
5. Enter Identifier (Entity ID) and Reply URL (Assertion Consumer Service URL) accordingly, refer to the table above  
6. Look for the section for “Attributes and Claims,” and click the Edit pencil icon. The first thing we want to do is modify the Unique User identifier (Name ID) value, so click on that row and set the Source attribute to user.objectid. Additionally, the Name identifier format must be updated, and set to Persistent.
7. Delete those default four items under **Additional claims**
8. Add new Additional claims using the info in the table below. Note that these values are case sensitive.
   
| **Name** | **Namespace** | **Source Attribute** |  
|---|---|---|  
|NameID|http://schemas.microsoft.com/ws/2008/06/identity/claims|user.objectid|  
|emailaddress|http://schemas.microsoft.com/ws/2008/06/identity/claims|user.mail|  
|name|http://schemas.microsoft.com/ws/2008/06/identity/claims|user.displayname|  
|Unique User Identifier|http://schemas.microsoft.com/ws/2008/06/identity/claims|user.objectid|  
  
9. under the Advance settings, enable **Include attribute name format setting**.
10. At the **Users and groups**, you can assign which user are allow to login gitlab using MS365 SSO.
11. Now go back to gitlab.rb to update the **idp_sso_target_url** and **idp_cert_fingerprint** with the information you found in the Entra application configuration.  
  
After saving the gitlab.rb file, remember to use this command to commit change to the system.  
```
gitlab-ctl reconfigure
```


 
**Reference:**  
[How-to: GitLab Single Sign-on with SAML, SCIM, and Azure’s Entra ID](https://about.gitlab.com/blog/how-to-gitlab-single-sign-on-with-saml-scim-and-azures-entra-id/ "How-to: GitLab Single Sign-on with SAML, SCIM, and Azure’s Entra ID")    
[Configure SAML support in GitLab](https://docs.gitlab.com/integration/saml/#configure-saml-support-in-gitlab "Configure SAML support in GitLab")   
[Example Configuration](https://docs.gitlab.com/user/group/saml_sso/example_saml_config/#basic-saml-app-configuration "Example Configuration")  

