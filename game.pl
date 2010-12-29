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
    initializeCheckerBoard(Board),
    initializePlayers(Player),
    run(Board,Player),
    nl.
    
run(Board,Player) :-
    canStillPlay(Board,Player),
    printCheckerBoard(Board),
    printPlayerTurn(Player),
    write('Select the pawn you want to move'),nl,
    read(StartPosition),
    generateAllowedMove(Board,StartPosition,Player,Moves),
    write('Allowed Moves : '),write(Moves),nl,
    write('Select where you want to go'),nl,
    read(MovePosition),nl,
    movePawn(Board,NewBoard,StartPosition,MovePosition,Moves,Player),
    nextTurn(Player,NewPlayer),
    run(NewBoard,NewPlayer).
    
run(Board,Player) :-
    canStillPlay(Board,Player),
    write('Reselect a correct the pawn you want to move'),nl,
    run(Board,Player).
    
run(_Board,Player) :-
    Player, !,
    write('Noir a gagné.').
    
run(_Board,_Player) :-
    write('Blanc a gagné.').
    
