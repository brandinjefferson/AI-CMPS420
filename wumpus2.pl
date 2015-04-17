subset([H|T], Set):-
    member(H, Set),
    subset(T, Set).
subset([], _).

delete_list([H|T], List, Final):-
    remove(H, List, Remainder),
    delete_list(T, Remainder, Final).
delete_list([], List, List).

delete_item(A, [A|B], B).
delete_item(A, [B, C|D], [B|E]) :- delete_item(A, [C|D], E).

start([Size,Pits,wumpus(X,Y),Gold]) :- 
	climb([Size,Pits,wumpus(X,Y)],Gold,
				[arrows(2),pos(1,1),facing(east)],[]).

climb(World,Gold,Cur_State,Knowledge) :- member(has_gold,Cur_State), write('Climb out.\n').
climb(World,Gold,Cur_State,[]) :- plan(World,Cur_State,Gold,[],[],[]).

plan(World,[arrows(A),pos(X,Y),facing(F),has_gold],Gold,Safe,Not_Safe,Knowledge) :-
	%Go back to 1,1
	climb(World,Gold,[arrows(A),pos(X,Y),facing(F),has_gold],Knowledge).

plan(World,[arrows(A),pos(X,Y),facing(F)],Gold,Safe,Not_Safe,Knowledge) :-
	(member(has_gold,Knowledge) ->
		go_back(World,[arrows(A),pos(X,Y),facing(F)],Safe,Not_Safe,Knowledge);
		(
		(\+member(pos(X,Y),Safe) ->
			append(Safe,pos(X,Y),New_Safe);
			append([],Safe,New_Safe)),
		cell_notices(World,Gold,pos(X,Y),Knowledge,New_Knowledge,Safe,Not_Safe,New_Not_Safe),
		\+dead(World,pos(X,Y)),
		(grab_gold(World,New_World,pos(X,Y),Knowledge,[arrows(A),pos(X,Y),facing(F)],New_State);
		shoot_arrow(World,New_World,Knowledge,[arrows(A),pos(X,Y),facing(F)],New_State);
		move_forward(World,New_World,[arrows(A),pos(X,Y),facing(F)],New_State);
		turn(World,New_World,[arrows(A),pos(X,Y),facing(F)],New_State)),
		plan(New_World,New_State,Gold,New_Safe,New_Not_Safe,New_Knowledge))
	).
		

cell_notices([_,Pits,wumpus(X1,Y1)],Gold,pos(X,Y),
					Knowledge,New_Knowledge,Safe,Not_Safe,New_Not_Safe) :-
	(stench(wumpus(X1,Y2),pos(X,Y),Knowledge) -> 
		append(Knowledge,stench(X,Y),L1),Temp is 1;
		append(Knowledge,[],L1),Temp is 0),
	(breeze(Pits,pos(X,Y)) ->
		append(Knowledge,breeze(X,Y),L2),Temp is 2;
		append(Knowledge,[],L2)),
	(Temp > 0 -> add_to_not_safe(pos(X,Y),Safe,Not_Safe,New_Not_Safe);true) ->
	(glitter(Gold,pos(X,Y)) ->
		append(Knowledge,glitter(X,Y),L3);
		append(Knowledge,[],L3)),
	append(L1,L2,L4), append(L3,L4,L5),
	append(L5,Knowledge,New_Knowledge).
	
stench(wumpus(X,Y),pos(A,B),Safe,Not_Safe,New_Not_Safe,Knowledge) :-
	\+member(wumpus_is_dead,Knowledge),
	(X1 is X+1, X2 is X-1, Y1 is Y+1, Y2 is Y-1,
	((A = X1, B=Y); (A=X2,B=Y); (A=X,B=Y1);(A=X,B=Y2))),
	add_to_not_safe(pos(A,B),Safe,Not_Safe,New_Not_Safe).

breeze([],_) :- fail.
breeze([pit(X/Y)|Other_Pits],pos(A,B)) :-
	X1 is X+1, X2 is X-1, Y1 is Y+1, Y2 is Y-1,
	((A = X1, B=Y); (A=X2,B=Y); (A=X,B=Y1);(A=X,B=Y2)),
	add_to_not_safe(pos(A,B),Safe,Not_Safe,New_Not_Safe);
	breeze(Other_Pits,pos(A,B)).
	
