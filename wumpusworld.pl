%Prolog moves from the top to the bottom.
%It is heavily recursive.
%Can use 'trace' to follow what it does. Just continue pressing enter.

%Can do checks when reaching a certain 
world(Size,WumpusX/WumpusY,[PitX/PitY|Other_Pits],[GoldX/GoldY|Other_Gold],Path) :-
Size > 0, .
%Checks if the current room has a stench
stench(WumpusX/WumpusY,X/Y) :- 
    A is WumpusX+1, B is WumpusX-1, C is WumpusY+1, D is WumpusY-1,
    member(X/Y,[A/WumpusY,B/WumpusY,WumpusX/C,WumpusX/D]).
%Checks if the current room has a breeze
breeze([PitX/PitY|Other_Pits],X/Y) :-
    A is PitX+1, B is PitX-1, C is PitY+1, D is PitY-1,
    (member(X/Y,[A/PitY,B/PitY,PitX/C,PitX/D]);
    breeze(Other_Pits,X/Y)).
breeze([],_/_) :- fail.
%Checks if the current room has gold. If it does, there will be glitter. 
%This is used to make sure the character knows to pick up the gold.
glitter([GoldX/GoldY|Other_Gold],X/Y) :-
    (X = GoldX, Y = GoldY);
    glitter(Other_Gold,X/Y)).
glitter([],_/_) :- fail.


	