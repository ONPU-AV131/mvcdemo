#!/usr/bin/env ruby

class MyClass < Object
    def initialize(arg, arg1)           # => new
        @arg = arg                      # => instance variable
        @arg1 = arg1
        @@number_of_instances ||= 0     # => class variable
        @@number_of_instances += 1
    end

    def arg                             # => method (getter)
        @arg
    end

    def arg=(new_arg)                   # => method (setter)
        @arg = new_arg
    end

    attr_accessor :arg                  # => generates get/set
end

instance = MyClass.new(1, 2)            # => initialize object
p instance       #=> <MyClass:0x00000000e99738 @arg=1, @arg1=2>

# IF
if true
    puts "ok"
else
    puts "everything bad"
end


# WHILE:
i = 0
while i < 10 do
    i+= 2
end
puts i






