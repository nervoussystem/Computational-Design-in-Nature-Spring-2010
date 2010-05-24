/*
  Delaunay Triangulation code by... someone else.  I should properly attribute this if I can find it
  Feel free to ignore this code.
*/

Simplex simplex = new Simplex(new Pnt[0]);
Pnt pnt = new Pnt(0,0);

public class DelaunayTriangulation extends Triangulation {

  private Simplex mostRecent = null;       // Most recently inserted triangle
  public boolean debug = false;            // Used for debugging

  /**
   * Constructor.
   * All sites must fall within the initial triangle.
   * @param triangle the initial triangle
   */
  public DelaunayTriangulation (Simplex triangle) {
    super(triangle);
    mostRecent = triangle;
  }
  
  public DelaunayTriangulation (DelaunayTriangulation _dt) {
    this.neighbors = (HashMap) _dt.neighbors.clone();
    this.ptSimplex = (HashMap) _dt.ptSimplex.clone();
    this.mostRecent = _dt.mostRecent;
  }

  /**
   * Locate the triangle with point (a Pnt) inside (or on) it.
   * @param point the Pnt to locate
   * @return triangle (Simplex<Pnt>) that holds the point; null if no such triangle
   */
  public Simplex locate (Pnt point, Simplex guess) {
    return locateOld(point, guess);
    //if(dt.size() < 0) 
    //else {
    //  //Simplex s = locateGrid(point);
    //  Simplex s = point_locate(point, null);
    //  if(s == null) println("FUCK!!!!!!!!!!");
    //  return s;
    //}
  }

  private Simplex locateOld(Pnt point, Simplex guess) {
    //Simplex triangle = mostRecent;
    if(guess == null)
      guess = closest_face(point);
    Simplex triangle = guess;
    Simplex previousT = guess;
    //if (!this.contains(triangle)) triangle = null;

    // Try a directed walk (this works fine in 2D, but can fail in 3D)
    Set visited = new HashSet();
    while (triangle != null) {
      if (visited.contains(triangle)) { // This should never happen
        //System.out.println("Warning: Caught in a locate loop");
        break;
      }
      visited.add(triangle);
      // Corner opposite point
      Pnt corner = point.isOutside((Pnt[]) triangle.toArray(new Pnt[0]));
      if (corner == null) return triangle;
      previousT = triangle;
      triangle = this.neighborOpposite(corner, triangle);
    }
    // No luck; try brute force
    LinkedList waitingQ = new LinkedList();
    visited.clear();
    Pnt startP;

    if(triangle == null) {
      waitingQ.addAll(neighbors(previousT));
      visited.add(previousT);
      startP = triangle_barycenter(previousT);
    } else { 
      waitingQ.addAll(neighbors(triangle));
      visited.add(triangle);
      startP = triangle_barycenter(triangle);
    }
    visited.addAll(waitingQ);
    //float minDistSq = sq(startP.x()-point.x())+sq(startP.y()-point.y());
    while(!waitingQ.isEmpty()) {
      Simplex s = (Simplex) waitingQ.removeFirst();
      if (point.isOutside((Pnt[]) s.toArray(new Pnt[0])) == null) return s;
      Set neigh = neighbors(s);
      Pnt centC = triangle_barycenter(s);
      //float distSq =  sq(centC.x()-point.x())+sq(centC.y()-point.y());
      //if(distSq < minDistSq+sq(killD)) {
        for(Iterator it = neigh.iterator();it.hasNext();) {
          Simplex s2 = (Simplex) it.next();
          if(!visited.contains(s2)) {
            waitingQ.add(s2);
            visited.add(s2);
          }
        }
      //}
      visited.add(s);
    }
    println("WARNING: NO TRIANGLE " + visited.size() + " " + this.size());
    return null;
    /*
    System.out.println("Warning: Checking all triangles for " + point); 
    for (Iterator it = this.iterator(); it.hasNext();) {
      Simplex tri = (Simplex) it.next();
      if (point.isOutside((Pnt[]) tri.toArray(new Pnt[0])) == null) return tri;
    }
    
    // No such triangle
    System.out.println("Warning: No triangle holds " + point);
    return null;
    */
  }

