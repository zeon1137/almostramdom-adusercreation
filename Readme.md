# Almost Random AD Users

## Idea behid the script
While working on my HomeLab Active Directoy, I needed to create a big quantity of user to across a handful of Organizational Units for study Identity Management as well as some Pentesting and though that a script were I count input a target number of users would be a great (also if I screw up and needed to rebuild my AD :stuck_out_tongue_closed_eyes: this would come handy)

Why the name almost random? Well since scripting is not my forte I went with the approach of providing files with the user information needed to work.

## Pre-requisites for running the script

### Local Access to your AD

- This script is made to work locally on your AD, since its a for HomeLab and huge maybe testing environments this should not be an issue, but still.
- Prebuilt Organizational Unit (OUs), your AD configuraiton should have a handful of OUs already created for this script to work as is.

### Files with UserName information

This script works with 3 files:

- A TXT file with the given name for your users.
- A TXT file with the surname for your users.
- A TXT file with the name of OUs where your users will be added to.

All files need to be single item per lines. Example files are included on the 'samplefiles' folder.

## Limitations of thìs Script

- This script does not work with subdomains. If for some reason your AD Forest was configured with a subdomain (like drive.google.com) it will break. It only works with simple domains (such as myenterprise.com, mydomain.local).
- The script currently only supports adding users to first level OUs: this is due to how the PathAddress variable within AD works.

        Supported

        -mydomain.local
            - Finance
            - Technology
            - Management ...
    
        Not Supported
            -mydomain.local
            - Finance
                -- RTR
                -- STP
            - Technology
                -- Infraestructure
                -- DevOps


## Using the CreateADUsers script

1) Put CreateADUsers.ps1 on a folder within AD server.
2) Have the full path of your files at hand (C:\PathToFile\Filename.txt)
3) Execute the script through PowerShell or PowerShell ISE
    ![StartScript][startscritp]

4) The script will request for the variables mentioned before.
    ![ScriptVars][scriptvars]

5) Wait for it to do its thing, it will print on script the point in which is currently at.


## Identified Improvements:

- [ ] Better Data Validation  
- [ ] Better existing user validation
- [ ] Add additonal step validation and error handling
- [ ] Output users to file (makes using the credentials latter easier)
- [ ] Support nested OUs (maybe)


[startscritp]: img/initatescript.gif
[scriptvars]: img/scriptvariables.gif