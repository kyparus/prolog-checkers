% Author:
% Date: 29/12/2010
% Describe jump algorithm

getJump(Board,Position,Player,JumpPositions) :-
    findall(ObservedPosition,getJumpPosition(Board,Position,Player,ObservedPosition),FirstJumpPositions),  %first generation of "jumper" :)
    write('Jump Positions : '),write(FirstJumpPositions), nl,                                              %DEBUG
    exploreDeeperJumps(Board,Player,Position,FirstJumpPositions,AllJumpPositions),
    reverse(AllJumpPositions,AllJumpPositionsReversed),                                                    %Best jump are ALWAYS at the end
    nth1(1,AllJumpPositionsReversed,First),                                                                %select the best jump to compare with the other
    select(First,AllJumpPositionsReversed,JumpPositionsReversedTail),                                      %delete it from main list,
    selectBestMoves(JumpPositionsReversedTail,First,JumpPositions).

exploreDeeperJumps(Board,Player,FromPosition,[[ToPosition, FirstRivalPosition | RivalPositions] | OtherJumps ],FinalJumpPosition) :-
    %Determine player : 'o'
    Player,
    %Simulate a new board
    setBoxStateFromGridPosition(Board         ,BoardModified1,FromPosition      ,'o',' '),
    setBoxStateFromGridPosition(BoardModified1,BoardModified2,FirstRivalPosition,'x',' '),
    setBoxStateFromGridPosition(BoardModified2,FinalBoard    ,ToPosition        ,' ','o'),
%    write('Simulated checker board :'),nl,printCheckerBoard(FinalBoard),
    %Determine new jumps
    findall(ObservedPosition,getJumpPosition(FinalBoard,ToPosition,Player,ObservedPosition),NextGenerationJumpPositions),
    write('Jump Positions from ToPosition('),write(ToPosition),write(') : '),write(NextGenerationJumpPositions), nl, %DEBUG
    %Stop if there is no more
    length(NextGenerationJumpPositions,JumpPositionsSize),
    JumpPositionsSize > 0, !,                                                                                 %JumpSize
    saveJumpSize(NextGenerationJumpPositions,[FirstRivalPosition | RivalPositions],RefinedJumpPositions),
    write('Saved Jumps : '),write(RefinedJumpPositions), nl, %DEBUG
    %Keep Exploring !
    exploreDeeperJumps(FinalBoard,Player,ToPosition,RefinedJumpPositions,FoundPositions),
    write('Deeper Jump : '),write(FoundPositions),nl,
    exploreDeeperJumps(Board,Player,FromPosition,OtherJumps,OtherJumpPositions),
    append(FoundPositions,OtherJumpPositions,FinalJumpPosition).

exploreDeeperJumps(Board,Player,FromPosition,[[ToPosition, FirstRivalPosition | RivalPositions] | OtherJumps ],FinalJumpPosition) :-
    %Determine player : 'x'
    \+ Player,
    %Simulate a new board
    setBoxStateFromGridPosition(Board         ,BoardModified1,FromPosition      ,'x',' '),
    setBoxStateFromGridPosition(BoardModified1,BoardModified2,FirstRivalPosition,'o',' '),
    setBoxStateFromGridPosition(BoardModified2,FinalBoard    ,ToPosition        ,' ','x'),
%    write('Simulated checker board :'),nl,printCheckerBoard(FinalBoard),
    %Determine new jumps
    findall(ObservedPosition,getJumpPosition(FinalBoard,ToPosition,Player,ObservedPosition),NextGenerationJumpPositions),
    write('Jump Positions from ToPosition('),write(ToPosition),write(') : '),write(NextGenerationJumpPositions), nl, %DEBUG
    %Stop if there is no more
    length(NextGenerationJumpPositions,JumpPositionsSize),
    JumpPositionsSize > 0, !,                                                                                 %JumpSize
    saveJumpSize(NextGenerationJumpPositions,[FirstRivalPosition | RivalPositions],RefinedJumpPositions),
    write('Saved Jumps : '),write(RefinedJumpPositions), nl, %DEBUG
    %Keep Exploring !
    exploreDeeperJumps(FinalBoard,Player,ToPosition,RefinedJumpPositions,FoundPositions),
    write('Deeper Jump : '),write(FoundPositions),nl,
    exploreDeeperJumps(Board,Player,FromPosition,OtherJumps,OtherJumpPositions),
    append(FoundPositions,OtherJumpPositions,FinalJumpPosition).

