#! /usr/bin/ruby


# Kakuro.rb (C) 2009 David J. Aronson
# Released under GPLv3 (GNU Public Licence, Version 3)
#
# module to hold kakuro puzzles, including classes:
#
# Puzzle: mainly a list of Problems (see below), plus a two-dimensional array
# of Spaces (see below)
#
# Problem: individual math problem, i.e., length and sum, plus starting coords
# within a Puzzle, and direction (using constants DOWN and ACROSS)
#
# Space: one space in a Puzzle or Problem.  Can be marked BLANK, DIGIT, or
# HEADER.  BLANK is an unused space in the grid.  DIGIT is one where the user
# is supposed to fill in a digit, and has pointers to its DOWN and ACROSS
# Problems.  HEADER is where the sum for a Problem is printed; each HEADER
# Space may have an ACROSS sum, a DOWN sum, or both, but should not have
# neither.

require 'set'

module Kakuro

  AllDigits = Set.new([1,2,3,4,5,6,7,8,9])

  ACROSS = 1
  DOWN = 2

  class Problem

  protected
    @dir
    @len
    @spaces
    @sum
    @x
    @y

  public

    def initialize(x, y, dir, len, sum)
      # TODO: reject invalid values!  Throw exception?
      @dir = dir
      @len = len
      @spaces = Array.new(len)
      @sum = sum
      @x = x
      @y = y
    end

    def get_dir
      @dir
    end

    def get_len
      @len
    end

    # needed only for testing; maybe some way around it?
    def get_spaces
      @spaces
    end

    # needed only for testing; maybe some way around it?
    def get_space(i)
      @spaces[i]
    end

    def get_sum
      @sum
    end

    def get_x
      @x
    end

    def get_y
      @y
    end

    def set_space(idx, space)
      @spaces[idx] = space
    end

    def to_kdl
      [ '%2d' % @x, \
        '%2d' % @y, \
        '%s' % @dir == DOWN ? '|' : '-', \
        '%d' % @len, \
        '%2d' % @sum ]\
        .join ' '
    end

  end # class Problem



  class Puzzle

  protected

    @columns
    @problems
    @rows
    @spaces

  public

    def initialize(name=nil)
      @columns = 0
      @rows = 0
      @problems = []
      if name != nil
        f = File.new name, 'r'
        while not f.eof?
          line = f.readline.strip
          next if line == ''
          next if line[0,1] == '#'
          parts = line.split ' '
          # TODO MAYBE: hmmm, there MUST be a "cooler" way to do this...
          x = parts[0].to_i
          y = parts[1].to_i
          dir = parts[2] == '-' ? ACROSS : DOWN
          # TODO: reject invalid directions
          len = parts[3].to_i
          sum = parts[4].to_i
          add_problem x, y, dir, len, sum
        end
        f.close
        absorb_problems
      end
    end

    def absorb_problems
      @spaces = Array.new(@columns * @rows) { Space.new }
      @problems.each { |p|
        xInc = p.get_dir == ACROSS ? 1 : 0
        yInc = p.get_dir == DOWN ? 1 : 0
        p.get_len.times { |i|
          s = get_space(p.get_x + i * xInc, p.get_y + i * yInc)
          s.set_kind Space::DIGIT
          # TODO: there's probably a more rubyish way to do this....
          s.set_across p if xInc > 0
          s.set_down p if yInc > 0
          s.set_digits AllDigits.clone
          # TODO: make sure the one we're setting, isn't ALREADY set
          # with a different problem in this direction!
          p.set_space i, s
        }
        s = get_space(p.get_x - xInc, p.get_y - yInc)
        s.set_kind Space::HEADER
        # TODO: hmmm, there's probably a more rubyish way to do this....
        s.set_across p.get_sum if xInc > 0
        s.set_down p.get_sum if yInc > 0
        # TODO: make sure no overlap except crossing on digits
      }
    end

    def add_problem(x, y, dir, len, sum)
      # TODO: make sure args are reasonable
      # (e.g., x & y > 0, dir one or other, len>1 & <10, sum OK in len)
      high = (dir == ACROSS ? x + len : x + 1)
      @columns = high if @columns < high
      high = (dir == DOWN ? y + len : y + 1)
      @rows = high if @rows < high
      @problems.push Problem.new(x, y, dir, len, sum)
    end

    def get_columns
      @columns
    end

    def get_problem(i)
      @problems[i]
    end

    def get_problems
      @problems
    end

    def get_rows
      @rows
    end

    def get_space(x, y)
      i = y * @columns + x
      @spaces[i]
    end

    # needed only for testing; maybe some way around it?
    def get_spaces
      @spaces
    end

    def to_s(withDigits=false)
      result = ['_']
      # TODO: isn't there some way to say just x.times str?
      @columns.times { result[0] += '____' }
      @rows.times { |y|
        lines = ['|','|','|']
        @columns.times { |x|
          # remember, Space.to_s returns an ARRAY!
          spStr = get_space(x, y).to_s withDigits
          lines.size.times { |i| lines[i] += spStr[i] }
        }
        result += lines
      }
      result.join "\n"
    end

    def to_kdl
      @problems.map { |p| p.to_kdl }.join "\n"
    end

  end # class Puzzle



  class Space

  protected

      @across
      @digits
      @down
      @kind

  public

      BLANK = 1
      DIGIT = 2
      HEADER = 3

      def initialize(kind=BLANK, across=nil, down=nil)
          @across = across
          @down = down
          @kind = kind
          @digits = AllDigits.clone if kind == DIGIT
      end

      def get_across
          @across
      end

      def get_down
          @down
      end

      def get_digits
          @digits
      end

      def get_kind
          @kind
      end

      def to_s(withDigits=false)
          rep = [ '', '', '' ]
          if @kind == DIGIT
              if withDigits
                  if @digits.size == 1
                      rep[0] = ' | |'
                      rep[1] = '-' + @digits.to_a[0].to_s + '-|'
                      rep[2] = '_|_|'
                  else
                      rep[0] = '   |'
                      rep[1] = '   |'
                      rep[2] = '___|'
                      @digits.each { |digit|
                          rep[(digit-1)/3][(digit-1)%3] = digit.to_s
                      }
                  end
              else
                  rep = [ '   |', '   |', '___|' ]
              end
          elsif @kind == BLANK
              rep[0] = rep[1] = rep[2] = '***|'
          elsif @kind == HEADER
              rep[0] = '\\  |' if @across == nil
              rep[0] = '\\%2d|' % @across if @across != nil
              rep[1] = ' \\ |'
              if @down == nil
                  rep[2] = '__\\|'
              elsif @down < 10
                  rep[2] = "_%d\\|" % @down
              else
                  rep[2] = "%d\\|" % @down
              end
          end
          rep # yes, I do mean to have it return an ARRAY of strings!
      end

      def set_across(across)
          @across = across
      end

      def set_digits(digits)
          @digits = digits
      end

      def set_down(down)
          @down = down
      end

      def set_kind(kind)
          @kind = kind
      end

  end # class Space
end # module Kakuro