  /**
   * Place a new point site into the DT.
   * @param site the new Pnt
   * @return set of all new triangles created
   */
  public Set delaunayPlace (Pnt site, Simplex guess) {
    Set newTriangles = new HashSet();
    Set oldTriangles = new HashSet();
    Set doneSet = new HashSet();
    LinkedList waitingQ = new LinkedList();
    // Locate containing triangle
    if (debug) System.out.println("Locate");
    Simplex triangle = locate(site, guess);
    //locateTime += millis()-start;
    // Give up if no containing triangle or if site is already in DT
    if (triangle == null || triangle.contains(site)) {
      return newTriangles;
    }

    // Find Delaunay cavity (those triangles with site in their circumcircles)
    if (debug) System.out.println("Cavity");
    //start = millis();
    waitingQ.add(triangle);
    while (!waitingQ.isEmpty()) {
      triangle = (Simplex) waitingQ.removeFirst();      
      if (site.vsCircumcircle((Pnt[]) triangle.toArray(new Pnt[0])) == 1) continue;
      oldTriangles.add(triangle);
      Iterator it = this.neighbors(triangle).iterator();
      for (; it.hasNext();) {
        Simplex tri = (Simplex) it.next();
        if (doneSet.contains(tri)) continue;
        doneSet.add(tri);
        waitingQ.add(tri);
      }
    }
    // Create the new triangles
    if (debug) System.out.println("Create");
    for (Iterator it = simplex.boundary(oldTriangles).iterator(); it.hasNext();) {
      Set facet = (Set) it.next();
      facet.add(site);
      if(facet.size() < 3) return new HashSet();
      Pnt[] pnts = (Pnt[]) facet.toArray(new Pnt[0]);
      float orient = point_orient(pnts[0], pnts[1], pnts[2]);
      if(orient < 0) {
        Pnt temp = pnts[1];
        pnts[1] = pnts[2];
        pnts[2] = temp;
      }
      newTriangles.add(new Simplex(pnts));
    }
    // Replace old triangles with new triangles
    if (debug) System.out.println("Update");
    this.update(oldTriangles, newTriangles);
    //insertTime += millis()-start;

    // Update mostRecent triangle
    if (!newTriangles.isEmpty()) mostRecent = (Simplex) newTriangles.iterator().next();
    return newTriangles;
  }

  private Pnt triangle_barycenter (Simplex s)
  {
    float x = 0;
    float y = 0;
    for(Iterator it = s.iterator();it.hasNext();) {
      Pnt p = (Pnt) it.next();
      x += p.x();
      y += p.y();
    }
    x /= 3.0;
    y /= 3.0;
    return new Pnt(x,y);
  }
  
  private Simplex closest_face(Pnt p) {
    Iterator it = this.iterator();
    Simplex minSim = (Simplex) it.next();
    Pnt cent = triangle_barycenter(minSim);
    float minDist = sq(p.x()-cent.x())+sq(p.y()-cent.y());
    int maxSkip = int(this.size()/sqrt(sqrt(this.size())));
    while(it.hasNext()) {
      float skip = random(1, maxSkip);
      Simplex curr = null; 
      for(int j=0;it.hasNext() && j < skip-1;++j) curr = (Simplex) it.next();
      cent = triangle_barycenter(curr);
      float d =  sq(p.x()-cent.x())+sq(p.y()-cent.y());
      if(d < minDist) {
        minDist = d;
        minSim = curr;
      }
    }
    return minSim;
  }

/*
  private Simplex locateGrid(Pnt point) {
    int xInd = int(point.x()/gridSize);
    int yInd = int(point.y()/gridSize);
    println(xInd + ", " + yInd);
    ArrayList toSearch = new ArrayList();
    toSearch.addAll(ptGrid[xInd][yInd]);
    toSearch.addAll(getSearch(xInd,yInd,1));
    if(toSearch.size() == 0) toSearch = getSearch(xInd,yInd,2);
    Pnt minPt = null;
    float minDist = 9999999;
    for(Iterator it = toSearch.iterator();it.hasNext();) {
      Pnt curr = (Pnt) it.next();
      float d = sq(point.x()-curr.x())+sq(point.y()-curr.y());
      if(d < minDist) {
        minPt = curr;
        minDist = d;
      }
    }
    return simplex;
  }

  ArrayList getSearch(int xInd, int yInd, int dist) {
    int lowX = xInd-dist;
    int lowY = yInd-dist;
    int highX = xInd+dist;
    int highY = yInd+dist;
    ArrayList search = new ArrayList();

    if(lowX >= 0) {
      for(int i=max(0,lowY+1);i<=min(highY,ptGrid.length-1);++i) {
        search.addAll(ptGrid[lowX][i]);
      }
    }
    if(highX < ptGrid.length) {
      for(int i=min(highY-1,ptGrid.length-1);i>=max(0,lowY);--i) {
        search.addAll(ptGrid[highX][i]);
      }
    }
    if(lowY >= 0) {
      for(int i=max(0,lowX);i<=min(highX-1,ptGrid.length-1);++i) {
        search.addAll(ptGrid[i][lowY]);
      }
    }
    if(highY < ptGrid.length) {
      for(int i=max(lowX+1,0);i>=min(ptGrid.length-1,highX);++i) {
        search.addAll(ptGrid[i][highY]);
      }
    }
    return search;      
  }
  */
  
