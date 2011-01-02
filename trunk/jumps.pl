% Author:
% Date: 29/12/2010
% Describe jump algorithm

getJump(Board,Position,Player,JumpPositions) :-
    findall(ObservedPosition,getJumpPosition(Board,Position,Player,ObservedPosition),FirstJumpPositions),  %first generation of "jumper" :)
    %write('Jump Positions : '),write(FirstJumpPositions), nl,                                              %DEBUG
    exploreDeeperJumps(Board,Player,Position,FirstJumpPositions,AllJumpPositions),
    reverse(AllJumpPositions,AllJumpPositionsReversed),                                                    %Best jump are ALWAYS at the end
    nth1(1,AllJumpPositionsReversed,First),                                                                %select the best jump to compare with the other
    select(First,AllJumpPositionsReversed,JumpPositionsReversedTail),                                      %delete it from main list,
    selectBestMoves(JumpPositionsReversedTail,First,JumpPositions).

exploreDeeperJumps(Board,Player,FromPosition,[[ToPosition, FirstRivalPosition | RivalPositions] | OtherJumps ],FinalJumpPosition) :-
    %Determine player : 'o'
    Player,
    %Simulate a new board
    setBoxStateByPosition(Board         ,BoardModified1,FromPosition      ,'o',' '),
    setBoxStateByPosition(BoardModified1,BoardModified2,FirstRivalPosition,'x',' '),
    setBoxStateByPosition(BoardModified2,FinalBoard    ,ToPosition        ,' ','o'),
    %write('Simulated checker board :'),nl,printCheckerBoard(FinalBoard),
    %Determine new jumps
    findall(ObservedPosition,getJumpPosition(FinalBoard,ToPosition,Player,ObservedPosition),NextGenerationJumpPositions),
    %write('Jump Positions from '),write(ToPosition),write(' : '),write(NextGenerationJumpPositions), nl, %DEBUG
    %Stop if there is no more
    length(NextGenerationJumpPositions,JumpPositionsSize),
    JumpPositionsSize > 0, !,                                                                                 %JumpSize
    saveJumpSize(NextGenerationJumpPositions,[FirstRivalPosition | RivalPositions],RefinedJumpPositions),
    %write('Saved Jumps : '),write(RefinedJumpPositions), nl, %DEBUG
    %Keep Exploring !
    exploreDeeperJumps(FinalBoard,Player,ToPosition,RefinedJumpPositions,FoundPositions),
    %write('Deeper Jump : '),write(FoundPositions),nl,
    exploreDeeperJumps(Board,Player,FromPosition,OtherJumps,OtherJumpPositions),
    append(FoundPositions,OtherJumpPositions,FinalJumpPosition).

exploreDeeperJumps(Board,Player,FromPosition,[[ToPosition, FirstRivalPosition | RivalPositions] | OtherJumps ],FinalJumpPosition) :-
    %Determine player : 'x'
    \+ Player,
    %Simulate a new board
    setBoxStateByPosition(Board         ,BoardModified1,FromPosition      ,'x',' '),
    setBoxStateByPosition(BoardModified1,BoardModified2,FirstRivalPosition,'o',' '),
    setBoxStateByPosition(BoardModified2,FinalBoard    ,ToPosition        ,' ','x'),
    %write('Simulated checker board :'),nl,printCheckerBoard(FinalBoard),
    %Determine new jumps
    findall(ObservedPosition,getJumpPosition(FinalBoard,ToPosition,Player,ObservedPosition),NextGenerationJumpPositions),
    %write('Jump Positions from '),write(ToPosition),write(' : '),write(NextGenerationJumpPositions), nl, %DEBUG
    %Stop if there is no more
    length(NextGenerationJumpPositions,JumpPositionsSize),
    JumpPositionsSize > 0, !,                                                                                 %JumpSize
    saveJumpSize(NextGenerationJumpPositions,[FirstRivalPosition | RivalPositions],RefinedJumpPositions),
    %write('Saved Jumps : '),write(RefinedJumpPositions), nl, %DEBUG
    %Keep Exploring !
    exploreDeeperJumps(FinalBoard,Player,ToPosition,RefinedJumpPositions,FoundPositions),
    %write('Deeper Jump : '),write(FoundPositions),nl,
    exploreDeeperJumps(Board,Player,FromPosition,OtherJumps,OtherJumpPositions),
    append(FoundPositions,OtherJumpPositions,FinalJumpPosition).

exploreDeeperJumps(Board,Player,FromPosition,[[ToPosition, FirstRivalPosition | RivalPositions] | OtherJumps ],[[ToPosition, FirstRivalPosition | RivalPositions] | FinalJumpPositionTail]) :-
    % We haven't been cutted so there is no more solution with 'ToPosition'
    %write('No more jump solution for '),write(ToPosition),write(' position.'),nl,
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

saveJumpSize([ [JumpPosition,RivalPosition] | NextJumpPosition ],[FirstRivalPosition | RivalPositions],[RefinedJump | OthersJump]) :-
    append([JumpPosition,RivalPosition],[FirstRivalPosition | RivalPositions],RefinedJump),
    saveJumpSize(NextJumpPosition,[FirstRivalPosition | RivalPositions],OthersJump).

saveJumpSize([],_CurrentJump,[]).