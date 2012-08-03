This is a parser and printer for KDL.  KDL stands for Kakuro Description
Language.  (Kakuro is a type of math puzzle from Japan.)

A KDL file describes one complete Kakuro puzzle.  It consists of lines, each
one describing a sum, using the following items:

* The X coordinate (i.e., column) of the start of the digits, starting at 1 from the left side of the puzzle

* The Y coordinate (i.e., row) of the start of the digits, starting at 1 from the top of the puzzle

* Either a dash (-) or a vertical bar (|), to tell whether the sum runs across or down, respectively, so it's language-independent

* The length of the sum, i.e., the number of digits

* The number that the digits should sum to

That's it! There is no need to describe the puzzle overall; a KDL parser should
be able to figure out the total X and Y size of the puzzle.

There may be any amount of whitespace between these elements.  KDL files may
also have blank lines, and comments (which start with a # sign). For instance,
a file containing the following:

```
# This is a comment.
# The next line is blank.

# column 2, row 1, across, 2 digits, summing to 5
2 1 - 2 5

# column 1, row 2, across, 3 digits, summing to 7; get the idea now?
  1  2   -    3     7

# This is another comment

1 3 - 3 15

# All the whitespace on the line below, is tabs
1 2 | 2 7
2 1 | 3 7
3 1 | 3 13

# The lines above and below are blank... except for some whitespace.

# The End
```

would produce a rather small puzzle that looks as follows:
```
_________________
|***|***|\  |\  |
|***|***| \ | \ |
|***|***|_7\|13\|
|***|\ 5|   |   |
|***| \ |   |   |
|***|_7\|___|___|
|\ 7|   |   |   |
| \ |   |   |   |
|__\|___|___|___|
|\15|   |   |   |
| \ |   |   |   |
|__\|___|___|___|
```
and would be solved as follows:
```
_________________
|***|***|\  |\  |
|***|***| \ | \ |
|***|***|_7\|13\|
|***|\ 5|   |   |
|***| \ | 2 | 3 |
|***|_7\|___|___|
|\ 7|   |   |   |
| \ | 2 | 4 | 1 |
|__\|___|___|___|
|\15|   |   |   |
| \ | 5 | 1 | 9 |
|__\|___|___|___|
```
