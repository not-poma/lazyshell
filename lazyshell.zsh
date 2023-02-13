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
    local prompt="Write a bash command for query: \`$REPLY\`. Answer with the command only."
  else
    local prompt="Alter bash command \`$buffer_context\` to comply with query \`$REPLY\`. Answer with the command only."
  fi

  local escaped_prompt=$(echo "$prompt" | sed 's/"/\\"/g' | sed 's/\n/\\n/g')
  local data='{"prompt":"'"$escaped_prompt"'","model":"text-davinci-003","max_tokens":256,"temperature":0}'

  # Display a spinner while the API request is running in the background
  local spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  set +m
  local response_file=$(mktemp)
  { curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $OPENAI_API_KEY" --data "$data" https://api.openai.com/v1/completions > "$response_file" } &>/dev/null &
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
  zle -R

  if [ $? -ne 0 ]; then
    echo "Error: API request failed"
    return 1
  fi

  # Read the response from file
  # Todo: avoid using temp files
  local response=$(cat "$response_file")
  rm "$response_file"

  local generated_text=$(echo -E $response | jq -r '.choices[0].text' | xargs)

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

# Bind the __lazyshell_complete function to the Alt-g hotkey
zle -N __lazyshell_complete
bindkey '\eg' __lazyshell_complete