  private float point_orient(Pnt p1, Pnt p2, Pnt p3) {
    return p1.x()*p2.y()-p2.x()*p1.y()+p3.x()*p1.y()-p3.x()*p2.y()-p1.x()*p3.y()+p2.x()*p3.y();
  }

  /*Set boundary(Collection removePts) {
    Set theBoundary = new HashSet(this.size());
    for(Iterator it = this.iterator();it.hasNext();) {
      Simplex s = (Simplex) it.next();
      if(!containsAny(s,removePts)  && maxEdge(s) < birthD*10) {
        for (Iterator otherIt = s.facets().iterator(); otherIt.hasNext();) {
          Set facet = (Set) otherIt.next();
          if (theBoundary.contains(facet)) theBoundary.remove(facet);
             else theBoundary.add(facet);
        }
      }
    }
    return theBoundary;
  }*/
}

float maxEdge(Simplex s) {
  float maxE = 0;
  Iterator it = s.iterator();
  Pnt prev = (Pnt) it.next();
  Pnt first = prev;
  while(it.hasNext()) {
    Pnt curr = (Pnt) it.next();
    float d2 = curr.distSq(prev);
    if(d2 > maxE) maxE = d2;
    prev = curr;
  }
  float d2 = first.distSq(prev);
  if(d2 > maxE) maxE = d2;
  return sqrt(maxE);
}

boolean containsAny(Collection col, Collection search) {
  for(Iterator it = search.iterator();it.hasNext();) {
    if(col.contains(it.next())) return true;
  }
  return false;
}

public class Triangulation {
    protected HashMap neighbors;  // Maps Simplex to Set of neighbors
    protected HashMap ptSimplex;
    /**
     * Constructor.
     * @param simplex the initial Simplex.
     */
    public Triangulation (Simplex simplex) {
        neighbors = new HashMap();
        neighbors.put(simplex, new HashSet());
        ptSimplex = new HashMap();
        for(Iterator it = simplex.iterator();it.hasNext();) {
          Pnt p = (Pnt) it.next();
          HashSet hs = new HashSet();
          hs.add(simplex);
          ptSimplex.put(p, hs);
        }
    }
    
    public Triangulation() {
      
    }
    
    /**
     * String representation.
     * Shows number of simplices currently in the Triangulation.
     * @return a String representing the Triangulation
     */
    public String toString () {
        return "Triangulation (with " + neighbors.size() + " elements)";
    }
    
    /**
     * Size (# of Simplices) in Triangulation.
     * @return the number of Simplices in this Triangulation
     */
    public int size () {
        return neighbors.size();
    }
    
    /**
     * True iff the simplex is in this Triangulation.
     * @param simplex the simplex to check
     * @return true iff the simplex is in this Triangulation
     */
    public boolean contains (Simplex simplex) {
        return this.neighbors.containsKey(simplex);
    }
    
    /**
     * Iterator.
     * @return an iterator for every Simplex in the Triangulation
     */
    public Iterator iterator () {
        return Collections.unmodifiableSet(this.neighbors.keySet()).iterator();
    }
    
    /**
     * Print stuff about a Triangulation.
     * Used for debugging.
     */
    public void printStuff () {
        System.out.println("Neighbor data for " + this);
        for (Iterator it = neighbors.keySet().iterator(); it.hasNext();) {
            Simplex simplex = (Simplex) it.next();
            System.out.print("    " + simplex + ":");
            for (Iterator otherIt = ((Set) neighbors.get(simplex)).iterator(); 
                 otherIt.hasNext();)
                System.out.print(" " + otherIt.next());
            System.out.println();
        }
    }
    
    /* Navigation */
    
