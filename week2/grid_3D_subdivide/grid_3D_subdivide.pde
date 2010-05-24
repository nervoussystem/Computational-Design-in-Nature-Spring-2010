import processing.opengl.*;

import controlP5.*;

import peasy.*;
import nervous.physics2.*;

ParticleSystem physics;
Particle[][] particles;
//number of particles on a side
int gridSize = 20;
float gridStep;

//variables for forces
float SPRING_STRENGTH = 0.2;
float SPRING_DAMPING = 0.1;
float REPEL = 1000;
float NOISE_STRENGTH=200;
float noiseScale = .01;

boolean drawForces = true;
PeasyCam camera;
//off screen window to draw clickable faces
PGraphics3D pg;

//List of faces
ArrayList faces;
//List of noisePotential2D forces for later modification
ArrayList noiseForces;
void setup()
{
  size(400, 400, OPENGL);
  gridStep = float(width)/(gridSize-1);
  //smooth();
  camera = new PeasyCam(this, width/2.0, height/2.0, 0, 500);
  pg = (PGraphics3D) createGraphics(width,height,P3D);
  setupGUI();
  fill(0);

  physics = new ParticleSystem(0,0,.5, 0.1);
  //physics.setIntegrator(ParticleSystem.VERLET);
  particles = new Particle[gridSize][gridSize];
  noiseForces = new ArrayList();
  faces = new ArrayList();
  setupGrid();
}

void setupGrid() {
  float gridStepX = (float) ((width ) / (gridSize-1));
  float gridStepY = (float) ((height) / (gridSize-1));

  //keep track of edges going horizontally and vertically
  Edge downEdges[][] = new Edge[gridSize][gridSize];
  Edge acrossEdges[][] = new Edge[gridSize][gridSize];

  for (int i = 0; i < gridSize; i++)
  {
    for (int j = 0; j < gridSize; j++)
    {
      particles[i][j] = physics.makeParticle(0.2, j * gridStepX, i * gridStepY, 0.0);
      NoisePotential2D np = new NoisePotential2D(particles[i][j],NOISE_STRENGTH,noiseScale);
      physics.addCustomForce(np);
      noiseForces.add(np);
      if(i==0 || i == gridSize-1 || j==0 || j== gridSize-1) particles[i][j].makeFixed();
      if (j > 0)
      {
        Spring s = physics.makeSpring(particles[i][j - 1], particles[i][j], SPRING_STRENGTH, SPRING_DAMPING, gridStepX/1.0);
        Edge e = new Edge(s);
        downEdges[i][j-1] = e;
      }
    }
  }

  for (int j = 0; j < gridSize; j++)
  {
    for (int i = 1; i < gridSize; i++)
    {
      Spring s = physics.makeSpring(particles[i - 1][j], particles[i][j], SPRING_STRENGTH, SPRING_DAMPING, gridStepY/1.0);
      Edge e = new Edge(s);
      acrossEdges[i-1][j] = e;
    }
  }

  //create faces out of edges
  for (int i = 0; i < gridSize-1; i++)
  {
    for (int j = 0; j < gridSize-1; j++)
    {
      Face f = new Face();
      //add edges in counter clockwise order
      //(i,j) to (i,j+1)
      f.edges.add(downEdges[i][j]);
      //(i,j+1) to (i+1,j+1)
      f.edges.add(acrossEdges[i][j+1]);
      //(i+1,j+1) to (i+1,j) actually this is backwards
      f.edges.add(downEdges[i+1][j]);
      //(i+1,j) to (i,j) actually this is backwards
      f.edges.add(acrossEdges[i][j]);
      faces.add(f);
    }
  }
}

void draw()
{
  physics.tick(.25);  
  background(255);
  cp5.draw();

  //drawNoise();
  //draw forces
  //if(drawForces) drawForce();


  noFill();
  stroke(0);

  //drawGrid();
  
  ambientLight(48,48,48);
  lightSpecular(230,230,230);
  directionalLight(255,255,255,0,-0.5,-1);
  specular(255,255,255);
  shininess(16.0);  
  drawFaces();
}

void drawGrid() {
  for (int i = 0; i < gridSize; i++)
  {
    beginShape();
    curveVertex(particles[i][0].x, particles[i][0].y, particles[i][0].z);
    for (int j = 0; j < gridSize; j++)
    {
      curveVertex(particles[i][j].x, particles[i][j].y, particles[i][j].z);
    }
    curveVertex(particles[i][gridSize - 1].x, particles[i][gridSize - 1].y, particles[i][gridSize - 1].z);
    endShape();
  }
  for (int j = 0; j < gridSize; j++)
  {
    beginShape();
    curveVertex(particles[0][j].x, particles[0][j].y, particles[0][j].z);
    for (int i = 0; i < gridSize; i++)
    {
      curveVertex(particles[i][j].x, particles[i][j].y, particles[i][j].z);
    }
    curveVertex(particles[gridSize - 1][j].x, particles[gridSize - 1][j].y, particles[gridSize - 1][j].z);
    endShape();
  }
}