glitter([],_) :- fail.
glitter([gold(X/Y)|Other_Gold],pos(A,B)) :-
	X1 is X+1, X2 is X-1, Y1 is Y+1, Y2 is Y-1,
	(((A = X1, B=Y); (A=X2,B=Y); (A=X,B=Y1);(A=X,B=Y2));
	glitter(Other_Gold,pos(A,B)).

add_to_not_safe(pos(X,Y),Safe,Not_Safe,New_Not_Safe) :-
	(member(pos(X,Y),Not_Safe) ->
			delete_item(Not_Safe,pos(X,Y),L1);
			append(Not_Safe,[],L1)),
	((Z is X+1,\+member(pos(Z,Y),Safe),\+member(pos(Z,Y),Not_Safe)) 
		-> append(L1,pos(Z,Y),L2);append(L1,[],L2)) ->
	((Z is X-1,\+member(pos(Z,Y),Safe),\+member(pos(Z,Y),Not_Safe))
		-> append(L2,pos(Z,Y),L3);append(L2,[],L3)) ->
	((Z is Y+1,\+member(pos(X,Z),Safe),\+member(pos(X,Z),Not_Safe)) 
		-> append(L3,pos(X,Z),L4);append(L3,[],L4)) ->
	((Z is Y-1,\+member(pos(X,Z),Safe), \+member(pos(X,Z),Not_Safe))
		-> append(L4,pos(X,Z),New_Not_Safe);append(L4,[],New_Not_Safe)).
	
dead([_,Pits,wumpus(X2,Y2),_],pos(X,Y)) :-
	pit_dead(Pits,pos(X,Y));
	(X=X2,Y=Y2), write('Oh, you just ran into the wumpus!\n').
pit_dead([],_) :- fail.
pit_dead([pit(X1,Y1)|Other_Pits],pos(X,Y)) :-
	((X = X1,Y=Y1), write('Should have dodged that giant hole in the ground.\n'));
	pit_dead(Other_Pits,pos(X,Y)).
	
%Possible moves
move_forward([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(east)],[arrows(A),pos(Z,Y),facing(east)]) :- 
	Z is X+1,\+(Z > Size,write('Bump.\n')).
move_forward([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(west)],[arrows(A),pos(Z/Y),facing(west)]) :- 
	Z is X-1,\+(Z > Size,write('Bump.\n')).
move_forward([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(north)],[arrows(A),pos(X/Z),facing(north)]) :- 
	Z is Y+1,\+(Z > Size,write('Bump.\n')).
move_forward([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(south)],[arrows(A),pos(X/Z),facing(south)]) :- 
	Z is Y-1,\+(Z > Size,write('Bump.\n')).

grab_gold(World,World,pos(X,Y),Knowledge,Cur_State,New_State) :-
	(member(glitter(X,Y),Knowledge) ->
		(append(Cur_State,has_gold,New_State),
		write("Picked up gold at "),write(pos(X,Y))).

turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(east)],[arrows(A),pos(X,Y),facing(north)]) ;-
	Z is Y+1, Z < Size.
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(east)],[arrows(A),pos(X,Y),facing(south)]) ;-
	Z is Y-1, Z > 0.	
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(west)],[arrows(A),pos(X,Y),facing(south)]) ;-
	Z is Y-1, Z > 0.
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(west)],[arrows(A),pos(X,Y),facing(north)]) ;-
	Z is Y+1, Z < Size.
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(north)],[arrows(A),pos(X,Y),facing(west)]) ;-
	Z is X-1, Z > 0.
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(north)],[arrows(A),pos(X,Y),facing(east)]) ;-
	Z is X+1, Z < Size.
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(south)],[arrows(A),pos(X,Y),facing(east)]) ;-
	Z is X+1, Z < Size.
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(south)],[arrows(A),pos(X,Y),facing(west)]) ;-
	Z is X-1, Z > 0.
	
shoot_arrow([Size,Pits,wumpus(X1,Y1)], [Size,Pits,wumpus(X2,Y2)], Knowledge,
				[arrow(A),pos(X,Y),facing(F)],[arrow(A1),pos(X,Y),facing(F)]) :-
	(A > 0,member(stench(X,Y),Knowledge)) -> A1 is A-1, 
	write("Firing an arrow. "), write(A1), write(' arrows remaining.\n'),
	((X = X1, Y < Y1, F = north);(X=X1,Y>Y1,F=south);
	(X>X1,Y=Y1,F = west);(X<X1,Y=Y1,F=east)) ->
		(X2 is -100, Y2 is -100,
			write("Wumpus: AAAAAAAAAGHDGHDSKLGHG!!!\n"));
		X2 is X1, Y2 is Y1, write('Thump.\n').
		

		