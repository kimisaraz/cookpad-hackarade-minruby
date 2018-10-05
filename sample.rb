require 'pp'
require 'minruby'

pp minruby_parse("1 + 2 * 3")
pp minruby_parse("(1 + 2) * 3")
pp minruby_parse("x = 42; y = x + 1; p(y)")
