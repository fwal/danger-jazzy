module Danger
  # This is a danger plugin to check for undocumented symbols via Jazzy.
  #
  # @example Fail on undocumented symbols in modified files.
  #
  #          jazzy.check
  #
  # @example Fail on undocumented symbols in all files.
  #
  #          jazzy.check fail: :all
  #
  # @example Warn about undocumented symbols in modified files.
  #
  #          jazzy.check warn: :modified
  #
  # @example Write a custom message for undocumented symbols in modified files.
  #
  #          jazzy.undocumented.each do |item|
  #              message "You forgot to document this", file:item.file, line:item.line
  #          end
  #
  # @example Write a custom message for undocumented symbols in all files.
  #
  #          jazzy.undocumented(:all).each do |item|
  #              message "You forgot to document this", file:item.file, line:item.line
  #          end
  #
  # @see  fwal/danger-jazzy
  # @tags jazzy, docs, documentation
  #
  class DangerJazzy < Plugin
    DEFAULT_MESSAGE = 'Undocumented symbol.'.freeze

    # Path to the docs folder, defaults to 'docs/'.
    # @return   [String]
    attr_accessor :path

    # Checks files for modified symbols.
    #
    # Takes a hash with the following keys:
    #
    #  * `fail`
    #  * `warn`
    #
    # Available scopes:
    #
    #  * `modified`
    #  * `all`
    #
    # @param [Hash] config
    # @return [void]
    def check(config = {})
      @config = config
      fail_check
      warn_check
    end

    # Returns a list of undocumented symbols in the current diff.
    #
    # Available scopes:
    #
    #  * `modified`
    #  * `all`
    #
    # @param [Key] scope
    # @return [Array of symbol]
    def undocumented(scope = :modified)
      return [] unless scope != :ignore && File.exist?(undocumented_path)
      @undocumented = { :modified => [], :all => [] } if @undocumented.nil?
      load_undocumented(scope) if @undocumented[scope].empty?
      @undocumented[scope]
    end

    private

    def docs_path
      @path || 'docs/'
    end

    def undocumented_path
      File.join(docs_path, 'undocumented.json')
    end

    def files_of_interest
      git.modified_files + git.added_files
    end

    def load_undocumented(scope)
      reader = UndocumentedReader.new(undocumented_path)
      @undocumented[scope] = reader.undocumented_symbols.select do |item|
        if scope == :modified
          files_of_interest.include?(item.file)
        else
          true
        end
      end
    end

    def fail_scope
      @config[:fail] || :modified
    end

    def warn_scope
      @config[:warn] || :ignore
    end

    def fail_check
      undocumented(fail_scope).each do |item|
        fail DEFAULT_MESSAGE, file: item.file, line: item.line
      end
    end

    def warn_check
      undocumented(warn_scope).each do |item|
        warn DEFAULT_MESSAGE, file: item.file, line: item.line
      end
    end
  end
end
