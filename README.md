# ror.nvim
Make Ruby on Rails development experience FUN!

## Installation
```vim
Plug 'weizheheng/ror.nvim'
```

## Dependencies
1. [telescope](https://github.com/nvim-telescope/telescope.nvim)

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

### 1. Test Helpers
Writing test in Rails is fun, but ror.nvim is bringing it to the next level with features like:
- Easily run all the tests in the file
- Easily run only a single test in the file
- Test results are shown in the file itself
- Show coverage percentage and also which lines are covered or not covered (with simplecov)
- Popup window for debugging purpose when you put a debugger in your test.

https://user-images.githubusercontent.com/40255418/215996583-544207d4-1979-4bd4-b069-bf46e7b7e52d.mp4

#### Prerequisite
**If you are using minitest, you will need to install the [minitest-json-reporter](https://rubygems.org/gems/minitest-json-reporter)
to your Ruby on Rails project**:

```ruby
group :test do
  gem "minitest-json-reporter"
end
```

### 2. Finders
I love Telescope, but sometimes there are just too much noise. ROR finders allow you to quickly
look for files in:
1. Models and model tests
2. Controllers and controller tests
3. Views
4. Migrations and more

https://user-images.githubusercontent.com/40255418/215999170-77882a9b-f377-42f7-9d03-b8c606f3ea22.mp4

### 3. Generators helpers
Rails provide a lot of generator methods, but one just couldn't remember them all!

Supported generators:
- Model
- Mailer
- Migration (add_column, remove_column, add_index)
- Controller
- System test

https://user-images.githubusercontent.com/40255418/216001892-9e777443-f6ba-4533-945a-90c51f5e770a.mp4

### 4. Destroyer helpers
Each Rails generators have a destroyer too!

### 5. CLI helpers
There are a few commands that Rails developers will run daily while developing, instead of
switching to your console, just run it in Neovim!

### 6. Navigation helpers
Rails follows the Model, View, Controller (MVC) pattern, navigations helper provide a way to easily
jump to the associated models, views, and controllers easily. Of course, you can quickly jump to
the test files too!

### 7. Routes helpers
When working in a big project, it's very hard to remember all the routes. Rails does provide a CLI
method like `rails routes` to list all the routes but that command is SLOwwwww. ROR routes helpers
provide a better experience to look through all the routes in your project.

### 8. Schema helpers
I bet there are times you don't remember what columns does an ActiveRecord model has? And you have
to go to schema.rb and look through them? Schema helpers is here to help!

### 9. Snippets

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
