module Danger
  # Reads undocumented.json file created by jazzy
  class UndocumentedReader
    def initialize(path)
      load(path)
    end

    def undocumented_symbols
      @data['warnings'].each do |item|
        next unless item_valid? item
        yield(item_file(item), item['line']) if block_given?
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
