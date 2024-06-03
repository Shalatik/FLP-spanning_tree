Simona Češková xcesko00  
FLP 2023/2024 – logický projekt: Kostra grafu  
27.04.2024

# Popis použité metody řešení
Pro řešení jsem inspirovala aplikací Kruskalova algortimu k nalezení minimální kostry grafu: [Kruskal](https://www.geeksforgeeks.org/kruskals-minimum-spanning-tree-algorithm-greedy-algo-2/).  
Vygenerovala jsem si všechny kombinace grafů pomocí prolog predikátu ``findall/3`` v mé ``all_graphs/4`` funkci pomocí podmínek pro generování ``skeleton_graph/2``. Vygenerování kombinací funguje na principu, že procházím pole zadaných hran a postupně k nim přiřazuji další hrany, dokud nevnikne 2D podle (jeden graf) o délce rovné počtu všech unikátních vrcholů - 1.  
Aplikovala jsem Kruskalův algoritmus reverzně: postupně jsem prošla každý nově vzniklý graf a hledala ty, které nesplňují podmínky kostry grafu - neboli ty, které tvořili nějakým stylem cyklus. K tomuto sloužily predikáty:
1) ``remove_missing_vertexes/3`` - odstranění grafů, které neobsahují všechny vrcholy (neboli obsahují malý cyklus). Predikát funguje na principu, že spočítá všechny unikátní vrcholy vstupního grafu. Poté spočítá všechny unikátní vrcholy v nově vzniklých grafech. Pokud se tento počet nerovná, tak se nejedná o kostru grafu.
2) ``sort_edges/2`` - odstranění stejných grafů seřazením vrcholů ``[B,A] -> [A,B]`` s spoluprácí pomocného predikát ``sort_vertex/2``.
3) ``unconnected/2`` - odstranění grafů, které na sebe nenavazují ``[[A,B],[C,D]]``. Funguje na principu, že spočítá kolikrát se nějaký vrchol vyskytuje v grafu pomocí ``count_edges/4``. Poté vezme hranu, pokud oba vrcholy na jedné hraně se vyskytly v grafu pouze jedenkrát (``cond/3``), tak potom jsou odpojené od zbytku a netvoří souvislý graf (``add_cond/4``).

## Struktura projektu
Řešení se skládá ze tří hlavních funkcí, které volají celý zbytek programu:
1) prepare_data() - zavolání všech funkcí, které na začátku upraví vstup po vhodné podoby
2) spanning_tree() - tato predikát má 2 úlohy - zavolat vygenerování kombinací grafů a jejich následné zredukování jen na kostry grafu
3) output_write() - predikát pro formátování konečného výstupu

# Návod k použití
``input.txt``: vstupní soubor s jedním grafem ve formátu:
```
A B
A C
A D
B C
C D
```
  
``output.txt``: výsledný soubor s vygenerovanými kostry grafu
```
make
./flp23-log <input.txt >output.txt
```
# Omezení
Pro složité grafy můj algoritmus není schopný detekovat všechny cykly. Snažila jsem se vytvořit funkci, která by toho byla schopná, ale nepovedlo se mně to. Místo toho jsem alespoň vytvořila výše uvedeného predikátu, které se snaží co nejlépe nahradit tento fakt a dokáží pracovat s velkou většinou případů korektně. Z tohoto důvodu očekávám, že pro složité grafy, se naskytnou kostry grafu navíc.

# Testování
Přiložila jsem 3 testovací soubory, jeden ze zadání (``1input.txt``) pro porovnání času a další dva co jsem vytvořila. Merlin časy výpočtu:  
1) ``1input.txt``  
real    0m0.015s  
user    0m0.010s  
sys     0m0.003s   
2) ``2input.txt``   
real    0m0.013s  
user    0m0.009s  
sys     0m0.002s  
3) ``3input.txt``  
real    0m0.015s  
user    0m0.009s  
sys     0m0.005s  
