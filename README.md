# ror.nvim
Make Ruby on Rails development experience FUN!

## Installation
```vim
Plug 'weizheheng/ror.nvim'
```

## Optional Dependencies

1. [nvim-notify](https://github.com/rcarriga/nvim-notify) (RECOMMENDED)
   - With nvim-notify installed you can get beautiful notification on when the test is running and
       also display the result of the run when it's done.
   - Otherwise, the notification will be shown in the command line through vim.notify.

## Usage
```lua
-- The default settings
require("ror").setup({
  test = {
    message = {
      -- These are the default title for nvim-notify
      file = "Running test file...",
      line = "Running single test..."
    },
    coverage = {
      -- To customize replace with the hex color you want for the highlight
      -- guibg=#354a39
      up = "DiffAdd",
      -- guibg=#4a3536
      down = "DiffDelete",
    },
    notification = {
      -- Using timeout false will replace the progress notification window
      -- Otherwise, the progress and the result will be a different notification window
      timeout = false
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


### 2. Running Tests

**Watch the [DEMO VIDEO](https://youtu.be/NmA0ADMWaW0)**

This is now supporting both [minitest](https://github.com/minitest/minitest) and [rspec-rails](https://github.com/rspec/rspec-rails).

Running test with ror.nvim provides:
1. Quick feedback loop on showing you the result of the test in the test file.
  <img width="1267" alt="quick feedback loop" src="https://user-images.githubusercontent.com/40255418/202112014-3a5a0163-ea95-4b42-a071-50545a261da1.png">

2. A floating terminal window you can attached to when running the test with a debugger.
  ![attached terminal](https://user-images.githubusercontent.com/40255418/193445643-f91d7622-bcca-424a-867e-8998503581d0.png)

3. If you have [simplecov](https://github.com/simplecov-ruby/simplecov) setup for your project.
   ror.nvim will show you the coverage after running the test. You can also see which lines are not
   covered in the original file. **PS: You will need to add in the SimpleCov::Formatter::JSONFormatter**

#### Prerequisite
**If you are using minitest, you will need to install the [minitest-json-reporter](https://rubygems.org/gems/minitest-json-reporter)
to your Ruby on Rails project**:

```ruby
group :test do
  gem "minitest-json-reporter"
end
```

#### Usage
```lua
-- Set a keybind to the below commands, some example:
vim.keymap.set("n", "<Leader>tf", ":lua require('ror.test').run()<CR>")
vim.keymap.set("n", "<Leader>tl", ":lua require('ror.test').run('Line')<CR>")
vim.keymap.set("n", "<Leader>tl", ":lua require('ror.test').run('OnlyFailures')<CR>")
vim.keymap.set("n", "<Leader>tl", ":lua require('ror.test').run('Last')<CR>")
vim.keymap.set("n", "<Leader>tc", ":lua require('ror.test').clear()<CR>")
vim.keymap.set("n", "<Leader>ta", ":lua require('ror.test').attach_terminal()<CR>")
vim.keymap.set("n", "<Leader>cs", ":lua require('ror.coverage').show()<CR>")
vim.keymap.set("n", "<Leader>ch", ":lua require('ror.coverage').clear()<CR>")

-- Or call the command directly
:RorTestRun -- run the whole test file
:RorTestRun Line -- run test on the current cursor position
:RorTestClear -- clear diagnostics and extmark
:RorTestAttachTerminal -- attach the terminal (useful when running test with debugger)
:RorShowCoverage -- attach the terminal (useful when running test with debugger)
:RorClearCoverage -- attach the terminal (useful when running test with debugger)
```