    /**
     * Report neighbor opposite the given vertex of simplex.
     * @param vertex a vertex of simplex
     * @param simplex we want the neighbor of this Simplex
     * @return the neighbor opposite vertex of simplex; null if none
     * @throws IllegalArgumentException if vertex is not in this Simplex
     */
     public Simplex neighborOpposite (Object vertex, Simplex simplex) {
        if (!simplex.contains(vertex))
            throw new IllegalArgumentException("Bad vertex; not in simplex");
        for (Iterator it = ((Set) neighbors.get(simplex)).iterator(); 
                          it.hasNext();) {
            Simplex s = (Simplex) it.next();
            if(! s.contains(vertex)) return s;
        }
        return null;
    }

     /*
    public Simplex neighborOpposite (Object vertex, Simplex simplex) {
        if (!simplex.contains(vertex))
            throw new IllegalArgumentException("Bad vertex; not in simplex");
        SimplexLoop: for (Iterator it = ((Set) neighbors.get(simplex)).iterator(); 
                          it.hasNext();) {
            Simplex s = (Simplex) it.next();
            for (Iterator otherIt = simplex.iterator(); otherIt.hasNext(); ) {
                Object v = otherIt.next();
                if (v.equals(vertex)) continue;
                if (!s.contains(v)) continue SimplexLoop;
            }
            return s;
        }
        return null;
    }
    */
    
    /**
     * Report neighbors of the given simplex.
     * @param simplex a Simplex
     * @return the Set of neighbors of simplex
     */
    public Set neighbors (Simplex simplex) {
      if(simplex == null) println(simplex);
      return new HashSet((Set) this.neighbors.get(simplex));
    }
    
    public Set triangles(Pnt p) {
      //println(p);
      return new HashSet((Set) this.ptSimplex.get(p));
    }
    
    /* Modification */
    
    /**
     * Update by replacing one set of Simplices with another.
     * Both sets of simplices must fill the same "hole" in the
     * Triangulation.
     * @param oldSet set of Simplices to be replaced
     * @param newSet set of replacement Simplices
     */
    public void update (Set oldSet, 
                        Set newSet) {
        // Collect all simplices neighboring the oldSet
        Set allNeighbors = new HashSet();
        for (Iterator it = oldSet.iterator(); it.hasNext();)
            allNeighbors.addAll((Set) neighbors.get((Simplex) it.next()));
        // Delete the oldSet
        for (Iterator it = oldSet.iterator(); it.hasNext();) {
            Simplex simplex = (Simplex) it.next();
            for (Iterator otherIt = ((Set) neighbors.get(simplex)).iterator();otherIt.hasNext();)
                ((Set) neighbors.get(otherIt.next())).remove(simplex);
            for(Iterator it2 = simplex.iterator();it2.hasNext();) {
              Pnt p = (Pnt) it2.next();
              HashSet hs = (HashSet) ptSimplex.get(p);
              hs.remove(simplex);
            }
            neighbors.remove(simplex);
            allNeighbors.remove(simplex);
        }
        // Include the newSet simplices as possible neighbors
        allNeighbors.addAll(newSet);
        // Create entries for the simplices in the newSet
        for (Iterator it = newSet.iterator(); it.hasNext();)
            neighbors.put((Simplex) it.next(), new HashSet());
        // Update all the neighbors info
        for (Iterator it = newSet.iterator(); it.hasNext();) {
            Simplex s1 = (Simplex) it.next();
            for (Iterator otherIt = allNeighbors.iterator(); otherIt.hasNext();) {
                Simplex s2 = (Simplex) otherIt.next();
                if (!s1.isNeighbor(s2)) continue;
                ((Set) neighbors.get(s1)).add(s2);
                ((Set) neighbors.get(s2)).add(s1);
            }
            for(Iterator it2 = s1.iterator();it2.hasNext();) {
              Pnt p = (Pnt) it2.next();
              HashSet hs;
              boolean cont = ptSimplex.containsKey(p);
              if(cont)
                hs = (HashSet) ptSimplex.get(p);
              else 
                hs = new HashSet();
              hs.add(s1);
              if(!cont) ptSimplex.put(p,hs);
            }
        }
    }
}

long idGenerator = 0;
class Simplex extends AbstractSet implements Set {
    
    private java.util.List vertices;                  // The simplex's vertices
    private long idNumber;                  // The id number
    
    /**
     * Constructor.
     * @param collection a Collection holding the Simplex vertices
     * @throws IllegalArgumentException if there are duplicate vertices
     */
     public Simplex() {
       
     }
     
