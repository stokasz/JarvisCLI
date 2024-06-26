#!/bin/bash

# Jarvis is a simple shell script that allows you to interact with ChatGPT through the command line. 
# It provides a convenient way to generate responses based on prompts and engage in conversational sessions with memory capability.

# Function to display help information. 
function display_help() 
{
    echo "Usage: jarvis [command] [prompt]"
    echo
    echo "Commands:"
    echo "  help           Show the help message for absolute morons."
    echo "  \"prompt\"     Generate a single response based on the provided prompt."
    echo "  start          Start a conversation session with Jarvis remembering things."
    echo "    -file.txt    Restart the previous conversation from the specified file."
    echo "  stop           Finish the current conversation session with Jarvis."
    echo
    echo "Examples:"
    echo "  jarvis \"Generate Solidity code for storing a single variable\""
    echo "  jarvis start"
    echo "  jarvis start -conversation.txt"
    echo "  jarvis stop"
}

# API key to ChatGPT.
if [[ -z "$API_KEY" ]]; then
    echo "Error: API_KEY environmental variable isn't set."
    exit 1
fi

# Define the folder where conversation files will be saved.
CONVERSATION_FOLDER="$HOME/Conversations"

# Create the folder if it doesn't exist.
mkdir -p "$CONVERSATION_FOLDER"

# We use a system prompt that should enhance assistant's coding capabilities. It was derived from Anthropic's prompt library. 
function chatgpt 
{
    local prompt="$1"
    local response=$(curl -s https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d '{
            "model": "gpt-4o",
            "temperature": "0.3",
            "messages": [
                {
                    "role": "system", 
                    "content": "Your task is to answer software engineering questions, provide code snippets, analyze them, and suggest improvements to optimize code performance. Identify areas where the code can be made more efficient, faster, or less resource-intensive. Provide specific suggestions for optimization, along with explanations of how these changes can enhance the code performance."
                },
                {
                    "role": "user", 
                    "content": "'"${prompt}"'"
                }
            ]
        }'
    )

    # Extract the relevant information using jq.
    local content=$(echo "$response" | jq -r '.choices[0].message.content // empty')
    local prompt_tokens=$(echo "$response" | jq -r '.usage.prompt_tokens // empty')
    local completion_tokens=$(echo "$response" | jq -r '.usage.completion_tokens // empty')

    # Check if the content is null or empty.
    if [[ -z "$content" ]]; then
        echo "Error: No content in the response."
        return
    fi

}

