% Author:  Dream Team
% Date: 08/12/2010
% Rules

% Check if a '+Position' given by a '+Player' on a '+Board'
isPositionAllowed(Board,Position,Player) :-
    Player, !,
    getBoxFromGridPosition(Board,Position,Box),
    nth1(1,Box,'o').

% *extra-logic*
% Check if a '+Position' given by a '+Player' on a '+Board'
isPositionAllowed(Board,Position,Player) :-
    \+ Player, !,
    getBoxFromGridPosition(Board,Position,Box),
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

% Get the '-BottomLeftPosition' of a '+Position' for a '+Player' on a given '+Board'
% if there is one
getNeighbor(Board,Position,Player,State,BottomLeftPosition) :-
    Player,
    \+ member(Position,[1,11,21,31,41,51,61,71,81,91]),
    \+ member(Position,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,Position,_Box),
    BottomLeftPosition is Position + 9,
    getBoxFromGridPosition(Board,BottomLeftPosition,CheckNewBox),
    nth1(1,CheckNewBox,State).

% Get the '-BottomRightPosition' of a '+Position' for a '+Player' on a given '+Board'
% if there is one
getNeighbor(Board,Position,Player,State,BottomRightPosition) :-
    Player,
    \+ member(Position,[10,20,30,40,50,60,70,80,90,100]),
    \+ member(Position,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,Position,_Box),            %ensure given position  exists on this board
    BottomRightPosition is Position + 11,
    getBoxFromGridPosition(Board,BottomRightPosition,CheckNewBox), %ensure generated position exists on this board
    nth1(1,CheckNewBox,State).

% Get the '-TopRightPosition' of a '+Position' for a '+Player' on a given '+Board'
% if there is one
getNeighbor(Board,Position,Player,State,TopRightPosition) :-
    \+ Player,
    \+ member(Position,[10,20,30,40,50,60,70,80,90,100]),
    \+ member(Position,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,Position,_Box),
    TopRightPosition is Position - 9,
    getBoxFromGridPosition(Board,TopRightPosition,CheckNewBox),
    nth1(1,CheckNewBox,State).

% Get the '-TopLeftPosition' of a '+Position' for a '+Player' on a given '+Board'
% if there is one
getNeighbor(Board,Position,Player,State,TopLeftPosition) :-
    \+ Player,
    \+ member(Position,[1,11,21,31,41,51,61,71,81,91]),
    \+ member(Position,[1,2,3,4,5,6,7,8,9,10]),
    getBoxFromGridPosition(Board,Position,_Box),
    TopLeftPosition is Position - 11,
    getBoxFromGridPosition(Board,TopLeftPosition,CheckNewBox),
    nth1(1,CheckNewBox,State).

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
    
% Jump case
movePawn(Board,NewBoard,SourcePosition,MovePosition,[[MovePosition |RivalPawnsPosition] | _OtherAvailableMoves],Player) :-
    Player, !,
    setBoxStateFromGridPosition(Board,IntermediateBoard1,SourcePosition,'o',' '),
    setBoxStateFromGridPosition(IntermediateBoard1,IntermediateBoard2,MovePosition  ,' ','o'),
    moveRivalPawns(IntermediateBoard2,NewBoard,RivalPawnsPosition,Player).

movePawn(Board,NewBoard,SourcePosition,MovePosition,[[MovePosition |RivalPawnsPosition] | _OtherAvailableMoves],Player) :-
    \+ Player, !,
    setBoxStateFromGridPosition(Board,IntermediateBoard1,SourcePosition,'x',' '),
    setBoxStateFromGridPosition(IntermediateBoard1,IntermediateBoard2,MovePosition  ,' ','x'),
    moveRivalPawns(IntermediateBoard2,NewBoard,RivalPawnsPosition,Player).

movePawn(Board,NewBoard,SourcePosition,MovePosition,[_OtherStreak | OtherAvailableMoves],Player) :-
    movePawn(Board,NewBoard,SourcePosition,MovePosition,OtherAvailableMoves,Player).

% Simple case
movePawn(Board,NewBoard,SourcePosition,MovePosition,[MovePosition | _OtherMoves],Player) :-
    Player, !,
    setBoxStateFromGridPosition(Board,IntermediateBoard,SourcePosition,'o',' '),
    setBoxStateFromGridPosition(IntermediateBoard,NewBoard,MovePosition  ,' ','o').
    
movePawn(Board,NewBoard,SourcePosition,MovePosition,[MovePosition | _OtherMoves],Player) :-
    \+ Player, !,
    setBoxStateFromGridPosition(Board,IntermediateBoard,SourcePosition,'x',' '),
    setBoxStateFromGridPosition(IntermediateBoard,NewBoard,MovePosition  ,' ','x').

movePawn(Board,NewBoard,SourcePosition,MovePosition,[_MovePosition | OtherMoves],Player) :-
    movePawn(Board,NewBoard,SourcePosition,MovePosition,OtherMoves,Player).

movePawn(_Board,_NewBoard,SourcePosition,MovePosition,[],_Player) :-
    write('Your move from '),write(SourcePosition),write(' to '),write(MovePosition),write(' is not valid.'),nl,
    fail.
    
moveRivalPawns(Board,NewBoard,[PawnPosition |OtherPositions],Player) :-
    Player, !,
    setBoxStateFromGridPosition(Board,IntermediateBoard,PawnPosition,'x',' '),
    moveRivalPawns(IntermediateBoard,NewBoard,OtherPositions,Player).

moveRivalPawns(Board,NewBoard,[PawnPosition |OtherPositions],Player) :-
    \+ Player, !,
    setBoxStateFromGridPosition(Board,IntermediateBoard,PawnPosition,'o',' '),
    moveRivalPawns(IntermediateBoard,NewBoard,OtherPositions,Player).

moveRivalPawns(FinalBoard,FinalBoard,[],_Player).


