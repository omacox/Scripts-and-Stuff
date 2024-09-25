#!/bin/bash

# name: AWS Cost Report
# description: Generate AWS cost and usage report

# Default values for macOS date
start_date=$(date -v-1m +%Y-%m-%d)  # 1 month ago
end_date=$(date +%Y-%m-%d)  # Today
granularity="MONTHLY"
metric="UsageQuantity"
cost_metric="BlendedCost"
group_by="SERVICE"
output_format="table"

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -s, --start-date YYYY-MM-DD   Start date (default: 1 month ago)"
    echo "  -e, --end-date YYYY-MM-DD     End date (default: today)"
    echo "  -g, --granularity GRAN        Granularity: DAILY|MONTHLY (default: MONTHLY)"
    echo "  -m, --metric METRIC           Metric to use (default: UsageQuantity)"
    echo "  -b, --group-by KEY            Group by: SERVICE|USAGE_TYPE|etc. (default: SERVICE)"
    echo "  -o, --output FORMAT           Output format: table|json|text (default: table)"
    echo "  -h, --help                    Display this help message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -s|--start-date)
            start_date="$2"
            shift 2
            ;;
        -e|--end-date)
            end_date="$2"
            shift 2
            ;;
        -g|--granularity)
            granularity="$2"
            shift 2
            ;;
        -m|--metric)
            metric="$2"
            shift 2
            ;;
        -b|--group-by)
            group_by="$2"
            shift 2
            ;;
        -o|--output)
            output_format="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Display headers and the date range being reported
echo ""
echo "AWS Cost and Usage Report"
echo "Reporting period: $start_date to $end_date"
echo "----------------------------------------------------------------------------------"
echo "|  Service Name      |  Usage Amount  |   Cost    |  Running Total |"
echo "----------------------------------------------------------------------------------"

# Run the AWS CLI command to fetch usage and cost data and store results
report=$(aws ce get-cost-and-usage \
    --time-period Start=$start_date,End=$end_date \
    --granularity $granularity \
    --metrics "$metric" "$cost_metric" \
    --group-by Type=DIMENSION,Key=$group_by \
    --query "ResultsByTime[].Groups[?Metrics.$metric.Amount!='0'].[Keys[0],Metrics.$metric.Amount,Metrics.$cost_metric.Amount]" \
    --output json)

# Initialize total cost variable and running total
total_cost=0.00
running_total=0.00

# Store report in a variable and loop without piping to avoid subshell issue
while IFS=$'\t' read -r service usage cost; do
    # Ensure that the cost and usage are valid numbers before formatting them
    if [[ "$cost" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        # Round the usage to zero decimal places
        usage=$(printf "%.0f" "$usage")

        # Format the cost to four decimal places
        cost=$(printf "%.4f" "$cost")

        # Update running total
        running_total=$(echo "scale=4; $running_total + $cost" | bc)

        # Print the service information along with the running total
        printf "| %-18s | %-14s | \$%-8s | \$%-8.4f |\n" "$service" "$usage" "$cost" "$running_total"

        # Accumulate the total cost
        total_cost=$(echo "scale=4; $total_cost + $cost" | bc)
    else
        echo "Invalid cost value encountered: $cost"
    fi
done < <(echo "$report" | jq -r '.[][] | @tsv')

# Print the final total cost at the end of the report, formatted with two decimal places
echo "----------------------------------------------------------------------------------"
printf "| %-34s | \$%-8.2f |\n" "Total Cost" "$total_cost"
echo "----------------------------------------------------------------------------------"