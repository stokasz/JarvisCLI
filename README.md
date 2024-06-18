# Jarvis v0.1
Jarvis is the simple shell script to interact with ChatGPT through the command line. 

## Future plan for Jarvis v0.2

### 1. Conversation Memory
Implementing conversation memory would allow you to have more contextual interactions over multiple commands. You could store a session state that keeps track of recent exchanges.

#### Features:
- **Session Start/Stop Commands:**
  - `!start-session`
  - `!end-session`

- **Context Retention:**
Store the messages in a session buffer that ChatGPT can reference for context until the session is ended.

### 2. File Handling
Enable the CLI to read content from files and pass it to ChatGPT for processing. This can be useful for summarizing documents, analyzing code, etc.

#### Example:

!summarize -file report.txt
!code -file script.py
!debug -file errors.log

### 3. Persistent Storage
Store queries and responses in a log file for future reference. This adds an easy way to review past interactions.

#### Implementation:

chatgpt-cli --log-file=chat_history.log


### 4. Autocomplete and Suggestions
Implement an autocomplete feature that suggests commands or completes them as you type. This could use a combination of shell scripting and predefined command templates.

### 5. **System Monitoring**
- **Resource Usage Analysis**: Explain system resource usage like CPU, memory, and disk.
- **Alerting**: Notify the user about potential system issues or thresholds.

### 6. **Collaboration Tools**
- **Chat Integration**: Send CLI outputs or status updates to team collaboration tools like Telegram
- **File Sharing**: Facilitate sharing of files or command outputs directly from the CLI.
