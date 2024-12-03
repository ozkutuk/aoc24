USING: kernel splitting math math.parser sequences assocs
io.encodings.utf8 io.files sorting prettyprint command-line
namespaces ;
IN: aoc24.day1

: read-input ( file -- lineseq )
    utf8 file-lines ;

: parse-lists ( lineseq -- list1 list2 )
    [ "   " split-subseq [ string>number ] map ] map unzip ;

: count-element ( x seq -- n )
    swap [ = ] curry count ;

: part1 ( list1 list2 -- n )
    [ sort ] bi@ [ - abs ] 2map sum ;

: part2 ( list1 list2 -- n )
    [ count-element ] curry dupd map [ * ] 2map sum ;

: solve ( file -- )
    read-input parse-lists [ part1 ]  [ part2 ] 2bi [ . ] bi@ ;

: main ( -- )
    command-line get first solve ;

MAIN: main
