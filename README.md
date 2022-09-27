# ror.nvim
Make Ruby on Rails development experience FUN!

## Installation
```vim
Plug 'weizheheng/ror.nvim'
```

## Usage
```lua
-- The default settings
require("ror").setup({
  minitest = {
    message = {
      file = "Running all the tests...",
      -- This will be follow by a space, current cursor line number and ...
      -- E.g. Running test on line 10...
      line = "Running test on line"
    },
    pass_icon = "✅",
    fail_icon = "❌"
  }
})
```

## Features

### 1. Snippets

I have been a Rails developer for 3 years now, and sometimes I still don't remember a lot of the
built-in methods. There are active developments on adding types to Ruby code with tools like
[Sorbet](https://sorbet.org/) and Ruby's built-in [rbs](https://github.com/ruby/rbs) which when
pair with [steep](https://github.com/soutaro/steep) might give a very good developmet experience
with all language server features. I am excited to put my hands on those tools, but for now, here
are a list of snippets that might be useful for you while building a Rails app.

Example:
- Simple definition
- Link to the documentation (Tired of Googling them everytime)

<img width="939" alt="image" src="https://user-images.githubusercontent.com/40255418/192268415-e3920857-e6e5-435d-aff9-81db6e695922.png">

#### Prerequisite
- Snippets is tested to be working with [Luasnip](https://github.com/L3MON4D3/LuaSnip)
- This should work with other snippets plugin if they support loading Vscode-like snippets

#### Usage
```lua
-- With luasnip installed, you will need to add this line to your config
require("luasnip.loaders.from_vscode").lazy_load()
```


### 2. Minitest integration
**Watch the [DEMO VIDEO](https://share.cleanshot.com/kjXYPU)**

Recently, I started enjoying writing tests, and want to learn to write better tests. Then I came
across this [video](https://www.youtube.com/watch?v=cf72gMBrsI0) by [TJ DeVries](https://github.com/tjdevries)
and I can't stop thinking about having this in my workflow. So I decided to give it a try and
create a [minitest-json-reporter gem](https://rubygems.org/gems/minitest-json-reporter) so that I
can control the shape of the response and then use it here to integrate with the Neovim ecosystem.

#### Prerequisite
You will need to install the [minitest-json-reporter](https://rubygems.org/gems/minitest-json-reporter)
to your Ruby on Rails project:

```ruby
group :test do
  gem "minitest-json-reporter"
end
```

#### Usage
```lua
-- Set a keybind to the below commands, some example:
vim.keymap.set("n", "<Leader>ml", ":lua require('ror.minitest').run()<CR>")
vim.keymap.set("n", "<Leader>mf", ":lua require('ror.minitest').run('Line')<CR>")
vim.keymap.set("n", "<Leader>mc", ":lua require('ror.minitest').clear()<CR>")

-- Or call the command directly
:RorMinitestRun -- run the whole test file
:RorMinitestRun Line -- run test on the current cursor position
:RorMinitestClear -- clear diagnostics and extmark
```
