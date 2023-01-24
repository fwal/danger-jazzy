
> **Warning**
> This repository is no longer maintained.

---

## danger-jazzy
[![Build Status](https://img.shields.io/travis/fwal/danger-jazzy.svg)](https://travis-ci.org/fwal/danger-jazzy)
[![Coveralls](https://img.shields.io/coveralls/fwal/danger-jazzy.svg)](https://coveralls.io/github/fwal/danger-jazzy)
[![Gem](https://img.shields.io/gem/v/danger-jazzy.svg)](http://rubygems.org/gems/danger-jazzy)

#### Also available for Swift - check out [DangerJazzy](https://github.com/fwal/DangerJazzy) 🎉

This is a danger plugin to check for undocumented symbols via Jazzy.

<blockquote>Fail on undocumented symbols in modified files.
  <pre>
jazzy.check</pre>
</blockquote>

<blockquote>Fail on undocumented symbols in all files.
  <pre>
jazzy.check fail: :all</pre>
</blockquote>

<blockquote>Warn about undocumented symbols in modified files.
  <pre>
jazzy.check warn: :modified</pre>
</blockquote>

<blockquote>Write custom handling for undocumented symbols in modified files.
  <pre>
jazzy.undocumented.each do |item|
    message "You forgot to document this", file:item.file, line:item.line
end</pre>
</blockquote>

<blockquote>Write a custom handling for undocumented symbols in all files.
  <pre>
jazzy.undocumented(:all).each do |item|
    message "You forgot to document this", file:item.file, line:item.line
end</pre>
</blockquote>


#### Attributes

`path` - Path to the docs folder, defaults to 'docs/'.

`ignore` - List of files to ignore, defaults to [].

`message` -  Message to display, defaults to `Undocumented symbol %<symbol>s in *%<file>s*`.

`inline_message` - Message to display inline, defaults to `Undocumented symbol %<symbol>s`.


#### Methods

`check` - Checks files for modified symbols.

Takes a hash with the following keys:

 * `fail`
 * `warn`

Available scopes:

 * `modified`
 * `all`

`undocumented` - Returns a list of undocumented symbols in the current diff.

Available scopes:

 * `modified`
 * `all`