    public Simplex (Collection collection) {
        this.vertices = Collections.unmodifiableList(new ArrayList(collection));
        this.idNumber = idGenerator++;
        Set noDups = new HashSet(this);
        if (noDups.size() != this.vertices.size())
            throw new IllegalArgumentException("Duplicate vertices in Simplex");
    }
    
    /**
     * Constructor.
     * @param vertices the vertices of the Simplex.
     * @throws IllegalArgumentException if there are duplicate vertices
     */
    public Simplex (Object[] vertices) {
        this(Arrays.asList(vertices));
    }
    
    /**
     * String representation.
     * @return the String representation of this Simplex
     */
    public String toString () {
        return "Simplex" + idNumber + super.toString();
    }
    
    /**
     * Dimension of the Simplex.
     * @return dimension of Simplex (one less than number of vertices)
     */
    public int dimension () {
        return this.vertices.size() - 1;
    }
    
    /**
     * True iff simplices are neighbors.
     * Two simplices are neighbors if they are the same dimension and they share
     * a facet.
     * @param simplex the other Simplex
     * @return true iff this Simplex is a neighbor of simplex
     */
    public boolean isNeighbor (Simplex simplex) {
      
        HashSet h = new HashSet(this);
        h.removeAll(simplex);
        return (this.size() == simplex.size()) && (h.size() == 1);
    }
    
    /**
     * Report the facets of this Simplex.
     * Each facet is a set of vertices.
     * @return an Iterable for the facets of this Simplex
     */
    public java.util.List facets () {
        java.util.List theFacets = new LinkedList();
        for (Iterator it = this.iterator(); it.hasNext();) {
            Object v = it.next();
            Set facet = new HashSet(this);
            facet.remove(v);
            theFacets.add(facet);
        }
        return theFacets;
    }
    
    /**
     * Report the boundary of a Set of Simplices.
     * The boundary is a Set of facets where each facet is a Set of vertices.
     * @return an Iterator for the facets that make up the boundary
     */
    public Set boundary (Set simplexSet) {
        Set theBoundary = new HashSet();
        for (Iterator it = simplexSet.iterator(); it.hasNext();) {
            Simplex simplex = (Simplex) it.next();
            for (Iterator otherIt = simplex.facets().iterator(); otherIt.hasNext();) {
                Set facet = (Set) otherIt.next();
                if (theBoundary.contains(facet)) theBoundary.remove(facet);
                else theBoundary.add(facet);
            }
        }
        return theBoundary;
    }
    
    /* Remaining methods are those required by AbstractSet */
    
    /**
     * @return Iterator for Simplex's vertices.
     */
    public Iterator iterator () {
        return this.vertices.iterator();
    }
    
    /**
     * @return the size (# of vertices) of this Simplex
     */
    public int size () {
        return this.vertices.size();
    }
    
    /**
     * @return the hashCode of this Simplex
     */
    public int hashCode () {
        return (int)(idNumber^(idNumber>>>32));
    }
    
    /**
     * We want to allow for different simplices that share the same vertex set.
     * @return true for equal Simplices
     */
    public boolean equals (Object o) {
        return (this == o);
    }
}

public class Pnt {
    
    float[] coordinates;          // The point's coordinates
    
    /**
     * Constructor.
     * @param coords the coordinates
     */
    public Pnt (float[] coords) {
        // Copying is done here to ensure that Pnt's coords cannot be altered.
        coordinates = new float[coords.length];
        System.arraycopy(coords, 0, coordinates, 0, coords.length);
    }
    
    /**
     * Constructor.
     * @param coordA
     * @param coordB
     */
    public Pnt (float coordA, float coordB) {
        this(new float[] {coordA, coordB});
    }
    
    /**
     * Constructor.
     * @param coordA
     * @param coordB
     * @param coordC
     */
    public Pnt (float coordA, float coordB, float coordC) {
        this(new float[] {coordA, coordB, coordC});
    }
    
    /**
     * Create a String for this Pnt.
     * @return a String representation of this Pnt.
     */
    public String toString () {
        if (coordinates.length == 0) return "()";
        String result = "Pnt(" + coordinates[0];
        for (int i = 1; i < coordinates.length; i++)
            result = result + "," + coordinates[i];
        result = result + ")";
        return result;
    }
    
    /**
     * Equality.
     * @param other the other Object to compare to
     * @return true iff the Pnts have the same coordinates
     */
    public boolean equals (Object other) {
        if (!(other instanceof Pnt)) return false;
        Pnt p = (Pnt) other;
        if (this.coordinates.length != p.coordinates.length) return false;
        for (int i = 0; i < this.coordinates.length; i++)
            if (this.coordinates[i]!=p.coordinates[i]) return false;
        return true;
    }
    
