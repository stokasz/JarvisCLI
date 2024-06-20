# JarvisCLI v0.2
Jarvis is a simple shell script that allows you to interact with ChatGPT through the command line. It provides a convenient way to generate responses based on prompts and engage in conversational sessions with memory capability.

### Requirements
To run the Jarvis script, you need the following:

- Bash shell (version 4.0 or later)
- cURL command-line tool
- jq command-line JSON processor
- OpenAI API key

### Installation
You can install the Jarvis script by running the following command in your terminal:

```curl -sSL https://raw.githubusercontent.com/stokasz/JarvisCLI/main/jarvis.sh -o jarvis.sh && chmod +x jarvis.sh```

### Configuration
Before using Jarvis, you need to set up your OpenAI API key in ```~/.bashrc```. 

* Obtain an API key from the OpenAI platform.
* Open shell profile.
* Add the following line to the file, replacing "YOUR_API_KEY" with your actual API key: ```export API_KEY="YOUR_API_KEY"```
* Save the file and restart your terminal or run source ~/.bashrc (or the appropriate profile file) to apply the changes.

### Usage
**Changing the Model and Personality**

By default, Jarvis uses the ```gpt-4o``` model and has a specific system prompt that enhances its coding capabilities, derived from the Antrophic prompt library. If you want to change the model or modify the assistant's personality, you can do so by editing the chatgpt function in the script.

Look for the following lines:

```bash
"model": "gpt-4o",
"temperature": "0.3",
"messages": [
    {
        "role": "system", 
        "content": "Your task is to answer software engineering questions, provide code snippets, analyze them, and suggest improvements to optimize code performance. Identify areas where the code can be made more efficient, faster, or less resource-intensive. Provide specific suggestions for optimization, along with explanations of how these changes can enhance the code performance."
    },
    ...
]
```
You can change the ```model``` parameter to use a different model and adjust the ```temperature``` parameter to control the randomness of the generated responses. Additionally, you can modify the ```content``` of the system message to alter the assistant's personality and behavior.

### Commands 
Jarvis supports the following commands:
* ```jarvis help```: Show the help message with usage instructions.
* ```jarvis "prompt"```: Generate a single response based on the provided prompt.
* ```jarvis start```: Start a conversation session with Jarvis, enabling memory of previous interactions.
* ```jarvis start -file.txt"```: Restart a previous conversation session from the specified file.
* ```jarvis stop```: Finish the current conversation session with Jarvis.

### Conversational Memory

Jarvis has the ability to remember previous interactions within a conversation session. When you start a conversation session using ```jarvis start```, Jarvis will store the conversation history in a file located in the ```$HOME/Conversations``` directory.

Each conversation session is saved in a separate file named ```conversation_YYYYMMDD_HHMMSS.txt```, where ```YYYYMMDD_HHMMSS``` represents the timestamp of when the session started.

You can restart a previous conversation session by providing the filename as an argument to ```jarvis start```, like this:

```bash
jarvis start -conversation_20230520_120000.txt
```
During a conversation session, Jarvis will append the conversation history to the API calls, allowing it to maintain context and provide more coherent responses based on the previous interactions.

### Example
Here are a few examples of how to use Jarvis:
1. Generate a single response: 
   ```bash
   jarvis "Generate Solidity code for storing a single variable"
   ```
2. Start a new conversation session:
   ```bash
   jarvis start
   ```
3. Restart a previous conversation session:
    ```bash
   jarvis start -conversation_20230520_120000.txt
   ```
4. Finish the current conversation session:
   ```bash
   jarvis stop
   ```
Feel free to explore and interact with Jarvis. Who knows, maybe he will tell you some beautiful programming truths! 
