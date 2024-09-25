#!/bin/bash
# A script to review defined groups of services to check for usage
# save to a file and display on the terminal    
# Oma Cox 2024.09.25

# Define the timestamp for the output file
timestamp=$(date +"%Y%m%d_%H%M%S")
output_file="${timestamp}_all_services_review.txt"

# Function to log output to both console and file
log() {
    echo "$1" | tee -a "$output_file"
}

# Start of the report
log "AWS Services Usage Report - $(date)"
log "==========================================="

# Function to check if a service has resources and handle errors
check_service() {
    service_name="$1"
    cli_command="$2"
    query="$3"

    log "Checking $service_name..."

    output=$(eval "$cli_command" 2>&1)
    if [[ $? -ne 0 ]]; then
        log "Error checking $service_name: $output"
    else
        if [[ "$output" == "null" || -z "$output" ]]; then
            log "$service_name: No resources found."
        else
            log "$service_name resources:"
            echo "$output" | tee -a "$output_file"
        fi
    fi
    log "==========================================="
}

# Example checks (expand with services from your list)
log "Checking services...\n"

# Analytics Services
check_service "Amazon Athena" "aws athena list-work-groups --output table" ''
# check_service "Amazon CloudSearch" "aws cloudsearch describe-domains --query 'DomainStatusList[*].[DomainName,Created,SearchInstanceCount]' --output table" ''
check_service "Amazon EMR" "aws emr list-clusters --active --query 'Clusters[*].[Name,Id,Status.State]' --output table" ''
check_service "Amazon Kinesis Data Streams" "aws kinesis list-streams --output table" ''
# check_service "Amazon QuickSight" "aws quicksight list-dashboards --output table" ''

# Application Integration Services
check_service "Amazon AppFlow" "aws appflow list-flows --output table" ''
check_service "Amazon SNS" "aws sns list-topics --output table" ''
check_service "Amazon SQS" "aws sqs list-queues --output table" ''

# AI Services
check_service "Amazon Lex" "aws lex-models get-bots --output table" ''
check_service "Amazon Polly" "aws polly list-speech-synthesis-tasks --output table" ''
check_service "Amazon Rekognition" "aws rekognition list-collections --output table" ''

# Storage Services
check_service "Amazon S3" "aws s3 ls" ''
check_service "Amazon EBS" "aws ec2 describe-volumes --output table" ''
check_service "Amazon FSx" "aws fsx describe-file-systems --output table" ''

# Compute Services
check_service "Amazon EC2" "aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' --output table" ''
check_service "AWS Lambda" "aws lambda list-functions --query 'Functions[*].[FunctionName,Runtime]' --output table" ''
check_service "Amazon Lightsail" "aws lightsail get-instances --output table" ''

# Networking Services
check_service "Amazon VPC" "aws ec2 describe-vpcs --output table" ''
check_service "Amazon CloudFront" "aws cloudfront list-distributions --output table" ''
check_service "Amazon Route 53" "aws route53 list-hosted-zones --output table" ''

# Finish report
log "AWS Services check completed."