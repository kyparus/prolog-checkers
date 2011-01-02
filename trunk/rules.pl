% Author:  Dream Team
% Date: 08/12/2010
% Rules

% Check if a '+Position' given by a '+Player' on a '+Board'
isPositionAllowed(Board,Position,Player) :-
    Player, !,
    getBoxByPosition(Board,Position,Box),
    nth1(1,Box,'o').

% *extra-logic*
% Check if a '+Position' given by a '+Player' on a '+Board'
isPositionAllowed(Board,Position,Player) :-
    \+ Player, !,
    getBoxByPosition(Board,Position,Box),
    nth1(1,Box,'x').

isPositionAllowed(_Board,Position,_Player)  :-
    write('Position '),display(Position),write(' is illegal'),nl,
    fail.

% Check if a '+Player' can still (or we can also say that he lose) by checking a '+Board'
canStillPlay(Board,Player) :-
    Player,
    existsOnBoard(Board,'o').
    
canStillPlay(Board,Player) :-
    \+ Player,
    existsOnBoard(Board,'x').

generateAllowedMove(Board,StartPosition,Player,Moves) :-
    isPositionAllowed(Board,StartPosition,Player),
    getJump(Board,StartPosition,Player,Moves),          % We MUST jump if we can
    length(Moves,JumpMoveSize),
    JumpMoveSize > 0, !.

generateAllowedMove(Board,StartPosition,Player,Moves) :-
    isPositionAllowed(Board,StartPosition,Player),
    findall(ObservedPosition,getNeighbor(Board,StartPosition,Player,' ',ObservedPosition),Moves), % Otherwise normal moves
    length(Moves,JumpMoveSize),
    JumpMoveSize > 0, !.                                                                             % Don't select a pawn who can't move
    
generateAllowedMove(Board,StartPosition,Player,_Moves) :-
    isPositionAllowed(Board,StartPosition,Player),
    write('Pawn at position '),write(StartPosition),write(' cant move'),nl,
    fail.

getStartPositions(Board,Board,Player,RefinedStartPositions) :-
    generateAllowedStartPosition(Board,Board,Player,StartPositions),
    findLongestSize(StartPositions,LongestSize),
    filterStartPositions(StartPositions,LongestSize,RefinedStartPositions).

generateAllowedStartPosition(Board,[Line | OtherLines],Player,StartPositions) :-
    generateAllowedPositionWithinLines(Board,Line,Player,LineStartPositions),
    generateAllowedStartPosition(Board,OtherLines,Player,OtherStartPositions),
    append(LineStartPositions,OtherStartPositions,StartPositions).

generateAllowedStartPosition(_Board,[],_Player,[]).

%jump detected
generateAllowedPositionWithinLines(Board,[Box | OtherBox],Player,[[StartPosition,JumpSize] | OtherStartPosition]) :-
    nth1(2,Box,StartPosition),
    isPositionAllowed(Board,StartPosition,Player),
    generateAllowedMove(Board,StartPosition,Player,Moves),
    length(Moves,MovesSize),
    MovesSize >0,
    nth1(1,Moves,FirstJump),
    is_list(FirstJump), !,
    length(FirstJump,JumpSize),
    JumpSize > 1, % Jump dectection give list with size > 1. e.g : [43,43,43]
    generateAllowedPositionWithinLines(Board,OtherBox,Player,OtherStartPosition).
    
%move detected
generateAllowedPositionWithinLines(Board,[Box | OtherBox],Player,[[ StartPosition, 1 ] | OtherStartPosition]) :-
    nth1(2,Box,StartPosition),
    isPositionAllowed(Board,StartPosition,Player),
    generateAllowedMove(Board,StartPosition,Player,Moves),
    length(Moves,MovesSize),
    MovesSize >0, !,
    generateAllowedPositionWithinLines(Board,OtherBox,Player,OtherStartPosition).

generateAllowedPositionWithinLines(Board,[_UnacceptableBox | OtherBox],Player,OtherStartPosition) :-
    generateAllowedPositionWithinLines(Board,OtherBox,Player,OtherStartPosition).
    
generateAllowedPositionWithinLines(_Board,[],_Player,[]).

checkValidPosition(ChallengerPosition,[ChallengerPosition | _OtherPosition]) :-
    !.

checkValidPosition(ChallengerPosition,[_Position | OtherPosition]) :-
    checkValidPosition(ChallengerPosition,OtherPosition).

checkValidPosition(_ChallengerPosition,[]) :-
    write('Given position is not allowed !'), nl, fail.

% Simple case
movePawn(Board,NewBoard,SourcePosition,MovePosition,[MovePosition | _OtherMoves],Player) :-
    Player,
    \+ is_list(MovePosition), !,
    setBoxStateByPosition(Board,IntermediateBoard,SourcePosition,'o',' '),
    setBoxStateByPosition(IntermediateBoard,NewBoard,MovePosition  ,' ','o').

movePawn(Board,NewBoard,SourcePosition,MovePosition,[MovePosition | _OtherMoves],Player) :-
    \+ Player,
    \+ is_list(MovePosition), !,
    setBoxStateByPosition(Board,IntermediateBoard,SourcePosition,'x',' '),
    setBoxStateByPosition(IntermediateBoard,NewBoard,MovePosition  ,' ','x').

% Jump case
movePawn(Board,NewBoard,SourcePosition,MovePosition,[ Move | _OtherAvailableMoves],Player) :-
    Player,
    is_list(Move),
    nth1(1,Move,Head),
    Head = MovePosition, !,
    setBoxStateByPosition(Board,IntermediateBoard1,SourcePosition,'o',' '),
    setBoxStateByPosition(IntermediateBoard1,IntermediateBoard2,MovePosition  ,' ','o'),
    select(Head,Move,RivalPawnsPosition),
    moveRivalPawns(IntermediateBoard2,NewBoard,RivalPawnsPosition,Player).

movePawn(Board,NewBoard,SourcePosition,MovePosition,[Move | _OtherAvailableMoves],Player) :-
    \+ Player,
    is_list(Move),
    nth1(1,Move,Head),
    Head = MovePosition,  !,
    setBoxStateByPosition(Board,IntermediateBoard1,SourcePosition,'x',' '),
    setBoxStateByPosition(IntermediateBoard1,IntermediateBoard2,MovePosition  ,' ','x'),
    moveRivalPawns(IntermediateBoard2,NewBoard,RivalPawnsPosition,Player),
    select(Head,Move,RivalPawnsPosition),
    moveRivalPawns(IntermediateBoard2,NewBoard,RivalPawnsPosition,Player).

movePawn(Board,NewBoard,SourcePosition,MovePosition,[_MovePosition | OtherMoves],Player) :-
    movePawn(Board,NewBoard,SourcePosition,MovePosition,OtherMoves,Player), !.

movePawn(_Board,_NewBoard,_SourcePosition,_MovePosition,[],_Player) :-
    write('Move position is not allowed !'), nl, fail.


