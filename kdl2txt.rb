#! /usr/bin/ruby

require 'Kakuro'

def giveUsage
    puts "Usage: kdl_to_ascii kdlfile ..."
    exit
end

giveUsage if ARGV.length == 0
ARGV.each { |a| puts Kakuro::Puzzle.fromFile(a).to_s }
