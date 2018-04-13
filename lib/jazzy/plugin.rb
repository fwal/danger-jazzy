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
    DEFAULT_MESSAGE = 'Undocumented symbol `%<symbol>s` in *%<file>s*'.freeze
    DEFAULT_INLINE_MESSAGE = 'Undocumented symbol `%<symbol>s`'.freeze

    # Path to the docs folder, defaults to 'docs/'.
    # @return   [String]
    attr_accessor :path

    # List of files to ignore, defaults to [].
    # @return   [[String]]
    attr_accessor :ignore

    # Message to display, defaults to 'Undocumented symbol `%<symbol>s` in *%<file>s*'.
    # @return   [String]
    attr_accessor :message

    # Message to display inline,
    # defaults to 'Undocumented symbol `%<symbol>s`'.
    # @return   [String]
    attr_accessor :inline_message

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
      @undocumented = { modified: [], all: [] } if @undocumented.nil?
      load_undocumented(scope) if @undocumented[scope].empty?
      @undocumented[scope]
    end

    private

    def docs_path
      @path || 'docs/'
    end

    def ignored_files
      @ignore || []
    end

    def message_template
      @message || DEFAULT_MESSAGE
    end

    def inline_message_template
      @inline_message || DEFAULT_INLINE_MESSAGE
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
        next unless !item.nil? && item.file
        next if ignored_files.include? item.file
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
        # rubocop:disable Style/SignalException, Style/GuardClause
        if item.file.nil? || item.line.nil?
          fail message_template % item.to_h
        else
          fail inline_message_template % item.to_h, file: item.file, line: item.line
        end
        # rubocop:enable Style/SignalException, Style/GuardClause
      end
    end

    def warn_check
      undocumented(warn_scope).each do |item|
        if item.file.nil? || item.line.nil?
          warn message_template % item.to_h
        else
          warn inline_message_template % item.to_h, file: item.file, line: item.line
        end
      end
    end
  end
end