void drawForces()    {
  noStroke();
  for(int i=0;i<physics.numberOfAttractions();++i) {
    Attraction a = physics.getAttraction(i);
    fill(0,0,255,50);
    if(a.strength() < 0) fill(255,0,0,50);
    Particle p = a.getOneEnd();
    ellipse(p.x,p.y,10,10);
  }
  for(int i=0;i<physics.numberOfCustomForces();++i) {
    Force cf = physics.getCustomForce(i);
    if(cf instanceof SpiralForce) {
      SpiralForce sf = (SpiralForce) cf;
      fill(0,255,255,50);
      if(sf.k < 0) fill(255,255,0,50);
      Particle p = sf.a;
      ellipse(p.x,p.y,10,10);
    }
  }
}

//draw a quad for each "face" of the mesh
void drawFaces() {
  noStroke();
  fill(100);
  for(int i=0;i<faces.size();++i) {
    //ArrayList face = (ArrayList) faces.get(i);
    //for(int j=0;j<face.size();++j) {
    //  PVector v = (PVector) face.get(j);
    //  vertex(v.x,v.y,v.z);
    //}
    Face f = (Face) faces.get(i);
    drawFace(f,this.g);
  }
}

//draw a face in a arbitrary PGraphics
void drawFaceBad(Face f, PGraphics graph) {
  //this method assumes four sides with opposite sides going opposite directions
  //basically this is a bad way of doing it
  //it isn't general and won't draw subdivided face correctly
  graph.beginShape(QUADS);
  Edge e1 = (Edge) f.edges.get(0);
  Edge e2 = (Edge) f.edges.get(2);
  graph.vertex(e1.s.a().x,e1.s.a().y,e1.s.a().z);
  graph.vertex(e1.s.b().x,e1.s.b().y,e1.s.b().z);
  graph.vertex(e2.s.b().x,e2.s.b().y,e2.s.b().z);
  graph.vertex(e2.s.a().x,e2.s.a().y,e2.s.a().z);
  graph.endShape();
}

//a slightly better draw face function
//get a rough center for the face and draw a triangle for each real edge
void drawFace(Face f, PGraphics graph) {
  PVector center = new PVector();
  for(int i=0;i<f.edges.size();++i) {
    Edge e = f.getEdge(i);
    center.add(e.s.a());
    center.add(e.s.b());
  }
  graph.beginShape(TRIANGLES);
  center.mult(1.0/(f.edges.size()*2));
  for(int i=0;i<f.edges.size();++i) {
    Edge e = f.getEdge(i);
    drawEdge(center, e, graph);
  }
  graph.endShape();
}

//recursive function for drawing edges
//keep looking at sub-edges until you get to an edge that doesn't have them
void drawEdge(PVector center, Edge e, PGraphics graph) {
  if(e.midPt == null) {
    graph.vertex(center.x,center.y,center.z);
    graph.vertex(e.s.a().x,e.s.a().y,e.s.a().z);
    graph.vertex(e.s.b().x,e.s.b().y,e.s.b().z);
  } 
  else {
    drawEdge(center, e.e1, graph);
    drawEdge(center, e.e2, graph);
  }
}

//draw a quad off screen for each face.  each quad is a different color so they can be identified by pixel
void drawClickable() {
  pg.noStroke();
  for(int i=0;i<faces.size();++i) {

    int i2 = i+1;
    pg.fill(i2%255, (i2/255)%255,i2/sq(255));
    //ArrayList face = (ArrayList) faces.get(i);
    //
    //for(int j=0;j<face.size();++j) {
    //  PVector v = (PVector) face.get(j);
    //  pg.vertex(v.x,v.y,v.z);
    //}
    Face f = (Face) faces.get(i);
    drawFace(f,pg);
  }
}

void mouseClicked() {
  if(keyPressed && key == CODED && keyCode == CONTROL) {
    Particle p = physics.makeParticle(1.0,mouseX,mouseY,0);
    p.makeFixed();
    if(mouseButton == LEFT) repelAll(p,REPEL);
    else repelAll(p,-REPEL);
  } 
  else if(keyPressed && key == CODED && keyCode == ALT) {
    Particle p = physics.makeParticle(1.0,mouseX,mouseY,0);
    p.makeFixed();
    if(mouseButton == LEFT) repelAllSpiral(p,10);
    else repelAllSpiral(p,-10);
  } 
  else if(keyPressed && key == CODED && keyCode == SHIFT) {
    subdivideClick();
  }
}