    /**
     * HashCode.
     * @return the hashCode for this Pnt
     */
    public int hashCode () {
        int hash = 0;
        for (int i = 0; i < this.coordinates.length; i++) {
            int bits = Float.floatToIntBits(this.coordinates[i]);
            hash = (31*hash) ^ (int)(bits ^ (bits >> 32));
        }
        return hash;
    }
    
    /* Pnts as vectors */
    
    /**
     * @return the specified coordinate of this Pnt
     * @throws ArrayIndexOutOfBoundsException for bad coordinate
     */
    public float coord (int i) {
        return this.coordinates[i];
    }
    
    public float x() {
      return this.coordinates[0];
    }

    public float y() {
      return this.coordinates[1];
    }
    
    /**
     * @return this Pnt's dimension.
     */
    public int dimension () {
        return coordinates.length;
    }
    
    /**
     * Check that dimensions match.
     * @param p the Pnt to check (against this Pnt)
     * @return the dimension of the Pnts
     * @throws IllegalArgumentException if dimension fail to match
     */
    public int dimCheck (Pnt p) {
        int len = this.coordinates.length;
        if (len != p.coordinates.length)
            throw new IllegalArgumentException("Dimension mismatch");
        return len;
    }
    
    /**
     * Create a new Pnt by adding additional coordinates to this Pnt.
     * @param coords the new coordinates (added on the right end)
     * @return a new Pnt with the additional coordinates
     */
    public Pnt extend (float[] coords) {
        float[] result = new float[coordinates.length + coords.length];
        System.arraycopy(coordinates, 0, result, 0, coordinates.length);
        System.arraycopy(coords, 0, result, coordinates.length, coords.length);
        return new Pnt(result);
    }
    
    /**
     * Dot product.
     * @param p the other Pnt
     * @return dot product of this Pnt and p
     */
    public float dot (Pnt p) {
        int len = dimCheck(p);
        float sum = 0;
        for (int i = 0; i < len; i++)
            sum += this.coordinates[i] * p.coordinates[i];
        return sum;
    }
    
    /**
     * Magnitude (as a vector).
     * @return the Euclidean length of this vector
     */
    public float magnitude () {
        return (float) Math.sqrt(this.dot(this));
    }
    
    /**
     * Subtract.
     * @param p the other Pnt
     * @return a new Pnt = this - p
     */
    public Pnt subtract (Pnt p) {
        int len = dimCheck(p);
        float[] coords = new float[len];
        for (int i = 0; i < len; i++)
            coords[i] = this.coordinates[i] - p.coordinates[i];
        return new Pnt(coords);
    }
    
    /**
     * Add.
     * @param p the other Pnt
     * @return a new Pnt = this + p
     */
    public Pnt add (Pnt p) {
        int len = dimCheck(p);
        float[] coords = new float[len];
        for (int i = 0; i < len; i++)
            coords[i] = this.coordinates[i] + p.coordinates[i];
        return new Pnt(coords);
    }

    public Pnt add (float x, float y) {
        return new Pnt(coordinates[0]+x,coordinates[1]+y);
    }
    
    /**
     * Angle (in radians) between two Pnts (treated as vectors).
     * @param p the other Pnt
     * @return the angle (in radians) between the two Pnts
     */
    public float angle (Pnt p) {
        return (float) Math.acos(this.dot(p) / (this.magnitude() * p.magnitude()));
    }
    
    /**
     * Perpendicular bisector of two Pnts.
     * Works in any dimension.  The coefficients are returned as a Pnt of one
     * higher dimension (e.g., (A,B,C,D) for an equation of the form
     * Ax + By + Cz + D = 0).
     * @param point the other point
     * @return the coefficients of the perpendicular bisector
     */
    public Pnt bisector (Pnt point) {
        int dim = dimCheck(point);
        Pnt diff = this.subtract(point);
        Pnt sum = this.add(point);
        float dot = diff.dot(sum);
        return diff.extend(new float[] {-dot / 2});
    }
    
    /* Pnts as matrices */
    
    /**
     * Create a String for a matrix.
     * @param matrix the matrix (an array of Pnts)
     * @return a String represenation of the matrix
     */
    public String toString (Pnt[] matrix) {
        StringBuffer buf = new StringBuffer("{");
        for (int i = 0; i < matrix.length; i++) buf.append(" " + matrix[i]);
        buf.append(" }");
        return buf.toString();
    }
    
