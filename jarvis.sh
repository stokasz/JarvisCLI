#!/bin/bash

# stokarz-key
if [[ -z "$API_KEY" ]]; then
    echo "Error: API_KEY environment variable is not set."
    exit 1
fi 

# Function to format code blocks
function format_code() {
    echo -e "\033[38;5;214m$1\033[0m"  # Yellowish color for code
}

function chatgpt() {
    local prompt="$1"
    echo "Prompt: $prompt"  # Debugging line
    local response=$(curl -s https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d '{
            "model": "gpt-4o",
            "messages": [{"role": "user", "content": "'"${prompt}"'"}]
        }')
    
    # Extract the relevant information using jq
    local content=$(echo "$response" | jq -r '.choices[0].message.content')
    local prompt_tokens=$(echo "$response" | jq -r '.usage.prompt_tokens')
    local completion_tokens=$(echo "$response" | jq -r '.usage.completion_tokens')

    # Format the parsed message to highlight code blocks
    local formatted_content=$(echo "$content" | awk '
    BEGIN {
        code_block = 0;
    }
    {
        if ($0 ~ /```/) {
            code_block = !code_block;
            if (code_block) {
                print "\033[1m\033[38;5;214m";
            } else {
                print "\033[0m";
            }
        } else if (code_block) {
            print "\033[38;5;214m" $0 "\033[0m";
        } else {
            print $0;
        }
    }')
    
    # Print the extracted information
    echo "Parsed message: $formatted_content"
    echo -e "\nPrompt Tokens: $prompt_tokens"
    echo "Completion Tokens: $completion_tokens"
} 

# Main command processing
if [[ -n "$1" ]]; then
    chatgpt "$1"
else
    echo "It seems like I don't really understand your question."
fi
