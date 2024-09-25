# A Bunch of Scripts

## Table of Contents

- [menu.sh](#menu-sh)
- [aws_cost_report.sh](#aws_cost_reportsh)
- [policy_user_list.sh](#policy_user_listsh)
- [services_list_check_2_file.sh](#services_list_check_2_filesh)
- [services_all_used.sh](#services_all_usedsh)

## Enviorment in Terminal

- All scripts tested on Mac OS Sonoma 14.6.1
- Tested on Mac OS Sonoma 14.6.1

## menu.sh

- Menu Script for Command Line items for AWS and URL in Google Chrome
- You have to have your keys from AWS saved in the .aws folder and Chrome Browser on your system.
- Also, use `chmod` on the this menu file to allow it to run: `chmod +x filename.sh`
- Use Automator for desktop icon open, select run shell script and add the two lines below:

```bash

open -a Terminal /Users/<your-username>/scripts/menu.sh
exit

```

## aws_cost_report.sh

Example of result of the script running providing Script description
and usage information for aws_cost_report.sh.

```bash

AWS Cost and Usage Report
----------------------------------------------------------------------------------
|  Service Name      |  Usage Amount  |   Cost    |  Running Total |
----------------------------------------------------------------------------------
| AWS Key Management Service | 12             | $0.0000   | $0.0000   |
| AWS Secrets Manager | 4              | $0.0000   | $0.0000   |
| Amazon Simple Notification Service | 4              | $0.0000   | $0.0000   |
| Amazon Simple Queue Service | 4              | $0.0000   | $0.0000   |
| Amazon Simple Storage Service | 285            | $0.0001   | $0.0001   |
| AWS CloudShell     | 0              | $0.0000   | $0.0001   |
| AWS Cost Explorer  | 56             | $0.5600   | $0.5601   |
| AWS Glue           | 1              | $0.0000   | $0.5601   |
| AWS Key Management Service | 303            | $0.0097   | $0.5698   |
| AWS Secrets Manager | 15             | $0.0000   | $0.5698   |
| AWS Step Functions | 0              | $0.0000   | $0.5698   |
| Amazon CloudFront  | 343            | $0.0000   | $0.5698   |
| Amazon Relational Database Service | 343            | $0.5269   | $1.0967   |
| Amazon Route 53    | 99666          | $2.0399   | $3.1366   |
| Amazon Simple Notification Service | 18             | $0.0000   | $3.1366   |
| Amazon Simple Queue Service | 15             | $0.0000   | $3.1366   |
| Amazon Simple Storage Service | 35676          | $0.0056   | $3.1422   |
| Amazon Virtual Private Cloud | 158            | $0.7898   | $3.9320   |
| AmazonCloudWatch   | 14             | $0.0000   | $3.9320   |
----------------------------------------------------------------------------------
| Total Cost                         | $3.93     |
----------------------------------------------------------------------------------

```

## policy_user_list.sh

This list all users that you have access to via aws cl

Enter number and will provide all permissions given to the users

start the app on the command line

```bash

./policy_user_list.sh

```

Example of the Menu

```bash

Fetching list of IAM users...
IAM Users:
 1. KTa
 2. BiCoast
 3. Ianic
 4. Kitter
 5. kitkater
 6. Kyral
 7. Omaha
 8. PrimeDev
 9. TimHold
10. timhold-acmewerx-s3
11. ZeeChee
Select a user by number (or press X to exit):

```

## services_list_check_2_file.sh

List all services from csv file output to screen and datetime stamped file
the file aws_all_services_mod.csv contains the list of services and commands

## services_all_used.sh

list of groups of services to check and list to file and terminal screen