    /**
     * Compute the determinant of a matrix (array of Pnts).
     * This is not an efficient implementation, but should be adequate 
     * for low dimension.
     * @param matrix the matrix as an array of Pnts
     * @return the determinnant of the input matrix
     * @throws IllegalArgumentException if dimensions are wrong
     */
    public float determinant (Pnt[] matrix) {
        if (matrix.length != matrix[0].dimension())
            throw new IllegalArgumentException("Matrix is not square");
        boolean[] columns = new boolean[matrix.length];
        for (int i = 0; i < matrix.length; i++) columns[i] = true;
        try {return determinant(matrix, 0, columns);}
        catch (ArrayIndexOutOfBoundsException e) {
            throw new IllegalArgumentException("Matrix is wrong shape");
        }
    }
    
    /**
     * Compute the determinant of a submatrix specified by starting row
     * and by "active" columns.
     * @param matrix the matrix as an array of Pnts
     * @param row the starting row
     * @param columns a boolean array indicating the "active" columns
     * @return the determinant of the specified submatrix
     * @throws ArrayIndexOutOfBoundsException if dimensions are wrong
     */
    private float determinant(Pnt[] matrix, int row, boolean[] columns) {
        if (row == matrix.length) return 1;
        float sum = 0;
        int sign = 1;
        for (int col = 0; col < columns.length; col++) {
            if (!columns[col]) continue;
            columns[col] = false;
            sum += sign * matrix[row].coordinates[col] *
                   determinant(matrix, row+1, columns);
            columns[col] = true;
            sign = -sign;
        }
        return sum;
    }
    
    /**
     * Compute generalized cross-product of the rows of a matrix.
     * The result is a Pnt perpendicular (as a vector) to each row of
     * the matrix.  This is not an efficient implementation, but should 
     * be adequate for low dimension.
     * @param matrix the matrix of Pnts (one less row than the Pnt dimension)
     * @return a Pnt perpendicular to each row Pnt
     * @throws IllegalArgumentException if matrix is wrong shape
     */
    public Pnt cross (Pnt[] matrix) {
        int len = matrix.length + 1;
        if (len != matrix[0].dimension())
            throw new IllegalArgumentException("Dimension mismatch");
        boolean[] columns = new boolean[len];
        for (int i = 0; i < len; i++) columns[i] = true;
        float[] result = new float[len];
        int sign = 1;
        try {
            for (int i = 0; i < len; i++) {
                columns[i] = false;
                result[i] = sign * determinant(matrix, 0, columns);
                columns[i] = true;
                sign = -sign;
            }
        } catch (ArrayIndexOutOfBoundsException e) {
            throw new IllegalArgumentException("Matrix is wrong shape");
        }
        return new Pnt(result);
    }
    
    public float distSq(Pnt p) {
      return sq(coordinates[0]-p.coordinates[0])+sq(coordinates[1]-p.coordinates[1]);
    }
    /* Pnts as simplices */
    
    /**
     * Determine the signed content (i.e., area or volume, etc.) of a simplex.
     * @param simplex the simplex (as an array of Pnts)
     * @return the signed content of the simplex
     */
    public float content (Pnt[] simplex) {
        Pnt[] matrix = new Pnt[simplex.length];
        for (int i = 0; i < matrix.length; i++)
            matrix[i] = simplex[i].extend(new float[] {1});
        int fact = 1;
        for (int i = 1; i < matrix.length; i++) fact = fact*i;
        return determinant(matrix) / fact;
    }
    
