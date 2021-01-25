class Spider():

    def __init__(self, node_list):
        self.node_list = node_list
        self.mapped_graph = Graph(loops=True)
        self.mapped_graph.add_vertex()
        self.current_state = [node.current_pos for node in self.node_list]
        self.graph_dict = {0: [node.current_pos for node in node_list]}
        self.node_counter = 1
        self.mapped_graph_pos = 0

    def update_current_state(self):
        self.current_state = []
        for node in self.node_list:
            self.current_state.append(node.current_pos)
        return self

    def update_graph_dict(self):
        self.graph_dict[self.node_counter] = self.current_state
        self.node_counter += 1
        return self
    
    def update_mapped_graph(self):
        self.mapped_graph.add_edge(self.mapped_graph_pos)
        self.mapped_graph_pos += 1
        return self

    def check_neighbors(self, node):
        node.update_avail()
        if len(node.avail_moves) > 0:
            for pos in node.avail_moves:
                count = 0
                for neighbor in node.orig_neighbors:
                    if self.node_list[neighbor].current_pos not in node.graph.neighbors(pos):
                        count += 1
                if count > 0:
                    node.avail_moves.remove(pos)
        return self
    
    def get_key(self, val):
        for key, value in self.graph_dict.items():
            if val == value:
                 return key

    def spider_move(self):
        for node in self.node_list:
            self.check_neighbors(node)
            if len(node.avail_moves) > 0:
                self.previous_move['last'].append(node.current_pos)
                node.update_position()
                self.previous_move['last']append(node.current_pos)
                self.update_current_state()
                if self.current_state not in self.graph_dict.values():
                    self.update_graph_dict()
                    break
                else:
                    self.mapped_graph.add_edge(get_key(self.current_state), self.mapped_graph_pos)
                    node.current_pos = node.previous_position
                    continue
        return self

    def reset_graph(self):
        for node in self.node_list:
            node.current_pos = node.orig_pos
        return self

    def spider_web(self):
        self.reset_graph()
        while self.current_state != self.graph_dict[0]:
            for node in self.node_list:
                self.check_neighbors(node)
                for pos in node.avail_moves:
                    self.mapped_graph.add_edge(self.mapped_graph_pos)
            self.mapped_graph_pos += 1
            self.spider_move()
        return self.mapped_graph
