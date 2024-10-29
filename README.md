# Pantheme

A tool for converting colorschemes between application formats.

## Demo

Converting the wonderful [neovim catppuccin theme](https://github.com/catppuccin/nvim) to zed and showing it off.

_(Note that there's already a catppuccin theme for zed. It's just complex and popular enough to be a good demo.)_

https://github.com/user-attachments/assets/9e89efae-f5df-4b31-b7b9-1df16bf46a88

## Getting started

```
Usage:
     pantheme [options]

   GENERAL OPTIONS
     --help                     shows this guide
     --from                     theme format to convert from (parse)
     --to                       theme format to convert to (emit)
     --author                   author name for emitted themes
     --name                     name of the theme to be emitted
     --output_file              path to write emitted theme. stdout if omitted
     --appearance               dark | light

   PARSER-SPECIFIC OPTIONS
     --neovim_plugin            neovim plugin containing input theme (git repo)
     --neovim_colorscheme       name of input colorscheme (via :colorscheme)
```

## Supported applications

#### Parsers
- Neovim

#### Emitters
- Zed

## Roadmap

- [ ] figure out distribution
- [ ] vscode emitter