    /**
     * Relation between this Pnt and a simplex (represented as an array of Pnts).
     * Result is an array of signs, one for each vertex of the simplex, indicating
     * the relation between the vertex, the vertex's opposite facet, and this
     * Pnt. <pre>
     *   -1 means Pnt is on same side of facet
     *    0 means Pnt is on the facet
     *   +1 means Pnt is on opposite side of facet</pre>
     * @param simplex an array of Pnts representing a simplex
     * @return an array of signs showing relation between this Pnt and the simplex
     * @throws IllegalArgumentExcpetion if the simplex is degenerate
     */
    public int[] relation (Pnt[] simplex) {
        /* In 2D, we compute the cross of this matrix:
         *    1   1   1   1
         *    p0  a0  b0  c0
         *    p1  a1  b1  c1
         * where (a, b, c) is the simplex and p is this Pnt.  The result
         * is a vector in which the first coordinate is the signed area
         * (all signed areas are off by the same constant factor) of
         * the simplex and the remaining coordinates are the *negated*
         * signed areas for the simplices in which p is substituted for
         * each of the vertices. Analogous results occur in higher dimensions.
         */
        int dim = simplex.length - 1;
        if (this.dimension() != dim)
            throw new IllegalArgumentException("Dimension mismatch");
        
        /* Create and load the matrix */
        Pnt[] matrix = new Pnt[dim+1];
        /* First row */
        float[] coords = new float[dim+2];
        for (int j = 0; j < coords.length; j++) coords[j] = 1;
        matrix[0] = new Pnt(coords);
        /* Other rows */
        for (int i = 0; i < dim; i++) {
            coords[0] = this.coordinates[i];
            for (int j = 0; j < simplex.length; j++) 
                coords[j+1] = simplex[j].coordinates[i];
            matrix[i+1] = new Pnt(coords);
        }
        
        /* Compute and analyze the vector of areas/volumes/contents */
        Pnt vector = cross(matrix);
        float content = vector.coordinates[0];
        int[] result = new int[dim+1];
        for (int i = 0; i < result.length; i++) {
            float value = vector.coordinates[i+1];
            if (Math.abs(value) <= 1.0e-6 * Math.abs(content)) result[i] = 0;
            else if (value < 0) result[i] = -1;
            else result[i] = 1;
        }
        if (content < 0) {
            for (int i = 0; i < result.length; i++) result[i] = -result[i];
        }
        if (content == 0) {
            for (int i = 0; i < result.length; i++) result[i] = Math.abs(result[i]);
        }
        return result;
    }
    
    /**
     * Test if this Pnt is outside of simplex.
     * @param simplex the simplex (an array of Pnts)
     * @return the simplex Pnt that "witnesses" outsideness (or null if not outside)
     */
    public Pnt isOutside (Pnt[] simplex) {
        int[] result = this.relation(simplex);
        for (int i = 0; i < result.length; i++) {
            if (result[i] > 0) return simplex[i];
        }
        return null;
    }
    
    /**
     * Test if this Pnt is on a simplex.
     * @param simplex the simplex (an array of Pnts)
     * @return the simplex Pnt that "witnesses" on-ness (or null if not on)
     */
    public Pnt isOn (Pnt[] simplex) {
        int[] result = this.relation(simplex);
        Pnt witness = null;
        for (int i = 0; i < result.length; i++) {
            if (result[i] == 0) witness = simplex[i];
            else if (result[i] > 0) return null;
        }
        return witness;
    }
    
    /**
     * Test if this Pnt is inside a simplex.
     * @param simplex the simplex (an arary of Pnts)
     * @return true iff this Pnt is inside simplex.
     */
    public boolean isInside (Pnt[] simplex) {
        int[] result = this.relation(simplex);
        for (int i = 0; i < result.length; i++) if (result[i] >= 0) return false;
        return true;
    }
    
    /**
     * Test relation between this Pnt and circumcircle of a simplex.
     * @param simplex the simplex (as an array of Pnts)
     * @return -1, 0, or +1 for inside, on, or outside of circumcircle
     */
    public int vsCircumcircle (Pnt[] simplex) {
        Pnt[] matrix = new Pnt[simplex.length + 1];
        for (int i = 0; i < simplex.length; i++)
            matrix[i] = simplex[i].extend(new float[] {1, simplex[i].dot(simplex[i])});
        matrix[simplex.length] = this.extend(new float[] {1, this.dot(this)});
        float d = determinant(matrix);
        int result = (d < 0)? -1 : ((d > 0)? +1 : 0);
        if (content(simplex) < 0) result = - result;
        return result;
    }
    
    /**
     * Circumcenter of a simplex.
     * @param simplex the simplex (as an array of Pnts)
     * @return the circumcenter (a Pnt) of simplex
     */
    public Pnt circumcenter (Pnt[] simplex) {
        int dim = simplex[0].dimension();
        if (simplex.length - 1 != dim)
            throw new IllegalArgumentException("Dimension mismatch");
        Pnt[] matrix = new Pnt[dim];
        for (int i = 0; i < dim; i++) 
            matrix[i] = simplex[i].bisector(simplex[i+1]);
        Pnt hCenter = cross(matrix);      // Center in homogeneous coordinates
        float last = hCenter.coordinates[dim];
        float[] result = new float[dim];
        for (int i = 0; i < dim; i++) result[i] = hCenter.coordinates[i] / last;
        return new Pnt(result);
    }
}
