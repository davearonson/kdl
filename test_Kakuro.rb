#! /usr/bin/ruby

require_relative './Kakuro'

require 'test/unit'

class TC_MyTest < Test::Unit::TestCase

    # def setup
    # end

    # def teardown
    # end


    # helpers

    def helper_inspectProblem prob, x, y, dir, len, sum
        assert_equal x, prob.get_x
        assert_equal y, prob.get_y
        assert_equal dir, prob.get_dir
        assert_equal len, prob.get_len
        assert_equal len, prob.get_spaces.size
        assert_equal sum, prob.get_sum
    end


    # NORMAL CONDITIONS

    def test_Kakuro_Problem
        p = Kakuro::Problem.new 1, 2, Kakuro::DOWN, 3, 6
        helper_inspectProblem p, 1, 2, Kakuro::DOWN, 3, 6
    end

    def test_Kakuro_Puzzle_initialize
        p = Kakuro::Puzzle.new
        assert_equal  0, p.get_columns
        assert_equal [], p.get_problems
        assert_equal  0, p.get_rows
    end

    def test_Kakuro_Puzzle_addProblem
        p = Kakuro::Puzzle.new
        p.add_problem 1, 2, Kakuro::DOWN, 3, 6
        assert_equal 1, p.get_problems.size
        assert_equal 2, p.get_columns
        assert_equal 5, p.get_rows
        p.add_problem 1, 2, Kakuro::ACROSS, 3, 6
        assert_equal 2, p.get_problems.size
        assert_equal 4, p.get_columns
        assert_equal 5, p.get_rows
        helper_inspectProblem p.get_problem(0), 1, 2, Kakuro::DOWN, 3, 6
    end

    def test_Kakuro_Puzzle_fromFile_and_to_kdl
        # put in some funky spacing to make sure it doesn't matter
        old_kdl = [ " 2  1 - 3  6", \
                    "2  2 - 3	7", \
                    " 3  3 - 2		10", \
                    " 2  1 | 2  3", \
                    " 3  1 | 3   7", \
                    " 4  1 | 3  13" \
                    ]
        fileName = "/tmp/test_Kakuro.tmp"
        f1 = File.new fileName, "w"
        f1.write old_kdl.join("\n")
        f1.close
        puzz = Kakuro::Puzzle.new fileName
        assert_equal 6, puzz.get_problems.size
        helper_inspectProblem puzz.get_problem(0), 2, 1, Kakuro::ACROSS, 3, 6
        helper_inspectProblem puzz.get_problem(1), 2, 2, Kakuro::ACROSS, 3, 7
        helper_inspectProblem puzz.get_problem(2), 3, 3, Kakuro::ACROSS, 2, 10
        helper_inspectProblem puzz.get_problem(3), 2, 1, Kakuro::DOWN, 2, 3
        helper_inspectProblem puzz.get_problem(4), 3, 1, Kakuro::DOWN, 3, 7
        helper_inspectProblem puzz.get_problem(5), 4, 1, Kakuro::DOWN, 3, 13
        puzz.get_problems.each { |prob|
            assert_not_nil prob.get_spaces
            prob.get_spaces.each { |s|
                assert_not_nil s
                assert_equal prob, \
                             prob.get_dir == Kakuro::DOWN ? s.get_down : \
                                                           s.get_across
                assert_equal Kakuro::AllDigits, s.get_digits
            }
        }
        new_kdl = puzz.to_kdl.split "\n"
        assert_equal old_kdl.size, new_kdl.size
    end

    def test_Kakuro_Puzzle_to_s
        f = File.new "/tmp/test_Kakuro.tmp", "w"
        f.write " 2  2 - 2  5\n"
        f.write " 1  3 - 3  7\n"
        f.write " 1  4 - 3 15\n"
        f.write " 1  3 | 2  7\n"
        f.write " 2  2 | 3  7\n"
        f.write " 3  2 | 3 13\n"
        f.close
        puzz = Kakuro::Puzzle.new "/tmp/test_Kakuro.tmp"
        assert_equal \
            "_________________\n"\
            "|***|***|***|***|\n"\
            "|***|***|***|***|\n"\
            "|***|***|***|***|\n"\
            "|***|***|\\  |\\  |\n"\
            "|***|***| \\ | \\ |\n"\
            "|***|***|_7\\|13\\|\n"\
            "|***|\\ 5|   |   |\n"\
            "|***| \\ |   |   |\n"\
            "|***|_7\\|___|___|\n"\
            "|\\ 7|   |   |   |\n"\
            "| \\ |   |   |   |\n"\
            "|__\\|___|___|___|\n"\
            "|\\15|   |   |   |\n"\
            "| \\ |   |   |   |\n"\
            "|__\\|___|___|___|"\
            , puzz.to_s(false)
        assert_equal \
            "_________________\n"\
            "|***|***|***|***|\n"\
            "|***|***|***|***|\n"\
            "|***|***|***|***|\n"\
            "|***|***|\\  |\\  |\n"\
            "|***|***| \\ | \\ |\n"\
            "|***|***|_7\\|13\\|\n"\
            "|***|\\ 5|123|123|\n"\
            "|***| \\ |456|456|\n"\
            "|***|_7\\|789|789|\n"\
            "|\\ 7|123|123|123|\n"\
            "| \\ |456|456|456|\n"\
            "|__\\|789|789|789|\n"\
            "|\\15|123|123|123|\n"\
            "| \\ |456|456|456|\n"\
            "|__\\|789|789|789|"\
            , puzz.to_s(true)
    end

    def test_Kakuro_Space_to_s
        s = Kakuro::Space.new
        assert_equal [ "***|",\
                       "***|",\
                       "***|" ],\
                     s.to_s
        s.set_kind Kakuro::Space::DIGIT
        assert_equal [ "   |",\
                       "   |",\
                       "___|" ],\
                     s.to_s(false)
        s.set_digits Kakuro::AllDigits.clone
        assert_equal [ "123|",\
                       "456|",\
                       "789|" ],\
                     s.to_s(true)
        s.set_digits Set.new([1,3,5,7,9])
        assert_equal [ "1 3|",\
                       " 5 |",\
                       "7_9|" ],\
                     s.to_s(true)
        s.set_kind Kakuro::Space::HEADER
        assert_equal [ "\\  |",\
                       " \\ |",\
                       "__\\|" ],\
                     s.to_s
        s.set_across 1
        assert_equal [ "\\ 1|",\
                       " \\ |",\
                       "__\\|" ],\
                     s.to_s
        s.set_across 12
        assert_equal [ "\\12|",\
                       " \\ |",\
                       "__\\|" ],\
                     s.to_s
        s.set_down 3
        assert_equal [ "\\12|",\
                       " \\ |",\
                       "_3\\|" ],\
                     s.to_s
        s.set_down 34
        assert_equal [ "\\12|",\
                       " \\ |",\
                       "34\\|" ],\
                     s.to_s
    end

    # DETECTION OF ERRORS

    # TODO: write such tests!


end
