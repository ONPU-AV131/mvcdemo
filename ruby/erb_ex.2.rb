require "erb"

class Basicerb

  def initialize name
    @name = name
    @template = File.read('./index.erb')
  end

  def render
    ERB.new(@template).result( binding )
  end
end

puts Basicerb.new('some name').render
