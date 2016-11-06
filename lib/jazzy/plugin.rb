module Danger
  # This is a danger plugin to check for undocumented symbols via Jazzy.
  #
  # @example Warn about undocumented symbols.
  #
  #          jazzy.warn
  #
  # @example Write a custom message for undocumented symbols.
  #
  #          jazzy.undocumented do |file,line|
  #              message("You forgot to document this", file:file, line:line)
  #          end
  #
  # @see  fwal/danger-jazzy
  # @tags jazzy, docs, documentation
  #
  class DangerJazzy < Plugin
    DEFAULT_MESSAGE = 'Undocumented symbol.'.freeze

    # Path to the docs folder, defaults to 'docs/'.
    # @return   [String]
    attr_accessor :path_to_docs

    # Warns about undocumented symbols.
    def warn_of_undocumented
      undocumented do |file, line|
        warn DEFAULT_MESSAGE, file: file, line: line
      end
    end

    # Finds and yields information about undocumented symbols.
    # @yieldparam [String] name of the file
    # @yieldparam [String] the line where the symbol is found
    def undocumented
      file = File.read(File.join(docs_path, 'undocumented.json'))
      data = JSON.parse(file)
      working_path = Pathname.new(data['source_directory'])

      data['warnings'].each do |item|
        next unless item['warning'] == 'undocumented'

        path = Pathname.new(item['file'])
        file = path.relative_path_from(working_path).to_s
        next unless files_of_interest.include?(file)

        yield(file, item['line'])
      end
    end

    private

    def docs_path
      @path_to_docs || 'docs/'
    end

    def files_of_interest
      git.modified_files + git.added_files
    end
  end
end
