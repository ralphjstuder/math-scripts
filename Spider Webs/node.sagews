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
        self.previous_position = None
        self.update_avail()

    def update_avail(self):
    """Update avialable sider moves depending on the current state of the graph."""
        self.avail_moves = []
        for neighbor in self.graph.neighbors(self.current_pos):
            for neighb2 in self.graph.neighbors(neighbor):
                if neighb2 != self.current_pos:
                    self.avail_moves.append(neighb2)
        return self

    def update_position(self):
    """Update node's current position."""
        self.previous_position = self.current_pos
        self.current_pos = self.avail_moves.pop()
        return self
        
