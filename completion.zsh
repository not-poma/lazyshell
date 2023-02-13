#!/usr/bin/env zsh

make_request() {
  if [ -z "$OPENAI_API_KEY" ]; then
    echo "Error: OPENAI_API_KEY is not set"
    echo "Get your API key from https://beta.openai.com/account/api-keys and then run:"
    echo "export OPENAI_API_KEY=<your API key>"
    exit 1
  fi

  local buffer_context="$BUFFER"

  local REPLY
  autoload -Uz read-from-minibuffer
  read-from-minibuffer '> GPT query: '
  BUFFER="$buffer_context"
  CURSOR=$#BUFFER

  # Determine the prompt based on the buffer context
  if [[ -z "$buffer_context" ]]; then
    local prompt="Write a bash command for query: \`$REPLY\`"
  else
    local prompt="Alter bash command \`$buffer_context\` to comply with query \`$REPLY\`"
  fi

  # Escape the prompt string for use in a JSON string
  local escaped_prompt=$(echo "$prompt" | sed 's/"/\\"/g' | sed 's/\n/\\n/g')

  # Generate the JSON data for the API request
  local data='{"prompt":"'"$escaped_prompt"'","model":"text-davinci-003","max_tokens":256,"temperature":0,"top_p":1}'

  # Display a spinner while the API request is in progress
  local spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  set +m
  local response_file=$(mktemp)
  { curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $OPENAI_API_KEY" --data "$data" https://api.openai.com/v1/completions > "$response_file"; } &>/dev/null &
  local pid=$!
  while kill -0 $pid 2> /dev/null; do
    for i in "${spinner[@]}"; do
      zle -R "$i GPT query: $REPLY"
      sleep 0.1
    done
  done
  zle -R

  # Check if the API request failed
  if [ $? -ne 0 ]; then
    echo "Error: API request failed"
    return 1
  fi

  local response=$(cat "$response_file")
  rm "$response_file"

  # Extract the generated text from the response
  local generated_text=$(echo -E $response | jq -r '.choices[0].text' | xargs)

  # Check if the response is valid JSON
  if [ $? -ne 0 ]; then
    echo "Error: Invalid response from API"
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

# Bind the make_request function to the Alt-g hotkey
zle -N make_request
bindkey '\eg' make_request