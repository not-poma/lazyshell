#!/usr/bin/env zsh

__lazyshell_complete() {
  if [ -z "$OPENAI_API_KEY" ]; then
    echo ""
    echo "Error: OPENAI_API_KEY is not set"
    echo "Get your API key from https://beta.openai.com/account/api-keys and then run:"
    echo "export OPENAI_API_KEY=<your API key>"
    zle reset-prompt
    return 1
  fi

  local buffer_context="$BUFFER"

  # Read user input
  # Todo: use zle to read input
  local REPLY
  autoload -Uz read-from-minibuffer
  read-from-minibuffer '> GPT query: '
  BUFFER="$buffer_context"
  CURSOR=$#BUFFER

  if [[ -z "$buffer_context" ]]; then
    local prompt="Write a zsh command for query: \`$REPLY\`. Answer with a single command only, without any additional characters so it can be pasted into the terminal."
  else
    local prompt="Alter zsh command \`$buffer_context\` to comply with query \`$REPLY\`. Answer with a single command only, without any additional characters so it can be pasted into the terminal."
  fi

  # todo: better escaping
  local escaped_prompt=$(echo "$prompt" | sed 's/"/\\"/g' | sed 's/\n/\\n/g')
  local data='{"messages":[{"role": "system","content":"You are the world leading expert on zsh shell commands for a computer running on Ubuntu 22.04.2 LTS. Always make the best guess if you do not have enough information. "},{"role":"user","content":"'"$escaped_prompt"'"}],"model":"gpt-3.5-turbo","max_tokens":256,"temperature":0.7}'  

  # Display a spinner while the API request is running in the background
  local spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  set +m
  local response_file=$(mktemp)
  { curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $OPENAI_API_KEY" -d "$data" https://api.openai.com/v1/chat/completions > "$response_file" } &>/dev/null &
  local pid=$!
  while true; do
    for i in "${spinner[@]}"; do
      if ! kill -0 $pid 2> /dev/null; then
        break 2
      fi
      zle -R "$i GPT query: $REPLY"
      sleep 0.1
    done
  done

  wait $pid
  if [ $? -ne 0 ]; then
    # todo displayed error is erased immediately, find a better way to display it
    zle -R "Error: API request failed"
    return 1
  fi

  # Read the response from file
  # Todo: avoid using temp files
  local response=$(cat "$response_file")
  rm "$response_file"

  local generated_text=$(echo -E $response | jq -r '.choices[0].message.content' | xargs -0)
  local error=$(echo -E $response | jq -r '.error.message')

  if [ $? -ne 0 ]; then
    zle -R "Error: Invalid response from API"
    return 1
  fi

  if [[ -n "$error" && "$error" != "null" ]]; then 
    zle -R "Error: $error"
    return 1
  fi

  # Replace the current buffer with the generated text
  BUFFER="$generated_text"
  CURSOR=$#BUFFER
}

if [ -z "$OPENAI_API_KEY" ]; then
  echo "Warning: OPENAI_API_KEY is not set"
  echo "Get your API key from https://beta.openai.com/account/api-keys and then run:"
  echo "export OPENAI_API_KEY=<your API key>"
fi

# Bind the __lazyshell_complete function to the Alt-g hotkey
zle -N __lazyshell_complete
bindkey '\eg' __lazyshell_complete
