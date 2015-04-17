%consult('C:/Users/brand_000/Documents/AI-CMPS420/wumpus2.pl').

test :- start([4,[pit(3,1),pit(3,3),pit(4,4)],wumpus(1,3),[gold(2,3)]]).
test2 :- start([2,[],wumpus(1,2),[gold(2,2)]]).

delete_item(A, [A|B], B).
delete_item(A, [B, C|D], [B|E]) :- delete_item(A, [C|D], E).

add_to_path(Path,Item,[Item|Path]).
write_path_back([]).
write_path_back([path(X,Y,F)|Path]) :- 
	((F = east -> write(pos(X,Y)),write(' , '),write(facing(west)),nl);
	(F = west -> write(pos(X,Y)),write(' , '),write(facing(east)),nl);
	(F = north -> write(pos(X,Y)),write(' , '),write(facing(south)),nl);
	(F = south -> write(pos(X,Y)),write(' , '),write(facing(north)),nl)),
	write_path_back(Path).

start([Size,Pits,wumpus(X,Y),Gold]) :- 
	climb_in([Size,Pits,wumpus(X,Y)],Gold,
				[arrows(2),pos(1,1),facing(east)]).

climb_out(World,Gold,Cur_State) :- member(has_gold,Cur_State), write('Climbed out.\n').
climb_in(World,Gold,Cur_State) :- plan(World,Cur_State,Gold,[],[],[],[],0,0).

plan(World,[arrows(A),pos(X,Y),facing(F),has_gold],Gold,Safe,Not_Safe,Knowledge,Path,_,_) :-
	write_path_back(Path),
	climb_out(World,Gold,[arrows(A),pos(X,Y),facing(F),has_gold],Knowledge).

plan(World,[arrows(A),pos(X,Y),facing(F)],Gold,Safe,Not_Safe,Knowledge,Path,Been_Count,Fired) :-
	(write(pos(X,Y)),write(' , '),write(facing(F)),nl, \+member(dead,Knowledge), 
	dead(World,pos(X,Y)) -> 
		write('Agent is dead.\n'),append(Knowledge,[dead],New_Knowledge);
		%Else, continue
		add_to_path(Path,[path(X,Y,F)],New_Path),
		(\+member(pos(X,Y),Safe) ->
			append(Safe,[pos(X,Y)],New_Safe),New_Been_Ct is 0;
			append([],Safe,New_Safe),New_Been_Ct is Been_Count+1),
		cell_notices(World,Gold,pos(X,Y),Knowledge,New_Knowledge,Safe,Not_Safe,New_Not_Safe),
		(grab_gold(World,New_World,New_Knowledge,[arrows(A),pos(X,Y),facing(F)],New_State);
		shoot_arrow(World,New_World,New_Knowledge,[arrows(A),pos(X,Y),facing(F)],New_State,Fired,Fired1);
		move_forward(World,New_World,[arrows(A),pos(X,Y),facing(F)],New_State,New_Been_Ct,New_Not_Safe);
		turn(World,New_World,[arrows(A),pos(X,Y),facing(F)],New_State)),
		write(New_Knowledge),nl,
		plan(New_World,New_State,Gold,New_Safe,New_Not_Safe,New_Knowledge,New_Path,New_Been_Ct,Fired1)).
		

cell_notices([_,Pits,wumpus(X1,Y1)],Gold,pos(X,Y),
					Knowledge,New_Knowledge,Safe,Not_Safe,New_Not_Safe) :-
	(get_stench(wumpus(X1,Y1),pos(X,Y)) ->
		(append(Knowledge,[stench(X,Y)],L1),Temp is 1);
		(append(Knowledge,[],L1),Temp is 0)),
	(get_breeze(Pits,pos(X,Y)) ->
		(append(L1,[breeze(X,Y)],L2),Temp is 2);
		(append(L1,[],L2))),
	(Temp > 0 -> add_to_not_safe(pos(X,Y),Safe,Not_Safe,New_Not_Safe);
		append(Not_Safe,[],New_Not_Safe)),
	(get_glitter(Gold,pos(X,Y)) ->
		append(L2,[glitter(X,Y)],New_Knowledge);
		append(L2,[],New_Knowledge)).
	
get_stench(wumpus(X,Y),pos(A,B)) :-
	 0 < X, 
	(X1 = X+1, X2 = X-1, Y1 = Y+1, Y2 = Y-1,
	((A = X1, B=Y); (A=X2,B=Y); (X=A,Y1=B);(A=X,B=Y2)),write('stench'),nl).


get_breeze([pit(X,Y)|Other_Pits],pos(A,B)) :- 
	X1 is X+1, X2 is X-1, Y1 is Y+1, Y2 is Y-1,
	((A = X1, B=Y); (A=X2,B=Y); (A=X,B=Y1);(A=X,B=Y2));
	get_breeze(Other_Pits,pos(A,B)).
get_breeze([],_) :- fail.


get_glitter([gold(X,Y)|Other_Gold],pos(A,B)) :-
	(A=X,B=Y);
	get_glitter(Other_Gold,pos(A,B)).
get_glitter([],_) :- fail.

