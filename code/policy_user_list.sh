#!/bin/bash
# policy_user_list.sh - A script to list IAM users and their permissions
# Function to list IAM users
list_users() {
    echo "Fetching list of IAM users..."
    users=$(aws iam list-users --query 'Users[].{Username:UserName}' --output json)

    # Display users in a numbered list
    echo "IAM Users:"
    echo "$users" | jq -r '.[] | "\(.Username)"' | nl -w 2 -s '. '

    echo "Select a user by number (or press X to exit):"
}

# Function to fetch and display the actions for a given policy
fetch_policy_actions() {
    local policy_arn=$1
    local version_id=$2

    # Fetch the policy document
    policy_document=$(aws iam get-policy-version --policy-arn "$policy_arn" --version-id "$version_id" --query 'PolicyVersion.Document.Statement' --output json)

    # Extract and display actions from the policy
    actions=$(echo "$policy_document" | jq -r '.[] | .Action | if type == "array" then .[] else . end')
    
    if [ -z "$actions" ]; then
        echo "No actions found."
    else
        echo "$actions"
    fi
}

# Function to fetch inline policy actions
fetch_inline_policy_actions() {
    local selected_user=$1
    local policy_name=$2

    # Fetch the inline policy document
    policy_document=$(aws iam get-user-policy --user-name "$selected_user" --policy-name "$policy_name" --query 'PolicyDocument.Statement' --output json)

    # Extract and display actions from the inline policy
    actions=$(echo "$policy_document" | jq -r '.[] | .Action | if type == "array" then .[] else . end')
    echo "$actions"
}

# Function to display permissions for a selected user
display_permissions() {
    local selected_user=$1
    echo "Fetching permissions for user: $selected_user"

    # 1. List attached policies directly assigned to the user
    echo "User-attached policies for $selected_user:"
    attached_policies=$(aws iam list-attached-user-policies --user-name "$selected_user" --query 'AttachedPolicies[].{PolicyName:PolicyName,Arn:PolicyArn}' --output json)
    
    # Loop through each attached policy and display actions
    for policy_arn in $(echo "$attached_policies" | jq -r '.[].Arn'); do
        policy_name=$(echo "$attached_policies" | jq -r --arg arn "$policy_arn" '.[] | select(.Arn==$arn) | .PolicyName')
        echo "Policy: $policy_name"

        # Get the default version of the policy
        default_version=$(aws iam get-policy --policy-arn "$policy_arn" --query 'Policy.DefaultVersionId' --output text)
        
        # Fetch and display the actions for the attached policy
        echo "Actions:"
        fetch_policy_actions "$policy_arn" "$default_version"
        echo ""
    done

    # 2. List group memberships and the policies attached to those groups
    echo "Group-attached policies for $selected_user:"
    groups=$(aws iam list-groups-for-user --user-name "$selected_user" --query 'Groups[].GroupName' --output text)

    if [ -z "$groups" ]; then
        echo "No groups found."
    else
        for group in $groups; do
            echo "Group: $group"

            # List attached policies for each group
            attached_group_policies=$(aws iam list-attached-group-policies --group-name "$group" --query 'AttachedPolicies[].{PolicyName:PolicyName,Arn:PolicyArn}' --output json)

            for policy_arn in $(echo "$attached_group_policies" | jq -r '.[].Arn'); do
                policy_name=$(echo "$attached_group_policies" | jq -r --arg arn "$policy_arn" '.[] | select(.Arn==$arn) | .PolicyName')
                echo "Policy: $policy_name"

                # Get the default version of the policy
                default_version=$(aws iam get-policy --policy-arn "$policy_arn" --query 'Policy.DefaultVersionId' --output text)

                # Fetch and display the actions for the group policy
                echo "Actions:"
                fetch_policy_actions "$policy_arn" "$default_version"
                echo ""
            done
        done
    fi

    # 3. List inline policies directly attached to the user
    echo "Inline policies for $selected_user:"
    inline_policies=$(aws iam list-user-policies --user-name "$selected_user" --output json | jq -r '.PolicyNames[]')

    if [ -z "$inline_policies" ]; then
        echo "No inline policies."
    else
        for policy_name in $inline_policies; do
            echo "Inline Policy: $policy_name"
            echo "Actions:"
            fetch_inline_policy_actions "$selected_user" "$policy_name"
            echo ""
        done
    fi

    echo ""
    echo "Press Enter to return to the user list..."
    read

    # Clear the screen after pressing Enter and redisplay the menu
    clear
}

# Main loop to list users, allow selection, and show permissions
while true; do
    # Clear the screen before showing the menu
    clear
    
    # List users
    list_users

    # Read user input
    read -r choice

    # Check if the user wants to exit
    if [[ "$choice" =~ ^[Xx]$ ]]; then
        echo "Exiting the script..."
        break
    fi

    # Check if the input is a valid number
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        selected_user=$(echo "$users" | jq -r ".[$((choice-1))].Username")

        # If the selected user is valid, display permissions
        if [ -n "$selected_user" ]; then
            display_permissions "$selected_user"
        else
            echo "Invalid selection. Please try again."
            sleep 2
            clear
        fi
    else
        echo "Invalid input. Please enter a number or 'X' to exit."
        sleep 2
        clear
    fi
done