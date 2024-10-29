# Pantheme

A tool for converting colorschemes between application formats.

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
     --output_file              path where emitted theme will be written. stdout if omitted
     --appearance               dark | light

   PARSER-SPECIFIC OPTIONS
     --neovim_plugin            neovim plugin containing the theme to be parsed (usually a git repo)
     --neovim_colorscheme       name of the vim colorscheme to be loaded (via :colorscheme)
```

## Supported applications

#### Parsers
- Neovim

#### Emitters
- Zed

## Roadmap

- [ ] figure out distribution
- [ ] vscode emitter
