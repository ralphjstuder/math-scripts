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
            node.current_pos
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
                for neighbor in node.orig_neighbors:
                    if self.node_list[neighbor].current_pos not in node.graph.neighbors(pos):
                        check = False
                        break
                    else:
                        check = True
                if not check:
                    try:
                        node.avail_moves.remove(pos)
                    except ValueError:
                        pass
                if pos == node.orig_pos:
                    try:
                        node.avail_moves.remove(pos)
                    except ValueError:
                        pass
        else:
            pass

        return self

    def spider_move(self):
        for node in self.node_list:
            self.check_neighbors(node)
            if len(node.avail_moves) > 0:
                node.update_position()
                self.update_current_state()
                if self.current_state in self.graph_dict.values():
                    node.current_pos = node.previous_position
                    continue
                else:
                    node.update_position()
                    self.update_current_state()
                    break
        return self

    def reset_graph(self):
        for node in self.node_list:
            node.current_pos = node.orig_pos
        return self

    def spider_web(self):
        self.reset_graph()
        for node in self.node_list:
            self.check_neighbors(node)

        for node in self.node_list:
            for pos in node.avail_moves:
                self.mapped_graph.add_edge(self.mapped_graph_pos)
        self.mapped_graph_pos += 1
