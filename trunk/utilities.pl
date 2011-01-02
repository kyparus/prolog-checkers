% Author:
% Date: 02/01/2011

moveRivalPawns(Board,NewBoard,[PawnPosition |OtherPositions],Player) :-
    Player, !,
    setBoxStateByPosition(Board,IntermediateBoard,PawnPosition,'x',' '),
    moveRivalPawns(IntermediateBoard,NewBoard,OtherPositions,Player).

moveRivalPawns(Board,NewBoard,[PawnPosition |OtherPositions],Player) :-
    \+ Player, !,
    setBoxStateByPosition(Board,IntermediateBoard,PawnPosition,'o',' '),
    moveRivalPawns(IntermediateBoard,NewBoard,OtherPositions,Player).

moveRivalPawns(FinalBoard,FinalBoard,[],_Player).

findLongestSize(Positions,LongestSize) :-
    exploreSizes(Positions,0,LongestSize).

exploreSizes([[_Position, Size] | OtherPositions],CurrentMax,NewMax) :-
    Size > CurrentMax,
    NewCurrentMax is Size,
    exploreSizes(OtherPositions,NewCurrentMax,NewMax).

exploreSizes([ _WeakPosition | OtherPositions],CurrentMax,NewMax) :-
    exploreSizes(OtherPositions,CurrentMax,NewMax).

exploreSizes([],Max,Max).

filterStartPositions([ [Position,Size] |OtherPositions],LongestSize,[ Position | Tail ]) :-
    Size >= LongestSize,
    filterStartPositions(OtherPositions,LongestSize,Tail).

filterStartPositions([ _WeakPosition |OtherPositions],LongestSize,Tail) :-
    filterStartPositions(OtherPositions,LongestSize,Tail).

filterStartPositions([],_Size,[]).