exploreDeeperJumps(Board,Player,FromPosition,[[ToPosition, FirstRivalPosition | RivalPositions] | OtherJumps ],[[ToPosition, FirstRivalPosition | RivalPositions] | FinalJumpPositionTail]) :-
    % We haven't been cutted so there is no more solution with 'ToPosition'
    write('No more jump solution for '),write(ToPosition),write(' position.'),nl,
    exploreDeeperJumps(Board,Player,FromPosition,OtherJumps,FinalJumpPositionTail).

exploreDeeperJumps(_Board,_Player,_FromPosition,[],[]).

selectBestMoves([[JumpPosition | RivalPawnsPositions]|OtherJumps],[BestJumpPosition | LongestRivalPawnsPositions],[[JumpPosition | RivalPawnsPositions]|Tail]) :-
    length(RivalPawnsPositions,ChallengerSize),
    length(LongestRivalPawnsPositions,BestSize),
    ChallengerSize = BestSize, !,
    selectBestMoves(OtherJumps,[BestJumpPosition | LongestRivalPawnsPositions],Tail).

selectBestMoves([_BadJump|OtherJumps],[BestJumpPosition | LongestRivalPawnsPositions],BestJumps) :-
    selectBestMoves(OtherJumps,[BestJumpPosition | LongestRivalPawnsPositions],BestJumps).

selectBestMoves([],[BestJumpPosition | LongestRivalPawnsPositions],[[BestJumpPosition | LongestRivalPawnsPositions]]).

getJumpPosition(Board,SourcePosition,Player,[TopLeftJumpPosition,RivalPosition]) :-
    Player,
    \+ member(SourcePosition,[1,11,21,31,41,51,61,71,81,91]),
    \+ member(SourcePosition,[1,2,3,4,5,6,7,8,9,10]),
    getBoxFromGridPosition(Board,SourcePosition,_FooBox),            %ensure given position  exists on this board
    RivalPosition is SourcePosition - 11,
    \+ member(RivalPosition,[1,11,21,31,41,51,61,71,81,91]),
    \+ member(RivalPosition,[1,2,3,4,5,6,7,8,9,10]),
    getBoxFromGridPosition(Board,RivalPosition,RivalBox),   %ensure generated position is a rival position
    nth1(1,RivalBox,'x'),                                   %TODO Handle super pawn case
    TopLeftJumpPosition is RivalPosition - 11,
    getBoxFromGridPosition(Board,TopLeftJumpPosition,EmptyBox),   %ensure generated position is an empty position
    nth1(1,EmptyBox,' ').
    
getJumpPosition(Board,SourcePosition,Player,[TopLeftJumpPosition,RivalPosition]) :-
    \+ Player,
    \+ member(SourcePosition,[1,11,21,31,41,51,61,71,81,91]),
    \+ member(SourcePosition,[1,2,3,4,5,6,7,8,9,10]),
    getBoxFromGridPosition(Board,SourcePosition,_FooBox),            %ensure given position  exists on this board
    RivalPosition is SourcePosition - 11,
    \+ member(RivalPosition,[1,11,21,31,41,51,61,71,81,91]),
    \+ member(RivalPosition,[1,2,3,4,5,6,7,8,9,10]),
    getBoxFromGridPosition(Board,RivalPosition,RivalBox),   %ensure generated position is a rival position
    nth1(1,RivalBox,'o'),                                   %TODO Handle super pawn case
    TopLeftJumpPosition is RivalPosition - 11,
    getBoxFromGridPosition(Board,TopLeftJumpPosition,EmptyBox),   %ensure generated position is an empty position
    nth1(1,EmptyBox,' ').

getJumpPosition(Board,SourcePosition,Player,[TopRighJumpPosition,RivalPosition]) :-
    Player,
    \+ member(SourcePosition,[10,20,30,40,50,60,70,80,90,100]),
    \+ member(SourcePosition,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,SourcePosition,_FooBox),            %ensure given position  exists on this board
    RivalPosition is SourcePosition - 9,
    \+ member(RivalPosition,[10,20,30,40,50,60,70,80,90,100]),
    \+ member(RivalPosition,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,RivalPosition,RivalBox),   %ensure generated position is a rival position
    nth1(1,RivalBox,'x'),                                   %TODO Handle super pawn case
    TopRighJumpPosition is RivalPosition - 9,
    getBoxFromGridPosition(Board,TopRighJumpPosition,EmptyBox),   %ensure generated position is an empty position
    nth1(1,EmptyBox,' ').

