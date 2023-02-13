# LazyShell

LazyShell is a GPT-3 powered utility for Zsh that helps you write and modify console commands using natural language. Perfect for those times when you can't remember the command line arguments for `tar`, or when you just want to save time by having AI do the heavy lifting. The tool uses your current command line content (if any) as a base for your query, so you can issue modification requests for it. Invoke the completion with ALT+G hotkey; you still have to manually press enter to execute the suggested command.

<img src="https://raw.githubusercontent.com/not-poma/lazyshell/master/screenshot.gif">

LazyShell is currently in alpha stage and may have bugs

### Query examples:

```
Unpack download.tar.gz

Start nginx server in docker
    Mount current dir

Speed up the video 2x using ffmpeg
    Remove audio track
```

# Installation

Get OpenAI API key from [OpenAI dashboard](https://beta.openai.com/account/api-keys).

```shell
# install prerequisites
brew install curl jq

# Download the script
curl -o ~/.lazyshell.zsh https://raw.githubusercontent.com/not-poma/lazyshell/master/lazyshell.zsh

# Add the following lines to your .zshrc
OPENAI_API_KEY=<your_api_key>
source ~/.lazyshell.zsh
```

You can invoke the completion with ALT+G hotkey.

# Contributing

This script is a crude hack, so any help is appreciated, especially if you can write zsh completion scripts. Feel free to open an issue or a pull request.

Inspired by https://github.com/TheR1D/shell_gpt

# TODO

- [ ] support for other shells
- [ ] support keyboard interrupts
- [ ] token streaming
- [ ] companion tool that explains the current command line contents
- [ ] allow query editing while the previous one is in progress
- [ ] make some kind of preview before replacing the buffer
- [ ] better json escaping
- [ ] better error handling
- [ ] query history
- [ ] create brew package
- [ ] maybe choose a better default shortcut?
