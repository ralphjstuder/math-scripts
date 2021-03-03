import pandas as pd

# Count isomorphisms between components
def iso_classes(graph):
    components = {}
    set_list = []
    iso_classes_dict = {}
    count = 1
    for comp in graph.connected_components_subgraphs():
        components[count] = comp
        iso_classes_dict[count] = set()
        count += 1

    for num, graph in components.items():
        for num2, graph2 in components.items():
            if graph.is_isomorphic(graph2):
                iso_classes_dict[num].add(num2)

    for val in iso_classes_dict.values():
        if val not in set_list:
            set_list.append(val)

    return len(set_list)

# Count which components have automorphisms
def aut_group(graph):
    aut_count = 0
    for comp in graph.connected_components_subgraphs():
        if len(comp.automorphism_group().list()) > 0:
            aut_count += 1
    return aut_count

# Build exponential object, if show set to true, function prints graph objects, otherwise returns data from subgraph of homomorphisms
def exponential_object(G, H, show=False):
    set_map = FiniteSetMaps(G.vertices(), H.vertices())
    exp_G_to_H = Graph(loops=True)
    exp_G_to_H.add_vertices(set_map)
    homomorphisms = Graph(loops=True)

    for f in set_map:
        for g in set_map:
            if (f, g, None) not in exp_G_to_H:
                edge = True
                for e in G.edges():
                    if ((f(e[0]), g(e[1]), None) not in H.edges()) or ((f(e[1]), g(e[0]), None) not in H.edges()):
                        edge = False
                if edge:
                    exp_G_to_H.add_edges([(f, g)])
                    if f == g:
                        homomorphisms.add_vertices([f])
    hom_graphs = exp_G_to_H.subgraph(homomorphisms)

    if show:
        hom_graphs.show(figsize=[100,4],dpi=100)
    else:
        return hom_graphs
   
def get_data(graph):
    return [len(graph.connected_components_subgraphs()), len(graph.edges()),
            len(graph.vertices()), iso_classes(graph)]

# function for iterating through graphs
def graph_iter(graph, n):
    return graph(n)

# Iterates each graph through a given number of vertices, checks all unique combinations, returns data frame
def generate_graph_data(n):
    graphs_dict = {'CycleG': graphs.CycleGraph, 'PathG': graphs.PathGraph, 'CompG': graphs.CompleteGraph}
    g_data = {}

    for name1, graph1 in graphs_dict.items():
        for name2, graph2 in graphs_dict.items():
            for i in range(2,n):
                for j in range(2,n):
                    g_data['{}({})^{}({})'.format(name1, i, name2, j)] = get_data(exponential_object(graph_iter(graph1, i), graph_iter(graph2, j)))

    graph_df = pd.DataFrame.from_dict(g_data, orient='index')
    graph_df.stack().reset_index()
    graph_df.rename(columns={0: 'objects', 1: 'edges', 2: 'homomorphisms', 3: 'isomorphism classes', 4: "components w aut"}, inplace=True)
    return graph_df

# Isolate spider moves within exponential graph
def spider_web(graph1, graph2):
    exp = exponential_object(graph1, graph2)
    for f in exp:
        for g in exp:
            count = 0
            for num in range(len(f)):
                if f[num] != g[num]:
                    count += 1
            if count > 1:
                exp.delete_edges([(f,g)])
    exp.show(figsize=[100,4],dpi=100)
    
 # Find the factor group: automorphism group/automorphisms spiderable to the identity
def factor_group(graph1):
    null_g = []
    aut_g = graph1.automorphism_group()

    for comp in spider_web(graph1, graph1).connected_components_subgraphs():
        vert_list = []
        for mapping in comp.vertices():
            vert_list.append(mapping[:])

        if graph1.vertices() in vert_list:
            count = 1
            for aut in aut_g:
                aut_dict = aut.dict()
                aut_vals = [x for x in aut_dict.values()]
                if aut_vals in vert_list and aut_vals != graph1.vertices():
                    count += 1
                    null_g.append(str(aut))

            for num in range(2, len(null_g)):
                if null_g[1] or null_g[2] in null_g[num]:
                    null_g.remove(null_g[num])

            if count == len(aut_g):
                null_g = aut_g
            elif count <= 1:
                return aut_g
            else:
                null_g = PermutationGroup(null_g)

    if len(null_g) < 1:
        return aut_g
    else:
        return aut_g.quotient(null_g)

# Find the graph's stiff form
def pleat(graph):
    for vert in graph.vertices():
        orig_neighbors = graph.neighbors(vert)
        for neighbor in orig_neighbors:
            moves = [x for x in graph.neighbors(neighbor) if x != vert and set(orig_neighbors).issubset(graph.neighbors(x))]
            if len(moves) > 0:
                try:
                    graph.delete_vertex(vert)
                except:
                    ValueError
                    pass

    count = 0
    for vert in graph.vertices():
        moves = []
        for neighb in graph.neighbors(vert):
            for neighb2 in graph.vertices(neighb):
                if neighb2 != vert and set(graph.neighbors(vert)).issubset(graph.neighbors(neighb2)):
                    moves.append(neighb2)
        if len(moves) == 0:
            count += 1

    if count != len(graph.vertices()):
        return pleat(graph)
    else:
        return graph
    
    # Find injective homomorphism from graph to stiff form
    def injective_hom(graph):
    inj_hom = {}
    for vert in graph.vertices():
        inj_hom[vert] = vert

    for vert in graph.vertices():
        orig_neighbors = graph.neighbors(vert)
        avail_moves = []
        for neighbor in orig_neighbors:
            moves = [x for x in graph.neighbors(neighbor) if x != vert and x != neighbor]
            avail_moves.extend(moves)
        if len(avail_moves) > 0:
            spider = moves.pop()
            inj_hom[vert] = spider
            graph.delete_vertex(vert)
            for key, val in inj_hom.items():
                if key != vert and val == vert:
                    inj_hom[key] = spider

    no_moves_count = 0
    for vert in graph.vertices():
        moves = []
        for neighb in graph.neighbors(vert):
            for neighb2 in graph.vertices(neighb):
                if neighb2 != vert and neighb2 != neighb:
                    moves.append(neighb2)
        if len(moves) == 0:
            no_moves_count += 1

    if no_moves_count != len(graph.vertices()):
        return injective_hom(graph)
    else:
        return inj_hom