getJumpPosition(Board,SourcePosition,Player,[TopRighJumpPosition,RivalPosition]) :-
    \+ Player,
    \+ member(SourcePosition,[10,20,30,40,50,60,70,80,90,100]),
    \+ member(SourcePosition,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,SourcePosition,_FooBox),            %ensure given position  exists on this board
    RivalPosition is SourcePosition - 9,
    \+ member(RivalPosition,[10,20,30,40,50,60,70,80,90,100]),
    \+ member(RivalPosition,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,RivalPosition,RivalBox),   %ensure generated position is a rival position
    nth1(1,RivalBox,'o'),                                   %TODO Handle super pawn case
    TopRighJumpPosition is RivalPosition - 9,
    getBoxFromGridPosition(Board,TopRighJumpPosition,EmptyBox),   %ensure generated position is an empty position
    nth1(1,EmptyBox,' ').

getJumpPosition(Board,SourcePosition,Player,[BottomRighJumpPosition,RivalPosition]) :-
    Player,
    \+ member(SourcePosition,[10,20,30,40,50,60,70,80,90,100]),
    \+ member(SourcePosition,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,SourcePosition,_FooBox),            %ensure given position  exists on this board
    RivalPosition is SourcePosition + 11,
    \+ member(RivalPosition,[10,20,30,40,50,60,70,80,90,100]),
    \+ member(RivalPosition,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,RivalPosition,RivalBox),   %ensure generated position is a rival position
    nth1(1,RivalBox,'x'),                                   %TODO Handle super pawn case
    BottomRighJumpPosition is RivalPosition + 11,
    getBoxFromGridPosition(Board,BottomRighJumpPosition,EmptyBox),   %ensure generated position is an empty position
    nth1(1,EmptyBox,' ').

getJumpPosition(Board,SourcePosition,Player,[BottomRighJumpPosition,RivalPosition]) :-
    \+ Player,
    \+ member(SourcePosition,[10,20,30,40,50,60,70,80,90,100]),
    \+ member(SourcePosition,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,SourcePosition,_FooBox),            %ensure given position  exists on this board
    RivalPosition is SourcePosition + 11,
    \+ member(RivalPosition,[10,20,30,40,50,60,70,80,90,100]),
    \+ member(RivalPosition,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,RivalPosition,RivalBox),   %ensure generated position is a rival position
    nth1(1,RivalBox,'o'),                                   %TODO Handle super pawn case
    BottomRighJumpPosition is RivalPosition + 11,
    getBoxFromGridPosition(Board,BottomRighJumpPosition,EmptyBox),   %ensure generated position is an empty position
    nth1(1,EmptyBox,' ').

getJumpPosition(Board,SourcePosition,Player,[BottomLeftJumpPosition,RivalPosition]) :-
    Player,
    \+ member(SourcePosition,[1,11,21,31,41,51,61,71,81,91]),
    \+ member(SourcePosition,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,SourcePosition,_FooBox),            %ensure given position  exists on this board
    RivalPosition is SourcePosition + 9,
    \+ member(RivalPosition,[1,11,21,31,41,51,61,71,81,91]),
    \+ member(RivalPosition,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,RivalPosition,RivalBox),   %ensure generated position is a rival position
    nth1(1,RivalBox,'x'),                                   %TODO Handle super pawn case
    BottomLeftJumpPosition is RivalPosition + 9,
    getBoxFromGridPosition(Board,BottomLeftJumpPosition,EmptyBox),   %ensure generated position is an empty position
    nth1(1,EmptyBox,' ').

getJumpPosition(Board,SourcePosition,Player,[BottomLeftJumpPosition,RivalPosition]) :-
    \+ Player,
    \+ member(SourcePosition,[1,11,21,31,41,51,61,71,81,91]),
    \+ member(SourcePosition,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,SourcePosition,_FooBox),            %ensure given position  exists on this board
    RivalPosition is SourcePosition + 9,
    \+ member(RivalPosition,[1,11,21,31,41,51,61,71,81,91]),
    \+ member(RivalPosition,[91,92,93,94,95,96,97,98,99,100]),
    getBoxFromGridPosition(Board,RivalPosition,RivalBox),   %ensure generated position is a rival position
    nth1(1,RivalBox,'o'),                                   %TODO Handle super pawn case
    BottomLeftJumpPosition is RivalPosition + 9,
    getBoxFromGridPosition(Board,BottomLeftJumpPosition,EmptyBox),   %ensure generated position is an empty position
    nth1(1,EmptyBox,' ').

saveJumpSize([ [JumpPosition,RivalPosition] | NextJumpPosition ],[FirstRivalPosition | RivalPositions],[RefinedJump | OthersJump]) :-
    append([JumpPosition,RivalPosition],[FirstRivalPosition | RivalPositions],RefinedJump),
    saveJumpSize(NextJumpPosition,[FirstRivalPosition | RivalPositions],OthersJump).

saveJumpSize([],_CurrentJump,[]).