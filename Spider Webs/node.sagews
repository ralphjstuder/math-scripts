class Node():

""" The purpose of this class is to build functionality for the nodes

which will be analyzed throughout various graph transformations.
"""

    def __init__(self, orig_pos, graph):
        self.orig_pos = orig_pos
        self.current_pos = orig_pos
        self.neighbors = graph.neighbors(orig_pos)
        self.avail_moves = []
        self.graph = graph

    def update_avail(self):
    """Update avialable sider moves depending on the current state of the graph."""
        self.avail_moves = []
        for neighbor in self.neighbors:
            for vertex in self.graph.vertices():
                if neighbor in self.graph.neighbors(vertex) and vertex != self.current_pos:
                    self.avail_moves.append(vertex)
        return self

    def update_position(self):
    """Update node's current position."""
    
        self.current_pos = self.avail_moves.pop()
        return self
        
