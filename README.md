# Plugin AWS Ressources

<p align="center">
  <img src="https://cdn.ocsinventory-ng.org/common/banners/banner660px.png" height=300 width=660 alt="Banner">
</p>

<h1 align="center">Plugin AWS Ressources</h1>
<p align="center">
  <b>Some Links:</b><br>
  <a href="http://ask.ocsinventory-ng.org">Ask question</a> |
  <a href="https://www.ocsinventory-ng.org/?utm_source=github-ocs">Website</a> |
  <a href="https://www.ocsinventory-ng.org/en/#ocs-pro-en">OCS Professional</a>
</p>

## Description

This plugin will retrieve Amazon AWS EC2 instances details using the describe-instances command of the AWS CLI.

## Prerequisites

*The following configuration has to be available :*
1. An AWS IAM user with AmazonEC2ReadOnlyAccess on the AWS infrastructure
2. AWS CLI installed, see : https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html


*AWS CLI Configuration :*

Configure an AWS CLI profile named 'ocs'.
```
>> aws configure --profile ocs
AWS Access Key ID [None]: ********************
AWS Secret Access Key [None]: *******************************
Default region name [None]: None
Default output format [None]: json
```

Enter your user's **access key ID** and **secret access key** provided at the user creation on the AWS management console.

Enter 'None' for the default region name. You will be able to add one or multiple regions inside **agent/Awsressources.pm**, see below for more details.

**JSON output is needed** for the plugin to work.


## Configuration

If you chose a different profile name than 'ocs' during the previous step, please edit the file **agent/Awsressources.pm** with your profile name : 

Line 46 :  
```
my $profile = 'ocs';
```
To choose which regions you want to search for instances, edit these lines : 

Line 49 to 52 :  
```
my @regions = (
            'us-east-2',
            'us-east-1',
            );
```



