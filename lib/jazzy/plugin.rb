module Danger
  # This is a danger plugin to check for undocumented symbols via Jazzy.
  #
  # @example Warn about undocumented symbols.
  #
  #          jazzy.warn_of_undocumented
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
    # @return  [void]
    def warn_of_undocumented
      undocumented.each do |item|
        warn DEFAULT_MESSAGE, file: item.file, line: item.line
      end
    end

    # Returns a list of undocumented symbols in the current diff.
    # @return [Array of symbol]
    def undocumented
      return unless File.exist? undocumented_path
      load_undocumented if @undocumented.nil?
      @undocumented
    end

    private

    def docs_path
      @path_to_docs || 'docs/'
    end

    def undocumented_path
      File.join(docs_path, 'undocumented.json')
    end

    def files_of_interest
      git.modified_files + git.added_files
    end

    def load_undocumented
      reader = UndocumentedReader.new(undocumented_path)
      @undocumented = reader.undocumented_symbols.select do |item|
        files_of_interest.include?(item.file)
      end
    end
  end
end
