import pandas as pd

# Count isomorphisms between components
def iso_classes(graph):
    iso_classes=[]
    for comp_1 in graph.connected_components_subgraphs():
        for comp_2 in graph.connected_components_subgraphs():
            if (comp_1, comp_2) and (comp_2, comp_1) not in iso_classes:
                if comp_1.is_isomorphic(comp_2):
                    iso_classes.append((comp_1, comp_2))

    return len(iso_classes)

# Count which components have automorphisms
def aut_group(graph):
    aut_count = 0
    for comp in graph.connected_components_subgraphs():
        if len(comp.automorphism_group().list()) > 0:
            aut_count += 1
    return aut_count

# Build exponential object, if show set to true, function prints graph objects, otherwise returns list of data
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
        return [len(hom_graphs.connected_components_subgraphs()), len(hom_graphs.edges()),
                len(hom_graphs.vertices()), iso_classes(hom_graphs), aut_group(hom_graphs)]

# function for iterating through graphs
def graph_iter(graph, n):
    return graph(n)

# Iterates each graph through a given number of vertices, checks all unique combinations, returns data frame
def generate_graph_data(n):
    graphs_dict = {'CycleG': graphs.CycleGraph, 'StG': graphs.StarGraph, 'CompG': graphs.CompleteGraph}
    g_data = {}

    for name1, graph1 in graphs_dict.items():
        for name2, graph2 in graphs_dict.items():
            for i in range(2,n):
                for j in range(2,n):
                    g_data['{}({})^{}({})'.format(name1, i, name2, j)] = exponential_object(graph_iter(graph1, i), graph_iter(graph2, j))

    graph_df = pd.DataFrame.from_dict(g_data, orient='index')
    graph_df.stack().reset_index()
    graph_df.rename(columns={0: 'objects', 1: 'edges', 2: 'homomorphisms', 3: 'isomorphism classes', 4: "components w aut"}, inplace=True)
    return graph_df
    
generate_graph_data(9)
