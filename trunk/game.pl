% Author: Dream Team
% Date: 08/12/2010
% Referee

initializePlayers(Player) :-
    Player = true.
    
printPlayerTurn(Player) :-
    Player, !,
    write('A Blanc de jouer.'),nl.
    
printPlayerTurn(_Player) :-
    write('A Noir de jouer.'),nl.

nextTurn(Player,NewPlayer) :-
    Player, !,
    NewPlayer = false.
    
nextTurn(Player,NewPlayer) :-
    not(Player),
    NewPlayer = true.

start :-
    initializeRafleCheckerBoard(Board),
    initializePlayers(Player),
    run(Board,Player),
    nl.
    
run(Board,Player) :-
    %canStillPlay(Board,Player),
    printCheckerBoard(Board),
    printPlayerTurn(Player),
    % TODO Détecter les pièces ayant le droit de se mouvoir
    getStartPositions(Board,Board,Player,StartPositions),
    %getPrintableStartPositions(StartPositions,PrintableStatPositions),
    write('Allowed start positions : '),write(StartPositions),nl,
    write('Select the pawn you want to move'),nl,
    read(StartPosition),
    checkValidPosition(StartPosition,StartPositions),
    generateAllowedMove(Board,StartPosition,Player,Moves),
    write('Allowed Moves : '),printPositions(Moves),nl,
    write('Select where you want to go'),nl,
    read(MovePosition),nl,
    movePawn(Board,NewBoard,StartPosition,MovePosition,Moves,Player),
    nextTurn(Player,NewPlayer),
    run(NewBoard,NewPlayer).
    
run(Board,Player) :-
    %canStillPlay(Board,Player),
    write('Reselect a correct the pawn you want to move'),nl,
    run(Board,Player).
    
run(Board,Player) :-
    Player, !,
    printCheckerBoard(Board),
    write('Noir a gagné.').
    
run(Board,_Player) :-
    printCheckerBoard(Board),
    write('Blanc a gagné.').
    