add_to_not_safe(pos(X,Y),Safe,Not_Safe,New_Not_Safe) :-
	(member(pos(X,Y),Not_Safe) ->
			delete_item(Not_Safe,pos(X,Y),L1);
			append(Not_Safe,[],L1)),
	((Z1 is X+1,\+member(pos(Z1,Y),Safe),\+member(pos(Z1,Y),Not_Safe)) 
		-> append(L1,[pos(Z1,Y)],L2);append(L1,[],L2)),
	((Z2 is X-1,\+member(pos(Z2,Y),Safe),\+member(pos(Z2,Y),Not_Safe))
		-> append(L2,[pos(Z2,Y)],L3);append(L2,[],L3)),
	((Z3 is Y+1,\+member(pos(X,Z3),Safe),\+member(pos(X,Z3),Not_Safe)) 
		-> append(L3,[pos(X,Z3)],L4);append(L3,[],L4)),
	((Z4 is Y-1,\+member(pos(X,Z4),Safe), \+member(pos(X,Z4),Not_Safe))
		-> append(L4,[pos(X,Z4)],New_Not_Safe);append(L4,[],New_Not_Safe)).
	
dead([_,Pits,wumpus(X2,Y2)],pos(X,Y)) :-
	pit_dead(Pits,pos(X,Y)),true;
	(X=X2,Y=Y2), write('Oh, you just ran into the wumpus!\n').
pit_dead([],_) :- fail.
pit_dead([pit(X1,Y1)|Other_Pits],pos(X,Y)) :-
	((X = X1,Y=Y1), write('Should have dodged that giant hole in the ground.\n'));
	pit_dead(Other_Pits,pos(X,Y)).
	
been_count(N,N1) :- N1 is N+1.
%Possible moves
move_forward([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(east)],
								[arrows(A),pos(Z,Y),facing(east)],C,Not_Safe) :- 
	Z is X+1,(Z > Size -> write('Bump.\n');true),%(\+member(pos(Z,Y),Not_Safe);C>=3).
	(C>=3,member(pos(Z,Y),Not_Safe));(\+member(pos(Z,Y),Not_Safe)).
move_forward([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(west)],
								[arrows(A),pos(Z,Y),facing(west)],C,Not_Safe) :- 
	Z is X-1,(0 >= Z -> write('Bump.\n');true),%(\+member(pos(Z,Y),Not_Safe);C>=3).
	(C>=3,member(pos(Z,Y),Not_Safe));(\+member(pos(Z,Y),Not_Safe)).
move_forward([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(north)],
								[arrows(A),pos(X,Z),facing(north)],C,Not_Safe) :- 
	Z is Y+1,(Z > Size -> write('Bump.\n');true),%(\+member(pos(X,Z),Not_Safe);C>=3).
	(C>=3,member(pos(X,Z),Not_Safe));(\+member(pos(X,Z),Not_Safe)).
move_forward([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(south)],
								[arrows(A),pos(X,Z),facing(south)],C,Not_Safe) :- 
	Z is Y-1,(0 >= Z -> write('Bump.\n');true),%(\+member(pos(X,Z),Not_Safe);C>=3).
	(C>=3,member(pos(X,Z),Not_Safe));(\+member(pos(X,Z),Not_Safe)).

grab_gold(World,World,Knowledge,[arrows(A),pos(X,Y),facing(F)],New_State) :-
	member(glitter(X,Y),Knowledge) ->
		append([arrows(A),pos(X,Y),facing(F)],[has_gold],New_State),
		write("Picked up gold at "),write(pos(X,Y)).

turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(east)],[arrows(A),pos(X,Y),facing(north)]) :-
	Z is Y+1, Z < Size.
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(east)],[arrows(A),pos(X,Y),facing(south)]) :-
	Z is Y-1, Z > 0.	
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(west)],[arrows(A),pos(X,Y),facing(south)]) :-
	Z is Y-1, Z > 0.
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(west)],[arrows(A),pos(X,Y),facing(north)]) :-
	Z is Y+1, Z < Size.
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(north)],[arrows(A),pos(X,Y),facing(west)]) :-
	Z is X-1, Z > 0.
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(north)],[arrows(A),pos(X,Y),facing(east)]) :-
	Z is X+1, Z < Size.
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(south)],[arrows(A),pos(X,Y),facing(east)]) :-
	Z is X+1, Z < Size.
turn([Size,P,W],[Size,P,W],[arrows(A),pos(X,Y),facing(south)],[arrows(A),pos(X,Y),facing(west)]) :-
	Z is X-1, Z > 0.
	
shoot_arrow([Size,Pits,wumpus(X1,Y1)], [Size,Pits,wumpus(X2,Y2)], Knowledge,
				[arrow(A),pos(X,Y),facing(F)],[arrow(A1),pos(X,Y),facing(F)],Fired,Fired1) :-
	(0 < A,member(stench(X,Y),Knowledge),0 < X1,Fired is 0) -> (A1 is A-1, 
	write("Firing an arrow. "), write(A1), write(' arrows remaining.\n'), Fired1 is 1,
	((X = X1, Y < Y1, F = north);(X=X1,Y>Y1,F=south);
	(X>X1,Y=Y1,F = west);(X<X1,Y=Y1,F=east)) ->
		(X2 is -100, Y2 is -100,
			write("Wumpus: AAAAAAAAAGHDGHDSKLGHG!!!\n"));
		X2 is X1, Y2 is Y1, write('Thump.\n'));
		Fired1 is 0.
		

		