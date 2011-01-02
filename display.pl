% Author:
% Date: 02/01/2011

printPositions([StartPosition]) :-
    \+ is_list(StartPosition), !,
    write(StartPosition).

printPositions([StartPosition]) :-
    is_list(StartPosition),
    nth1(1,StartPosition,Item),
    write(Item).

printPositions([StartPosition | OtherStartPositions]) :-
    \+ is_list(StartPosition), !,
    write(StartPosition),write(', '),
    printPositions(OtherStartPositions).

printPositions([StartPosition | OtherStartPositions]) :-
    is_list(StartPosition),
    nth1(1,StartPosition,Item),
    write(Item),write(', '),
    printPositions(OtherStartPositions).

printCheckerBoard(CheckerBoard) :-
    printTopLine,
    printEveryLine(CheckerBoard),
    printBottomLine.

printTopLine :-
    put_char(0x2554),
    put_char(0x2550),
    put_char(0x2566),
    put_char(0x2550),
    put_char(0x2566),
    put_char(0x2550),
    put_char(0x2566),
    put_char(0x2550),
    put_char(0x2566),
    put_char(0x2550),
    put_char(0x2566),
    put_char(0x2550),
    put_char(0x2566),
    put_char(0x2550),
    put_char(0x2566),
    put_char(0x2550),
    put_char(0x2566),
    put_char(0x2550),
    put_char(0x2566),
    put_char(0x2550),
    put_char(0x2557),
    nl.

printInterLine :-
    put_char(0x2560),
    put_char(0x2550),
    put_char(0x256C),
    put_char(0x2550),
    put_char(0x256C),
    put_char(0x2550),
    put_char(0x256C),
    put_char(0x2550),
    put_char(0x256C),
    put_char(0x2550),
    put_char(0x256C),
    put_char(0x2550),
    put_char(0x256C),
    put_char(0x2550),
    put_char(0x256C),
    put_char(0x2550),
    put_char(0x256C),
    put_char(0x2550),
    put_char(0x256C),
    put_char(0x2550),
    put_char(0x2563),
    nl.

printBottomLine :-
    put_char(0x255A),
    put_char(0x2550),
    put_char(0x2569),
    put_char(0x2550),
    put_char(0x2569),
    put_char(0x2550),
    put_char(0x2569),
    put_char(0x2550),
    put_char(0x2569),
    put_char(0x2550),
    put_char(0x2569),
    put_char(0x2550),
    put_char(0x2569),
    put_char(0x2550),
    put_char(0x2569),
    put_char(0x2550),
    put_char(0x2569),
    put_char(0x2550),
    put_char(0x2569),
    put_char(0x2550),
    put_char(0x255D),
    nl.

printLine([Box|Tail]) :-
    put_char(0x2551),
    getChar(Box,Char),
    put_char(Char),
    printLine(Tail).

printLine([]) :-
    put_char(0x2551),
    nl.

printEveryLine([Line | Tail]) :-
    length([Line | Tail],Size),
    Size > 1,
    printLine(Line),
    printInterLine,
    printEveryLine(Tail).

printEveryLine([Line]) :-
    printLine(Line).

printEveryLine([]).