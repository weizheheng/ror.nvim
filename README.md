# ror.nvim
Make Ruby on Rails development experience FUN!

## Features

### 1. Snippets

I have been a Rails developer for 3 years now, and sometimes I still don't remember a lot of the
built-in methods. There are active developments on adding types to Ruby code with tools like
[Sorbet](https://sorbet.org/) and Ruby's built-in [rbs](https://github.com/ruby/rbs) which when
pair with [steep](https://github.com/soutaro/steep) might give a very good developmet experience
with all language server features. I am excited to put my hands on those tools, but for now, here
you can find a list of snippets that might be useful for you to develop a Rails app.

### 2. Minitest reporter integration

Recently, I started enjoying writing tests, and want to learn to write better tests. Then I came
across this [video](https://www.youtube.com/watch?v=cf72gMBrsI0) by [TJ DeVries](https://github.com/tjdevries)
and I can't stop thinking about having this in my workflow. So I decided to give it a try and
create a [minitest-json-reporter gem](https://rubygems.org/gems/minitest-json-reporter) so that I
can control the shape of the response and then use it here to integrate with the Neovim ecosystem.
