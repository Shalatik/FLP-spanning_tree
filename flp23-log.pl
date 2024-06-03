% FLP 2. projekt
% Simona Ceskova xcesko00
% 27.04.2024

%include, findall, flatten, sort
%member, append, reverse, nl, maplist, include, 
%assert, call

% ----------------------------------------- input2.pl ----------------------------------------------
% prevzate nacitani souboru z input2.pl

read_line(L,C) :-
	get_char(C),
	(isEOFEOL(C), L = [], !;
		read_line(LL,_),
		[C|LL] = L).

isEOFEOL(C) :-
	C == end_of_file;
	(char_code(C,Code), Code==10).


read_lines(Ls) :-
	read_line(L,C),
	( C == end_of_file, Ls = [] ;
	  read_lines(LLs), Ls = [L|LLs]
	).
% ----------------------------------------- input2.pl ----------------------------------------------
% ----------------------------------------- RESENI ----------------------------------------------
% -------- PRIPRAVA DAT --------
%z read_lines formatu vstup na pole s kterym se bude lepe manipulovat 
format_input([], []) :- !.
format_input([X|XS], [Vextex|Others]) :-
	new_vertex(X,Vextex),
	format_input(XS, Others).

%[A, ,B] -> [A,B] smazani druheho prvku
new_vertex([], []) :- !.
	new_vertex([X|XS], New):-
	second(XS, S),
	append([X], [S], New).

%pomocne predikáty pro nalezeni tretiho prvku v puvodnim poli
second([_|XS], M):-
	third(XS, M).
second([X|_], X).
third([X|_], X).

%volani ostani predikáty, priprava dat pro dalsi manipulaci
prepare_data(Prepared):-
	%nacte radky ze vstupu
	read_lines(LL),
	%rozdeli vstup na jednotlive hrany do tvaru [A,B] \n\r [A,C]
	format_input(LL,Prepared).
% -------- PRIPRAVA DAT --------

% -------- VYPIS --------

%predikát pro vypsani vyslednych hran kostry
%postupne vola predikát line_write pro kazdy radek - jednu kostru grafu
output_write([]):- !.
	output_write([X|XS]):-
	line_write(X),
	output_write(XS).

%prevede pole na tvar s kterym se lepe pracuje pro vypis
remove_bracket([BB|_], BB).

%vypis pro kazdy radek kostry grafu podle zadani
line_write([]):-!.
%aby konec nekoncil mezerou
line_write([[A|B]]) :-
	remove_bracket(B, BB),
	%pro vypis na merlina je treba pouzit tento format
	%jinak dava znaky v ASCII
	format('~w-', A),
	format('~w\n', BB).
line_write([[A|B]|XS]) :-
	remove_bracket(B, BB),
	format('~w-', A),
	format('~w ', BB),
	line_write(XS).

% -------- VYPIS --------

% -------- ALGORITMUS --------
%[[A,B],[C,D]]->[A,B,C,D]
%pomocny predikát pro zbaveni se duplikatu koster
%prevede vice rozmerne pole do jednoho souvisleho listu
to_one_list([], Result, Result):-!.
to_one_list(_,[], []):-!.
to_one_list([X|XS], List, Result):-
	append(X, List, Temp),
	to_one_list(XS, Temp, Result).

%spocitani delky pro kazdou kostru grafu
%jeji delka musi byt = poctu vsech unikatnich vrcholu -1
% -1, protoze nechci vytvaret zadne cykly
output_length([X|XS], Len):-
	%zacnu s prazdnym polem, protoze chci vytvorit nove pole
	append(X, [], Array),
	to_one_list(XS, Array, List),
	%list_to_set vymaze duplikaty
	list_to_set(List, WithoutDupliacted),
	length(WithoutDupliacted, Len).

%behem tvoreni kombinaci se pridaji i ty, ktere neobsahuji vsechny vrcholy
remove_missing_vertexes(_,[],[]):-!.
remove_missing_vertexes(_,[],_):-!.
%pridam do seznamu jen ty co vyhovuji podmince, ze pocet vrcholu je roven poctu unikatnich vrcholu
remove_missing_vertexes(FullLen,[X|XS],[X|W]):-
	%spocita pocet vrcholu v kostre grafu
	output_length(X, Count),
	%pocet vrcholu == pocet unikatnich vrcholu -> je to kostra grafu
	Count == FullLen,
	remove_missing_vertexes(FullLen,XS, W).
%kdyz nevyhovuje podminka, tak jdu dal
remove_missing_vertexes(FullLen,[_|XS],W):-
	remove_missing_vertexes(FullLen,XS, W).	

%seradi hrany v kostrech grafu
%odstrani duplicity
sort_edges([],[]):-!.
sort_edges([X|XS],[S|Sorted]):-
	sort_vertex(X, S),
	sort_edges(XS, Sorted).

