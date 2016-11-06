### jazzy
This is a danger plugin to check for undocumented symbols via Jazzy.

<blockquote>Warn about undocumented symbols.
  <pre>
jazzy.warn_of_undocumented</pre>
</blockquote>

<blockquote>Write a custom message for undocumented symbols.
  <pre>
jazzy.undocumented do |file,line|
    message("You forgot to document this", file:file, line:line)
end</pre>
</blockquote>


#### Attributes

`path_to_docs` - Path to the docs folder, defaults to 'docs/'.


#### Methods

`warn_of_undocumented` - Warns about undocumented symbols.

`undocumented` - Finds and yields information about undocumented symbols.
