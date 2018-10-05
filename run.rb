require 'minruby'
require 'colorize'
require 'pp'
require 'stringio'

MY_PROGRAM = 'interp.rb interp.rb interp.rb'

Dir.glob('test*.rb').sort.each do |f|
  correct = `ruby -I. -rfizzbuzz #{f}`
  answer = `ruby #{MY_PROGRAM} #{f}`

  print "#{f} => "
  if correct == answer
    puts "OK!".green
  else
    puts "NG".red

    out = StringIO.new
    PP.pp(minruby_parse(File.read(f)), out)
    out.rewind
    puts out.read.yellow

    exit(1)
  end
end
