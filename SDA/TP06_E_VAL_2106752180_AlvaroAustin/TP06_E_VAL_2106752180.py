import sys
from collections import defaultdict

class Graph:
    def __init__(self, vertices = 0):
        self.graph = defaultdict(set)
        self.no_vertices = vertices
        self.in_degree = {}
        
    def add_vertices(self):
        self.no_vertices += 1

    def remove_matkul(self, matkul):
        exist = False
        for value in self.graph.values():
            try:
                value.remove(matkul)
                exist = True
            except KeyError:
                continue
        return exist

    def edit_matkul(self, u, v):
        self.graph[u].add(v)

    def add_matkul(self, u, v):
        if(self.in_degree.get(u) == None):
            return f"Matkul {u} tidak ditemukan"

        self.graph[u].add(v)

        if(self.in_degree.get(v) == None):
            self.in_degree[v] = 0
            self.add_vertices()

    def topologicalSort(self):
        # print(self.graph)
        s = sorted(self.graph)
        # print(s)
        for i in self.graph:
            self.in_degree[i] = 0

        for i in self.graph:
            for j in self.graph[i]:
                self.in_degree[j] += 1

        queue = []

        for i in s:
            # print(self.in_degree.get(i))
            if(self.in_degree[i] == 0):
                queue.append(i)
            
        result = []
        count = 0
        
        while queue:
            u = queue.pop(0) # dequeue
            result.append(u)
            
            for i in self.graph[u]:
                self.in_degree[i] -= 1
                if(self.in_degree[i] == 0):
                    queue.append(i)
            count += 1

        if(count != self.no_vertices):
            print("ada cycle")
        else:
            return result
                
graph = Graph()

while True: 
    inp = input()
    if(inp == 'EXIT'):
        sys.exit()
    else:
        inp_attr = inp.split(" ")
        perintah = inp_attr[0]
        if(perintah == "ADD_MATKUL"):
            if(len(inp_attr) == 2):
                if(graph.in_degree.get(inp_attr[1]) == None):
                    graph.add_vertices()
                    graph.in_degree[inp_attr[1]] = 0
            else:
                for i in range(2, len(inp_attr)):
                    graph.add_matkul(inp_attr[i], inp_attr[1])
        elif(perintah == "EDIT_MATKUL"):
            matkul = inp_attr[1]
            exist = graph.remove_matkul(matkul)
            if(not exist):
                print(f"Matkul {matkul} tidak ditemukan")
            else:
                for i in range(2, len(inp_attr)):
                    graph.edit_matkul(inp_attr[i], matkul)
        elif(perintah == "CETAK_URUTAN"):
            result = graph.topologicalSort()
            print(result)