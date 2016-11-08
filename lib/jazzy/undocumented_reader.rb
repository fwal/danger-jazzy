module Danger
  # Reads undocumented.json file created by jazzy
  class UndocumentedReader
    def initialize(path)
      load(path)
    end

    def undocumented_symbols
      @data['warnings'].map do |item|
        next unless item_valid? item
        Symbol.new(
          item_file(item),
          item['line'],
          item['symbol'],
          item['symbol_kind'],
          item['warning']
        )
      end
    end

    private

    def load(path)
      @data = JSON.parse(File.read(path))
      @working_path = Pathname.new(@data['source_directory'])
    end

    def item_file(item)
      path = Pathname.new(item['file'])
      path.relative_path_from(@working_path).to_s
    end

    def item_valid?(item)
      item['warning'] == 'undocumented'
    end
  end
end
