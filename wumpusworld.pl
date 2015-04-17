%Prolog moves from the top to the bottom.
%It is heavily recursive.
%Can use 'trace' to follow what it does. Just continue pressing enter.
del(A, [A|B], B).
del(A, [B, C|D], [B|E]) :- del(A, [C|D], E).

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
glitter([_,position(X/Y),_,[gold(GoldX/GoldY)|Other_Gold_To_Get]],[_,_,_,New_Gold]) :-
	%Alter this so that it's like an if statement
	/*if x = goldx and y=goldy, then del gold(x/y) from list of gold to get
	else check next in list of gold to get.*/
    ((X = GoldX, Y = GoldY) -> 
	(del(gold(X/Y),[gold(GoldX/GoldY)|Other_Gold_To_Get],New_Gold),
	write('Picked up gold.\n'));
    glitter([_,position(X/Y),_,Other_Gold_To_Get],New_Gold)).
glitter([],position(_/_),_,_,_).
%---Must remove from the list somehow if the gold is found
pickup_gold([GoldX/GoldY|Other_Gold],X/Y) :-
    glitter([GoldX/GoldY|Other_Gold]),
	%remove(GoldX/GoldY,[Other_Gold]),
	%move on with remaining gold list, if it's empty then move back to 1/1
    
climb_in(AgentX/AgentY,Direction,Arrows,Size,WumpusX/WumpusY,[PitX/PitY|Other_Pits],[GoldX/GoldY|Other_Gold]) :-
     stench(WumpusX/WumpusY,AgentX/AgentY),
	 breeze([PitX/PitY|Other_Pits],AgentX/AgentY),
	 glitter([GoldX/GoldY|Other_Gold],AgentX/AgentY),

	 
start([Size,Gold,Pits,WumpusX/WumpusY]) :- climb_in([Size,Gold,Pits,WumpusX/WumpusY],
                                                  [position(1/1),arrows(2),facing(east),Gold]).
climb_in(W,Start) :- plan([_,Gold,_,_/_],Start,[position(1/1),
                              arrows(2),facing(X),[]],[],[],[],[]).
climb_out :- write("Made it out alive.\n").
%plan(number,[],Number/Number,[],[],[])
%Size = size of the world
%Safe - A list of states that are known to be safe. Includes where the agent has been.
%Not_Safe - a list of places where it's not known if it' safe.
%Knowledge = Things he has perceived. These would be like stenches, breezes, the state of the wumpus, etc
plan(World,Cur_State,Goal,Knowledge,Safe,Not_Safe,Been) :-
            %Check for stenches/wumpus/breeze/pits/gitter
			(check_safety(World,Cur_State,Knowledge) ->
			    (add_to_not_safe(Cur_State,Not_Safe,New_Not_Safe),is_safe(Cur_State,Safe,New_Safe);
				add_to_safe(Cur_State,Safe,New_Safe)),
			\+ dead(World,Cur_State),
			glitter(Cur_State,New_Gold),
            move(World,Cur_State,Actions,Safe),
			append(Been,[been(X/Y)],New_Been),
			plan(World,)

/*move(World,Preconditions,Actions)*/
%Need movement for firing arrow.

%Move forward if Z is in bounds and the next square is safe.
move([Size,Gold,Pits,WumpusX/WumpusY],[arrows(A),position(X/Y),facing(east)],
		[arrows(A),remove(position(X/Y)),add(position(Z/Y)),facing(east)],Safe) :-
   Z is X+1, Z =< Size, Z >= 0,safe(Z/Y).
move([Size,Gold,Pits,WumpusX/WumpusY],[arrows(A),position(X/Y),facing(west),_],[arrows(A),position(Z/Y),facing(west)],Safe) :-
   Z is X-1, Z =< Size, Z >= 0,safe(Z/Y).
move([Size,Gold,Pits,WumpusX/WumpusY],[arrows(A),position(X/Y),facing(north),_],[arrows(A),position(X/Z),facing(north)],Safe) :-
   Z is Y+1, Z =< Size, Z >= 0,safe(X/Z).
move([Size,Gold,Pits,WumpusX/WumpusY],[arrows(A),position(X/Y),facing(south),_],[arrows(A),position(X/Z),facing(south)],Safe) :-
   Z is Y-1, Z =< Size, Z >= 0,safe(X/Z).
%Turn 90 degrees in some direction. 
move([Size,Gold,Pits,WumpusX/WumpusY],[arrows(A),position(X/Y),facing(east),_],[arrows(A),position(X/Y),facing(south)],_).
move([Size,Gold,Pits,WumpusX/WumpusY],[arrows(A),position(X/Y),facing(east),_],[arrows(A),position(X/Y),facing(north)],_).
move([Size,Gold,Pits,WumpusX/WumpusY],[arrows(A),position(X/Y),facing(west),_],[arrows(A),position(X/Y),facing(north)],_).
move([Size,Gold,Pits,WumpusX/WumpusY],[arrows(A),position(X/Y),facing(west),_],[arrows(A),position(X/Y),facing(south)],_).
move([Size,Gold,Pits,WumpusX/WumpusY],[arrows(A),position(X/Y),facing(north),_],[arrows(A),position(X/Y),facing(east)],_).
move([Size,Gold,Pits,WumpusX/WumpusY],[arrows(A),position(X/Y),facing(north),_],[arrows(A),position(X/Y),facing(west)],_).
move([Size,Gold,Pits,WumpusX/WumpusY],[arrows(A),position(X/Y),facing(south),_],[arrows(A),position(X/Y),facing(west)],_).
move([Size,Gold,Pits,WumpusX/WumpusY],[arrows(A),position(X/Y),facing(south),_],[arrows(A),position(X/Y),facing(east)],_).

%Checks the safety of the current square and adds whether it is a breeze or stench to the knowledge base
check_safety([_,Gold,Pits,WumpusX/WumpusY],[_,position(X/Y),_],Knowledge,New_Knowledge) :-
    (stench(WumpusX/WumpusY,X/Y), append(Knowledge,[stench(X/Y)],New_Knowledge)); 
	(breeze(Pits,X/Y), append(Knowledge,[breeze(X/Y)],New_Knowledge)).
	/*Redo stench and breeze so that they fail if agent not in one of those squares.*/
%Current square is safe. For when the agent recognizes a breeze or stench.
is_safe([_,position(X/Y),_,_],Safe,New_Safe) :- append(Safe,safe(X/Y),New_Safe).
%Nearby squares are also safe. For when the agent steps into a square void of a stench or breeze.
add_to_safe([_,position(X/Y),_,_],Safe,New_Safe) :- 
	append(Safe,safe(X/Y),New_Safe), Z is X+1,
	append(Safe,safe(Z/Y),New_Safe), Z is X-1,
	append(Safe,safe(Z/Y),New_Safe), Z is Y+1,
	append(Safe,safe(X/Z),New_Safe), Z is Y-1,
	append(Safe,safe(X/Z),New_Safe).
add_to_not_safe([_,position(X/Y),_,_],Safe,Not_Safe,New_Not_Safe) :- Z is X+1;
	(\+member(safe(Z/Y),Safe), append(Not_Safe,not_safe(Z/Y),New_Not_Safe)), Z is X-1;
	(\+member(safe(Z/Y),Safe), append(Not_Safe,not_safe(Z/Y),New_Not_Safe)), Z is Y+1;
	(\+member(safe(X/Z),Safe), append(Not_Safe,not_safe(X/Z),New_Not_Safe)), Z is Y-1;
	(\+member(safe(X/Z),Safe), append(Not_Safe,not_safe(X/Z),New_Not_Safe).

	