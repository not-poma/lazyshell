# GPT ZSH completion script

todo screeenshot

### Query examples:

```
Unpack download.tar.gz

Start nginx server in a docker container
    Mount current directory

Speed up the video 2x using ffmpeg
    Remove audio track
```

# Installation

Get OpenAI API key from [OpenAI dashboard](https://beta.openai.com/account/api-keys).

```shell
# install prerequisites
brew install curl jq

# Download the script
curl -o ~/.gpt.zsh https://raw.githubusercontent.com/not-poma/gpt-zsh/master/completion.zsh

# Add the following lines to your .zshrc
OPENAI_API_KEY=<your_api_key>
source ~/.gpt.zsh
```

You can invoke the completion with ALT+G hotkey.

# Contribution

This script is a crude hack, so any help is appreciated, especially if you can write zsh completion scripts. Feel free to open an issue or a pull request.

Inspired by https://github.com/TheR1D/shell_gpt

# TODO

- [ ] support for other shells
- [ ] support keyboard interrupts
- [ ] token streaming
- [ ] allow query editing while the previous one is in progress
- [ ] make some kind of preview before replacing the buffer
- [ ] better json escaping
- [ ] better error handling
- [ ] query history
- [ ] create brew package

# Description

The tool uses your current command line content (if any) as a base for your query, so you can issue modification requests for it. The tool will then replace the current command line with the result of the query.