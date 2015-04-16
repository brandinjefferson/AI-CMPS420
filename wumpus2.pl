start([Size,Pits,wumpus(X,Y)],Gold) :- 
	climb_in([Size,Pits,wumpus(X,Y)],
				[arrows(2),pos(1,1),facing(east)],Gold).

climb_in(World,Cur_State,Gold) :- plan(World,Cur_State,Gold,[],[],[],[]).

plan(World,Cur_State,[],_,_,_,[been(X,Y)|Other]) :-
		%Go back to 1,1
		write("Made it out alive and with the gold.\n").

plan(World,Cur_State,Gold,Safe,Not_Safe,Knowledge,Been) :-
		(check_safety(World,Cur_State) ->
			add_to_not_safe(Cur_State,Safe,Not_Safe,New_Not_Safe), 
				current_safe(Cur_State,Safe,New_Safe);
			add_to_safe(Cur_State,Safe,New_Safe),
				current_safe(Cur_State,Safe,New_Safe)),
		\+dead(World,Cur_State),
		move(World,Gold,Cur_State,Delete,Add),
		
		
stench(wumpus(X,Y),pos(A,B)) :-
	X1 is X+1, X2 is X-1, Y1 is Y+1, Y2 is Y-1,
	((A = X1, B=Y); (A=X2,B=Y); (A=X,B=Y1);(A=X,B=Y2)).

breeze([],_) :- fail.
breeze([pit(X/Y)|Other_Pits],pos(A,B)) :-
	X1 is X+1, X2 is X-1, Y1 is Y+1, Y2 is Y-1,
	(((A = X1, B=Y); (A=X2,B=Y); (A=X,B=Y1);(A=X,B=Y2));
	breeze(Other_Pits,pos(A,B)).

check_safety([_,Pits,wumpus(A,B)][_,pos(X,Y),_],Knowledge,New_Knowledge) :-
	stench(wumpus(A,B),pos(X,Y));breeze(Pits,pos(X,Y)).

add_to_not_safe([_,pos(X,Y),_],Safe,Not_Safe,New_Not_Safe) :-
	((Z is X+1,\+member(pos(Z,Y),Safe)) -> append(Not_Safe,pos(Z,Y),New_Not_Safe);true) ->
	((Z is X-1,\+member(pos(Z,Y),Safe)) -> append(Not_Safe,pos(Z,Y),New_Not_Safe);true) ->
	((Z is Y+1,\+member(pos(X,Z),Safe)) -> append(Not_Safe,pos(X,Z),New_Not_Safe);true) ->
	((Z is Y-1,\+member(pos(X,Z),Safe)) -> append(Not_Safe,pos(X,Z),New_Not_Safe);true).
current_safe([_,pos(X,Y),_],Safe,New_Safe) :-
	(\+member(pos(X,Y),Safe), append(Safe,pos(X,Y),New_Safe));
	true.
add_to_safe([_,pos(X,Y),_],Safe,New_Safe) :-
	((Z is X+1,\+member(pos(Z,Y),Safe)) -> append(Safe,pos(Z,Y),New_Safe);true) ->
	((Z is X-1,\+member(pos(Z,Y),Safe)) -> append(Safe,pos(Z,Y),New_Safe);true) ->
	((Z is Y+1,\+member(pos(X,Z),Safe)) -> append(Safe,pos(X,Z),New_Safe);true) ->
	((Z is Y-1,\+member(pos(X,Z),Safe)) -> append(Safe,pos(X,Z),New_Safe);true).
	
dead([_,Pits,wumpus(X2,Y2)],[_,pos(X,Y),_]) :-
	pit_dead(Pits,pos(X,Y));
	(X=X2,Y=Y2), write('Oh, you just ran into the wumpus!\n').
pit_dead([],_) :- fail.
pit_dead([pit(X1,Y1)|Other_Pits],pos(X,Y)) :-
	((X = X1,Y=Y1), write('Should have dodged that giant hole in the ground.\n'));
	pit_dead(Other_Pits,pos(X,Y)).
	
	
move(World,_,[arrows(A),pos(X,Y),facing(east)],[pos(X,Y)],[pos(Z,Y)]) :- 
	Z is X+1.
move(World,_,[arrows(A),pos(X,Y),facing(west)],[pos(X,Y)],[pos(Z,Y)]) :- 
	Z is X-1.
move(World,_,[arrows(A),pos(X,Y),facing(north)],[pos(X,Y)],[pos(X,Z)]) :- 
	Z is Y+1.
move(World,_,[arrows(A),pos(X,Y),facing(south)],[pos(X,Y)],[pos(X,Z)]) :- 
	Z is Y-1.
