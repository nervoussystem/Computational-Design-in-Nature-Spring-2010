class Face {
  ArrayList edges;
  
  Face() {
    edges = new ArrayList();
  }
  
  Edge getEdge(int i) {
    return (Edge) edges.get(i);
  }
}

class Edge {
  Spring s;
  Edge e1, e2;
  Particle midPt = null;
  
  Edge(Spring s) {
    this.s = s;
  }
}
