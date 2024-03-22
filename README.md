# ror.nvim
Make Ruby on Rails development experience FUN!

YouTube demo [video](https://www.youtube.com/watch?v=uPyklWpVjFI).

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
2. [dressing.nvim](https://github.com/stevearc/dressing.nvim)
   - I am using this plugin which make vim.ui.select to use telescope and also vim.ui.input to be a
       floating window asking for input as shown in my demo.
   - The config I am using for dressing.nvim

```lua
require("dressing").setup({
  input = {
    min_width = { 60, 0.9 },
  },
  select = {
    -- telescope = require('telescope.themes').get_ivy({...})
    telescope = require('telescope.themes').get_dropdown({ layout_config = { height = 15, width = 90 } }), }
})
```

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

-- Set a keybind
-- This "list_commands()" will show a list of all the available commands to run
vim.keymap.set("n", "<Leader>rc", ":lua require('ror.commands').list_commands()<CR>", { silent = true })
```

## LunarVim
```lua
-- Set a keybind
lvim.builtin.which_key.mappings["r"] = {
    name = "Ruby on Rails",
    c = { "<cmd>lua require('ror.commands').list_commands()<cr>", "RoR Menu" },
}
```

## LazyVim
```lua
-- lua/config/setup_ror.lua
require("dressing").setup({
  input = {
    min_width = { 60, 0.9 },
  },
  select = {
    -- telescope = require('telescope.themes').get_ivy({...})
    telescope = require('telescope.themes').get_dropdown({ layout_config = { height = 15, width = 90 } }), }
})

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

-- lua/plugins/ror.lua
return {
  { 'stevearc/dressing.nvim', opts = {}, },
  { 
    'weizheheng/ror.nvim',
    keys = {
      { "<leader>r", "<cmd>lua require('ror.commands').list_commands()<cr>", desc = "Ruby on Rails" },
    }
  },
}
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

https://user-images.githubusercontent.com/40255418/216002768-e3ecc59f-76a2-4a86-b0f3-94abfdb4d1b4.mp4

### 5. CLI helpers
There are a few commands that Rails developers will run daily while developing, instead of
switching to your console, just run it in Neovim!

Supported commands:
- bundle update
- bundle install
- rails db:migrate
- rails db:migrate:status
- rails db:rollback STEP=1

https://user-images.githubusercontent.com/40255418/216003425-c16004fb-c7e4-47c0-9716-d460ac9a34b3.mp4

### 6. Navigation helpers
Rails follows the Model, View, Controller (MVC) pattern, navigations helper provide a way to easily
jump to the associated models, views, and controllers easily. Of course, you can quickly jump to
the test files too!

https://user-images.githubusercontent.com/40255418/216009258-8bd6c232-bb22-4953-89e2-28b2cc4bedf1.mp4

### 7. Routes helpers
When working in a big project, it's very hard to remember all the routes. Rails does provide a CLI
method like `rails routes` to list all the routes but that command is SLOwwwww. ROR routes helpers
provide a better experience to look through all the routes in your project.

https://user-images.githubusercontent.com/40255418/216012430-f6a14937-cd69-411c-a56d-0d90d109c98a.mp4

### 8. Schema helpers
I bet there are times you don't remember what columns does an ActiveRecord model has? And you have
to go to schema.rb and look through them? ror.nvim is here to help!

https://user-images.githubusercontent.com/40255418/216013411-53cc355f-d036-487d-9f52-6d2ae19d362d.mp4

### 9. Snippets + [ror-lsp](https://github.com/weizheheng/ror-lsp) (EXPERIMENTAL)

I have been a Rails developer for 3 years now, and sometimes I still don't remember a lot of the
built-in methods. There are active developments on adding types to Ruby code with tools like
[Sorbet](https://sorbet.org/) and Ruby's built-in [rbs](https://github.com/ruby/rbs) which when
pair with [steep](https://github.com/soutaro/steep) might give a very good developmet experience
with all language server features.

I came across [Aaron Patterson](https://github.com/tenderlove)'s [YouTube video](https://www.youtube.com/watch?v=9fJntxnH4wY) on creating a language server and also Shopify's [ror-lsp](https://github.com/Shopify/ruby-lsp) GitHub repo and decided to create my own ror-lsp.

https://user-images.githubusercontent.com/40255418/216020106-5191001c-e7ad-4507-81fb-e61a31cbf6ae.mp4

#### Prerequisite
- Snippets is tested to be working with [Luasnip](https://github.com/L3MON4D3/LuaSnip)
- This should work with other snippets plugin if they support loading Vscode-like snippets

#### Usage
```lua
-- With luasnip installed, you will need to add this line to your config
require("luasnip.loaders.from_vscode").lazy_load()
```