void subdivideClick() {
  pg.camera = ((PGraphics3D)this.g).camera;
  pg.beginDraw();
  pg.background(255);
  drawClickable();
  pg.endDraw();
  pg.loadPixels();

  color cc = pg.pixels[mouseY*width+mouseX];

  if(cc != color(255)) {
    int index = int(red(cc) + green(cc)*255+blue(cc)*sq(255))-1;
    Face f = (Face) faces.get(index);
    subdivide(f);
  }
}

void subdivide(Face face) {
  //compute a center point average all point
  PVector center = new PVector();
  for(int i=0;i<face.edges.size();++i) {
    Edge e = (Edge) face.edges.get(i);
    center.add(e.s.a());
    center.add(e.s.b());
  }
  center.mult(1.0/(face.edges.size()*2));
  Particle centerPart = physics.makeParticle(0.2, center.x, center.y,center.z);

  ArrayList innerEdges = new ArrayList();
  //get mid points of the edge, note they might already exist
  for(int i=0;i<face.edges.size();++i) {
    Edge e = face.getEdge(i);
    //if edge has not yet been subdivided
    if(e.midPt == null) {
      //make particle at mid point of edge
      PVector mid = PVector.add(e.s.a(),e.s.b());
      mid.mult(0.5);
      Particle midPt = physics.makeParticle(0.2, mid.x,mid.y,mid.z);
      e.midPt = midPt;

      //turn off old spring
      e.s.turnOff();
      //add two springs for the edge
      Spring s1 = physics.makeSpring(e.s.a(), midPt, SPRING_STRENGTH, SPRING_DAMPING, gridStep);
      Spring s2 = physics.makeSpring(midPt, e.s.b(), SPRING_STRENGTH, SPRING_DAMPING, gridStep);

      //make new edges from springs and add as sub edges or e
      e.e1 = new Edge(s1);
      e.e2 = new Edge(s2);

    }
    //make a new spring and edge from the midpt to the center
    Spring sn = physics.makeSpring(centerPart, e.midPt, SPRING_STRENGTH, SPRING_DAMPING, gridStep);
    Edge en = new Edge(sn);
    innerEdges.add(en);
  }

  //make new faces
  for(int i=0;i<face.edges.size();++i) {
    Edge e = face.getEdge(i);
    Edge e2 = face.getEdge((i+1)%face.edges.size());
    Edge innerEdge1 = (Edge) innerEdges.get(i);
    Edge innerEdge2 = (Edge) innerEdges.get((i+1)%face.edges.size());

    Edge subEdge1, subEdge2;
    //must initialize variables or IDE will complain
    subEdge1 = subEdge2 = null;
    //figure out where the edges meet
    if(e.s.a().equals(e2.s.a())) {
      subEdge1 = e.e1;
      subEdge2 = e2.e1;
    } 
    else if(e.s.a().equals(e2.s.b())) {
      subEdge1 = e.e1;
      subEdge2 = e2.e2;
    } 
    else if(e.s.b().equals(e2.s.b())) {
      subEdge1 = e.e2;
      subEdge2 = e2.e2;
    } 
    else if(e.s.b().equals(e2.s.a())) {
      subEdge1 = e.e2;
      subEdge2 = e2.e1;
    }

    Face newFace = new Face();
    newFace.edges.add(subEdge1);
    newFace.edges.add(innerEdge1);
    newFace.edges.add(innerEdge2);
    newFace.edges.add(subEdge2);
    faces.add(newFace);
  }
  faces.remove(face);

}

Spring getSpring(Particle p1, Particle p2) {
  for(int i=0;i<physics.numberOfSprings();++i) {
    Spring s = physics.getSpring(i);
    if((s.a() == p1 && s.b() == p2) || (s.a() == p2 && s.b() == p1)) return s;
  }
  return null;
}

void keyPressed() {
  if(key == 'f') drawForces = !drawForces;
}

void repelAll(Particle p,float strength) {
  for(int i=0;i<particles.length;++i) {
    for(int j=0;j<particles[0].length;++j) {
      physics.makeAttraction(p,particles[i][j], strength,10);
    }  
  }
}

void repelAllSpiral(Particle p,float strength) {
  for(int i=0;i<particles.length;++i) {
    for(int j=0;j<particles[0].length;++j) {
      physics.addCustomForce(new SpiralForce(p,particles[i][j], strength,10));
    }  
  }
}

void drawNoise() {
  loadPixels();
  for(int i=0;i<width;++i) {
    for(int j=0;j<height;++j) {
      pixels[j*width+i] = color(noise(i*noiseScale,j*noiseScale)*255);
    }
  }
  updatePixels();
}



