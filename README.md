# LazyShell

LazyShell is a GPT powered utility for Zsh that helps you write and modify console commands using natural language. Perfect for those times when you can't remember the command line arguments for `tar` and `ffmpeg`, or when you just want to save time by having AI do the heavy lifting. The tool uses your current command line content (if any) as a base for your query, so you can issue modification requests for it. Invoke the completion with ALT+G hotkey; you still have to manually press enter to execute the suggested command.

It also can use GPT to explain what the current command does. Invoke the explanation with ALT+E hotkey.

![Screenshot](https://raw.githubusercontent.com/not-poma/lazyshell/master/screenshot.gif)

LazyShell is in alpha stage and may contain bugs. Currently only Zsh is supported.

# How to use

## Completion

1. Hit ALT+G to invoke the completion. The current command line content will be used as a base for your query.
2. You can then write a natural language version of what you want to accomplish.
3. Hit enter.
4. The suggested command will be inserted into the command line.
5. Hit enter to execute it, or continue modifying it.

### Query examples for completion:

```
Unpack download.tar.gz

Start nginx server in docker
    Mount current dir

Speed up the video 2x using ffmpeg
    Remove audio track
```

## Explanation

1. Write down a command you want to understand.
2. Hit ALT+E to invoke the explanation module.
3. Hit any key to modify the command (the explanation will disappear)

# Installation

Get OpenAI API key from [OpenAI dashboard](https://platform.openai.com/account/api-keys). All new OpenAI accounts get $18 balance for testing.

```shell
# install prerequisites
brew install curl jq

# Download the script
curl -o ~/.lazyshell.zsh https://raw.githubusercontent.com/not-poma/lazyshell/master/lazyshell.zsh

# Add the following lines to your .zshrc
export OPENAI_API_KEY=<your_api_key>
[ -f ~/.lazyshell.zsh ] && source ~/.lazyshell.zsh
```

After that restart your shell. You can invoke the completion with ALT+G hotkey and explanation with ALT+E.

Note: if you're on macOS and your terminal prints `©` when you press the hotkey, it means the OS intercepts the key combination first and you need to disable this behavior.

## Alternate Key Bindings

You can change the key bindings by modifying the lines starting with `bindkey` in the script.'

Make sure it doesn't conflict with your existing key bindings. To check, run `bindkey -L` in your shell.

# Contributing

This script is a crude hack, so any help is appreciated, especially if you can write zsh completion scripts. Feel free to open an issue or a pull request.

Inspired by https://github.com/TheR1D/shell_gpt

# TODO

- [ ] support for other shells
- [ ] support keyboard interrupts
- [ ] token streaming
- [x] companion tool that explains the current command line contents
- [ ] allow query editing while the previous one is in progress
- [ ] make some kind of preview before replacing the buffer
- [ ] better json escaping
- [ ] better error handling
- [ ] query history
- [ ] create brew package
- [ ] maybe choose a better default shortcut?
