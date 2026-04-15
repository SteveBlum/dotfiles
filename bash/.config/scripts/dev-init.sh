#!/bin/bash

name="$1"

if [ -z "$name" ]; then
    echo "Usage: ./dev-init.sh <environment_name>"
    exit 1
fi

SCRIPT_DIR=$(dirname "$0")
TEMPLATE_FILE="$SCRIPT_DIR/.env.template"
OUTPUT_FILE="$SCRIPT_DIR/$name.env"
LAST_ENV_FILE="$SCRIPT_DIR/.env.last"

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: .env.template not found at '$TEMPLATE_FILE'." >&2
    exit 1
fi

echo "Creating or updating '$OUTPUT_FILE' from '$TEMPLATE_FILE'."
echo "Priority for default values: '$OUTPUT_FILE' > '$LAST_ENV_FILE' > '$TEMPLATE_FILE'."
echo "Please provide values for the environment variables. Press Enter to keep the current value."

declare -A last_env_vars
if [ -f "$LAST_ENV_FILE" ]; then
    echo "Existing '$LAST_ENV_FILE' found. Its values will be used as defaults if not overridden."
    while IFS='=' read -r key value; do
        if [[ ! -z "$key" && "$key" != \#* ]]; then
            # Remove quotes if present
            value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
            last_env_vars["$key"]="$value"
        fi
    done < "$LAST_ENV_FILE"
fi

declare -A existing_env_vars
if [ -f "$OUTPUT_FILE" ]; then
    echo "Existing '$OUTPUT_FILE' found. Its values will be prioritized as defaults."
    while IFS='=' read -r key value; do
        if [[ ! -z "$key" && "$key" != \#* ]]; then
            # Remove quotes if present
            value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
            existing_env_vars["$key"]="$value"
        fi
    done < "$OUTPUT_FILE"
    fi

new_content=""

# Open the template file on fd 4 so the script's stdin remains available for
# interactive prompts. This avoids the classic problem where "while read ... < file"
# consumes stdin and prevents user input.
if ! exec 4<"$TEMPLATE_FILE"; then
    echo "Failed to open template file '$TEMPLATE_FILE' for reading." >&2
    exit 1
fi

while IFS= read -r line <&4; do
    if [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_]+)=(.*) ]]; then
        key="${BASH_REMATCH[1]}"
        template_value="${BASH_REMATCH[2]}"
        # Remove quotes from template value if present
        template_value=$(echo "$template_value" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")

        default_value="$template_value"

        if [[ -n "${last_env_vars[$key]}" ]]; then
            default_value="${last_env_vars[$key]}"
        fi
        
        if [[ -n "${existing_env_vars[$key]}" ]]; then
            default_value="${existing_env_vars[$key]}"
        fi
        
        # Prompt on stdin/stdout (the user's terminal). Reading from stdin
        # works because we've opened the template file on fd 4.
        printf "Enter value for '%s' (current: '%s'): " "$key" "$default_value"
        if ! read -r user_input; then
            echo "No interactive input; using default for '$key'." >&2
            user_input=""
        fi

        if [ -z "$user_input" ]; then
            new_content+="$key=$default_value"$'\n'
        else
            new_content+="$key=$user_input"$'\n'
        fi
    else
        new_content+="$line"$'\n'
    fi
done

# Close fd 4
exec 4<&-

# Remove trailing newline if any
new_content=${new_content%$'\n'}

echo "$new_content" > "$OUTPUT_FILE"
echo "Successfully created '$OUTPUT_FILE'."

echo "$new_content" > "$LAST_ENV_FILE"
echo "Saved current configuration to '$LAST_ENV_FILE'."
