import peasy.*;
import nervous.physics2.*;

ParticleSystem physics;
Particle[][] particles;
//number of particles on a side
int gridSize = 20;

//variables for forces
float SPRING_STRENGTH = 1;
float SPRING_DAMPING = 0.1;
float REPEL = 1000;
float NOISE_STRENGTH=200;
float noiseScale = .01;

boolean drawForces = true;
PeasyCam camera;

//List of faces
ArrayList faces;
//A map from Triangulation Pnts to ParticleSystem Particles
HashMap parts;
ArrayList pnts;

DelaunayTriangulation dt;
Simplex initialTriangle;
Pnt ip1, ip2, ip3;

void setup()
{
  size(400, 400, P3D);
  //setup camera
  camera = new PeasyCam(this, width/2.0, height/2.0, 0, 500);

  physics = new ParticleSystem(0,0,.5, 0.1);
  //create a delaunay triangulation and then a spring mesh based on that triangulation
  setupDelaunay();
}

void setupDelaunay() {
  //create an initial triangle that encompasses all points
  ip1 = new Pnt(-2.0*width, 2.0*height);
  ip2 = new Pnt(2.0*width, 2.0*height);
  ip3 = new Pnt(width/2.0,-2.0*height);
  initialTriangle = new Simplex(new Pnt[] {
    ip1,ip2,ip3          }
  );
  //initialize variables
  dt = new DelaunayTriangulation(initialTriangle);
  parts = new HashMap();
  pnts = new ArrayList();
  
  //create four corner points
  Pnt cpt = new Pnt(0,0);
  dt.delaunayPlace(cpt,null);
  pnts.add(cpt);
  cpt = new Pnt(width,0);
  dt.delaunayPlace(cpt,null);
  pnts.add(cpt);
  cpt = new Pnt(width,height);
  dt.delaunayPlace(cpt,null);
  pnts.add(cpt);
  cpt = new Pnt(0,height);
  dt.delaunayPlace(cpt,null);
  pnts.add(cpt);
  
  //randomly place points within our four corner points
  for(int i=0;i<400;++i) {
    float cx = random(0,width);
    float cy = random(0,height);
    cpt = new Pnt(cx,cy);
    dt.delaunayPlace(cpt,null);
    pnts.add(cpt);
  }
  
  //centroidal voronoi algorithm
  //moves points such that the voronoi diagram of the points is centroidal
  //create a more "even" triangulation
  for(int i=0;i<10;++i) lloydStep();
  
  //make Particles from the Pnts
  for(int i=0;i<pnts.size();++i) {
    cpt = (Pnt) pnts.get(i);
    Particle cpart = physics.makeParticle(0.2,cpt.x(),cpt.y(),0);
    parts.put(cpt,cpart);
    //fix the first four points, which are our four corners
    if(i<4) cpart.makeFixed();
  }
  
  //compile a set of all edges in the DelaunayTriangulation
  //the Triangulation is a list of triangles, so we must convert that to a list of edges
  //A set does not have duplicate entries.
  //Since each edge belongs to two triangles we must eliminate redundacy
  HashSet edges = new HashSet();
  for(Iterator it = dt.iterator();it.hasNext();) {
    Simplex sim = (Simplex) it.next();
    //get each edge or "facet" of the triangle or "Simplex"
    for (Iterator otherIt = sim.facets().iterator(); otherIt.hasNext();) {
      Set facet = (Set) otherIt.next();
      //add edge to the set
      edges.add(facet);
    }
  }
  
  //make a spring for each edge
  for(Iterator it = edges.iterator();it.hasNext();) {
    Set facet = (Set) it.next();
    Iterator otherIt = facet.iterator();
    Pnt p1 = (Pnt) otherIt.next();
    Pnt p2 = (Pnt) otherIt.next();
    //do not include triangles from the initial bounding triangle
    if(!(p1.equals(ip1) || p1.equals(ip2) || p1.equals(ip3) || p2.equals(ip1) || p2.equals(ip2) || p2.equals(ip3))) {
      Particle part1 = (Particle) parts.get(p1);
      Particle part2 = (Particle) parts.get(p2);
      //physics.makeSpring(part1,part2, SPRING_STRENGTH,SPRING_DAMPING,width/20.0);
      physics.makeSpring(part1,part2, SPRING_STRENGTH,SPRING_DAMPING,part1.dist(part2));    
    }
  }
}

void draw()
{
  physics.tick(.25);  

  background(255);

  //set lighting
  ambientLight(48,48,48);
  lightSpecular(230,230,230);
  directionalLight(255,255,255,0,-0.5,-1);
  specular(255,255,255);
  shininess(16.0);  
  drawFaces();
  //drawDelaunay();
  
  //draw springs
  drawSprings();
}

void drawSprings() {
  noFill();
  stroke(0);  
  for(int i=0;i<physics.numberOfSprings();++i) {
    Spring s = physics.getSpring(i);
    Particle p1 = s.a();
    Particle p2 = s.b();
    line(p1.x,p1.y,p1.z,p2.x,p2.y,p2.z);
  }  
}

void drawDelaunay() {
  for(Iterator it = dt.iterator(); it.hasNext();) {
    Simplex triangle = (Simplex) it.next();
    for (Iterator otherIt = triangle.facets().iterator(); otherIt.hasNext();) {
      Set facet = (Set) otherIt.next();
      Pnt[] endpoint = (Pnt[]) facet.toArray(new Pnt[2]);
      line(endpoint[0].x(),endpoint[0].y(), endpoint[1].x(), endpoint[1].y());
    }
  }
}

boolean containsAny(Set s1, Set s2) {
  for(Iterator it = s1.iterator();it.hasNext();) {
    Object o1 = it.next();
    for(Iterator it2 = s2.iterator();it2.hasNext();) {
      Object o2 = it2.next();
      if(o1.equals(o2)) return true;
    }
  }
  return false;
}
//draw a triangle for each Simplex of the Triangulation
void drawFaces() {
  noStroke();
  fill(100);
  beginShape(TRIANGLES);
  for(Iterator it = dt.iterator(); it.hasNext();) {
    Simplex triangle = (Simplex) it.next();
    if(!containsAny(triangle,initialTriangle)) {
      for (Iterator otherIt = triangle.iterator(); otherIt.hasNext();) {
        Pnt p = (Pnt) otherIt.next();
        Particle part = (Particle) parts.get(p);
        vertex(part.x,part.y,part.z);
      }
    }
  }
  endShape();
}