%serazeni vrcholu hran
sort_vertex([],[]):-!.
sort_vertex([X|XS], [S|Sorted]) :-
	sort(X, S),
	sort_vertex(XS, Sorted).

%pomocna promena pro prvni prvek
first([X|_], X).

%podminka, jestli oba vrcholy na jedne maji navaznost na ostatni, nebo jsou oddeleny
cond(F, S, Bool) :-
	(F =:= 1, S =:= 1) -> Bool = 0 ; Bool = 1.

%spocita kolikrat je vrchol na vsech hranach v kostre grafu
%N = hledany vrchol, X = vrcholy co prochazim
count_edges(_, [], Count, Count):-!.
%kdyz se vrchol rovna hledanemu, tak prictu 1
count_edges(N, [X|XS], C, Count) :-
	N == X,
	CN is C + 1,
	count_edges(N, XS, CN, Count).
%opacna strana podminky
count_edges(N, [X|XS], C, Count):-
	N \= X,
	CN is C,
	count_edges(N, XS, CN, Count).

%spocita se kolik hran ma navaznost na ostatni
%pokud maji navaznost tak hrana bude mit vahu 1, jestli ne tak 0
%takze vysledky Count musi byt roven poctu hran
%pokud neni roven, znamena to, ze nejaka hrana odevzdala 0, protože nenavazuje na ostatni
count_vertex([], _, Count, Count):-!.
count_vertex([X|XS], Flat, C, Count):-
	first(X, First),
	second(X, Second),
	count_edges(First, Flat, 0, FCount),
	count_edges(Second, Flat, 0, SCount),
	cond(FCount, SCount, Bool),
	CN is C + Bool,
	count_vertex(XS, Flat, CN, Count).

%pomocny predikát pro urceni, jestli se kostra prida do vyslednych grafu, nebo ne
add_cond(Count, L, X, X) :-
	Count =:= L.
add_cond(Count, L, _, []) :-
	Count \= L.

%prochazim vsechny grafy a hledam ty, ktere nejsou kostrou
unconnected([], []):-!.
unconnected([X|XS], [Add|Rest]):-!,
	length(X, L),
	%ze vsech hran je jedno pole, aby se dalo prochazet po prvcich
	flatten(X, Flat),
	count_vertex(X, Flat, 0, Count),
	%pokud graf vyhovuje a spojeny, tak je kostra grafu a prida se do seznamu grafu
	add_cond(Count, L, X, Add),
	unconnected(XS, Rest).


%podminky pro generovani moznosti kostry
skeleton_graph(_, []).
%jdu postupne po seznamu hran a pridam ji do grafu
%zbytek poslu rekurzivne zpet, aby jedna hrana nebyla v grafu vicekrat
skeleton_graph([X|XS], [X|Graph]) :-
	skeleton_graph(XS, Graph).
%timto se zaruci, ze i hrany, ktere nejsou na prvnim miste budou tvorit dalsi kombinace
skeleton_graph([_|XS], Graph) :-
	skeleton_graph(XS, Graph).

%vola predikát pro vygenerovani spanning tree
all_graphs(Edges, Len, FullLen, Connected) :-
	%tim, ze nehledam pouze jeden graf, ale vsechny tak musim pouzit predikát pro vygenerovani vsech moznych kombinaci na zaklade podminky
	%prvni podminka je length(Graph, Len) - delka kombinace musi byt N - 1 (length() vraci v tomto pripade true/false)
	%druha podminka je skeleton_graph(Elements, Graph) - jak ma vypadat vysledne pole
	findall(Graph, (length(Graph, Len), skeleton_graph(Edges, Graph)), Graphs),
	%seradi vysledne pole podle hran, odstrani duplicity
	sort_edges(Graphs, SortedEdges),
	sort(SortedEdges, Sorted),

	%zbaveni se kombinaci, kde chybi nejaky vrchol - neni to kostra grafu
	remove_missing_vertexes(FullLen, Sorted, Result),
	%zbaveni se grafu, ktere na sebe nenavazuji
	unconnected(Result,Connected).

%vygeneruje spanning tree
spanning_tree(Edges, SpanningTree) :-
	%spocita pocet unikatnich vrcholu
	output_length(Edges, FullLen),
	%Len je delka vsech vyslednych grafu
	Len is FullLen - 1,
	%pocet hran musi byt o 1 mensi nez pocet vrcholu, aby nevznikly cykly
	all_graphs(Edges, Len, FullLen, SpanningTree).

% ----------------------------------------- RESENI ----------------------------------------------



start :-
	prompt(_, ''),
	%priprava dat
	prepare_data(Prepared),
	%vytvori vsechny unikatni kombinace o delce N - 1
	spanning_tree(Prepared, SpanningTreeGraphs),
	%vypis vysledku
	output_write(SpanningTreeGraphs),
	halt.