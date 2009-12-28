module Hugo
  module Base
    def find_or_create(options)
      find(options[:name]) || new(options).create
    end
  end
end