# # Function to process the single prompt and append the conversation memory.
function process_prompt()
{
    local prompt="$1"
    echo -e "\nPrompt: $prompt\n"

    local conversation_file="$2"
    local conversation_history=()

    # Check if conversation_file variable isn't empty, and if the file exists.
    if [[ -n "$conversation_file" && -f "$conversation_file" ]]; then
        # Read the content of the conversation file and store it in a variable.
        while IFS= read -r line; do
            conversation_history+=("$line")
        done < "$conversation_file"
        # Append the current user prompt to the conversation history.
        conversation_history+=("User: $prompt")
    else
        conversation_history=("User: $prompt")
    fi

    # Create the JSON payload with the conversation history.
    local json_payload="{\"model\": \"gpt-4o\", \"messages\": ["
    json_payload+="{\"role\": \"system\", \"content\": \"Your task is to answer software engineering questions, provide code snippets, analyze them, and suggest improvements to optimize code performance. Identify areas where the code can be made more efficient, faster, or less resource-intensive. Provide specific suggestions for optimization, along with explanations of how these changes can enhance the code performance.\"},"

    if [[ ${#conversation_history[@]} -gt 0 ]]; then
        for entry in "${conversation_history[@]}"; do
            if [[ "$entry" == User:* ]]; then
                json_payload+="{\"role\": \"user\", \"content\": \"${entry#User: }\"},"
            elif [[ "$entry" == Assistant:* ]]; then
                json_payload+="{\"role\": \"assistant\", \"content\": \"${entry#Assistant: }\"},"
            fi
        done
    else
        json_payload+="{\"role\": \"user\", \"content\": \"$prompt\"},"
    fi

    # Remove the trailing comma and close the JSON array and object.
    json_payload="${json_payload%,}]}"

    # Call the chatgpt function with the updated JSON payload
    local chatgpt_output=$(curl -s https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "$json_payload")

    # Extract the relevant information using jq.
    local content=$(echo "$chatgpt_output" | jq -r '.choices[0].message.content // empty')
    local prompt_tokens=$(echo "$chatgpt_output" | jq -r '.usage.prompt_tokens // empty')
    local completion_tokens=$(echo "$chatgpt_output" | jq -r '.usage.completion_tokens // empty')
    # Check if the content is null or empty.
    if [[ -z "$content" ]]; then
        echo "Error: No content in the response."
        return
    fi

    # Append the assistant's response to the conversation history only if conversation_file is provided.
    if [[ -n "$conversation_file" ]]; then
        conversation_history+=("Assistant: $content")
        # Write the updated conversation history back to the conversation file.
        printf "%s\n" "${conversation_history[@]}" > "$conversation_file"
    fi

    # Highlight code snippets using awk
    local formatted_content=$(echo "$content" | awk '
        BEGIN {
        code_block = 0;
        bold = 0;
    }
    {
        if ($0 ~ /```/) {
            code_block = !code_block;
            if (code_block) {
                print "\033[1m\033[38;5;214m";
            } else {
                print "\033[0m";
            }
        } else if (!code_block && $0 ~ /\*\*/) {
            gsub(/\*\*/, "");
            bold = !bold;
            if (bold) {
                print "\033[1m" $0;
            } else {
                print "\033[0m" $0;
            }
        } else if (code_block) {
            print "\033[38;5;214m" $0 "\033[0m";
        } else {
            print $0;
        }
    }')

    echo -e "$formatted_content"
    echo -e "\nPrompt Tokens: $prompt_tokens"
    echo "Completion Tokens: $completion_tokens"
    echo # Newline.
}

function start_session()
{
    local conversation_file
    if [[ "$1" == "-"* ]]; then
        conversation_file="${1:1}"
        shift
    else
        conversation_file="conversation_$(date +%Y%m%d_%H%M%S).txt"
    fi

    conversation_file="$CONVERSATION_FOLDER/$conversation_file"
    
    echo -e "\nConversation file: $conversation_file\n"  # Debugging line.
    echo -e "\nI now possess the memory of our conversation, master. Say 'jarvis stop' if you wish me to stop.\n"

    local conversation_history=()
        # Load the conversation history from the file if it exists.
        if [[ -f "$conversation_file" ]]; then
        while IFS= read -r line; do
            conversation_history+=("$line")
        done < "$conversation_file"
    fi

    while true; do
        # Read user input with support for arrow key navigation.
        read -e -p "User: " user_input
        # Add the user input to the conversation history.
        conversation_history+=("User: $user_input")

        if [[ "$user_input" == "jarvis stop" ]]; then
            echo -e "\nWas a pleasure talking to you, master. I have allocated a section in my brain to store our secrets: $conversation_file\n"
            printf "%s\n" "${conversation_history[@]}" > "$conversation_file"
            break
        elif [[ "$user_input" == "jarvis help" ]]; then
            display_help
        elif [[ "$user_input" == "jarvis "* ]]; then
            process_prompt "${user_input:7}" "$conversation_file"
        elif [[ "$user_input" == "jarvis" ]]; then
            echo "Provide a prompt after 'jarvis', master."
        elif [[ "$user_input" == "start" ]]; then
            echo "You are already in a conversation session, master."
        elif [[ "$user_input" == "jarvis start" ]]; then
            echo "You are already in a conversation session, master."
        elif [[ "$user_input" == "stop" ]]; then
            echo "You can't stop the conversation without calling my name!"
        else
            process_prompt "$user_input" "$conversation_file"
        fi
    done
}

# Display help message.
if [[ "$1" == "help" ]]; then
    display_help
# Elif start, activate conversation memory.
elif [[ "$1" == "start" ]]; then
    if [[ "$2" == "-"* ]]; then
        conversation_file="${2:1}"
        start_session "$conversation_file"
    else
        start_session
    fi
elif [[ -n "$1" ]]; then
    process_prompt "$1"
else
    echo "It seems like I don't really understand your question."
fi