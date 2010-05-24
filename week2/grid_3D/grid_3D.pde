import processing.opengl.*;

import controlP5.*;

import peasy.*;
import nervous.physics2.*;

ParticleSystem physics;
Particle[][] particles;
//number of particles on a side
int gridSize = 20;

//variables for forces
float SPRING_STRENGTH = 0.2;
float SPRING_DAMPING = 0.1;
float REPEL = 1000;
float NOISE_STRENGTH=200;
float noiseScale = .01;
float noiseT = 0; //noise 'time'

boolean drawForces = true;
PeasyCam camera;

//List of faces
ArrayList faces;
//List of noisePotential2D forces for later modification
ArrayList noiseForces;

//control variable for 2D versus 3D view
boolean view2D = false;
void setup()
{
  size(400, 400, OPENGL);
  camera = new PeasyCam(this, width/2.0, height/2.0, 0, 500);
  setupGUI();

  //initialize variables
  physics = new ParticleSystem(0,0,.5, 0.1);
  particles = new Particle[gridSize][gridSize];
  noiseForces = new ArrayList();
  faces = new ArrayList();

  //create particles and springs
  setupGrid();
}

//make particles and springs on a regular rectangular grid
void setupGrid() {
  //divide space evenly
  float gridStepX = (float) ((width ) / (gridSize-1));
  float gridStepY = (float) ((height) / (gridSize-1));

  //make a particle at each grid points
  for (int i = 0; i < gridSize; i++)
  {
    for (int j = 0; j < gridSize; j++)
    {
      particles[i][j] = physics.makeParticle(0.2, j * gridStepX, i * gridStepY, 0.0);
      //add a noise force to the particle
      NoisePotential2D np = new NoisePotential2D(particles[i][j],NOISE_STRENGTH,noiseScale);
      physics.addCustomForce(np);
      noiseForces.add(np);

      //make edge particles fixed
      if(i==0 || i == gridSize-1 || j==0 || j== gridSize-1) particles[i][j].makeFixed();

      //connect neighboring particles in the 'j' direction with a spring
      if (j > 0)
      {
        physics.makeSpring(particles[i][j - 1], particles[i][j], SPRING_STRENGTH, SPRING_DAMPING, gridStepX/1.0);
      }
    }
  }

  //connect neighboring particles in the 'i' direction with a spring
  for (int j = 0; j < gridSize; j++)
  {
    for (int i = 1; i < gridSize; i++)
    {
      physics.makeSpring(particles[i - 1][j], particles[i][j], SPRING_STRENGTH, SPRING_DAMPING, gridStepY/1.0);
    }
  }

  //store each square of the grid as a 'face'
  for (int i = 0; i < gridSize-1; i++)
  {
    for (int j = 0; j < gridSize-1; j++)
    {
      ArrayList face = new ArrayList();
      face.add(particles[i][j]);
      face.add(particles[i+1][j]);
      face.add(particles[i+1][j+1]);
      face.add(particles[i][j+1]);
      faces.add(face);
    }
  }

  //fix corners.  in this case they are actually already fixed
  particles[0][0].makeFixed();
  particles[0][gridSize - 1].makeFixed();
  particles[gridSize - 1][0].makeFixed();
  particles[gridSize - 1][gridSize - 1].makeFixed(); 
}

void draw()
{
  physics.tick(.25);  
  
  //update noise
  noiseT += .001;
  background(255);

  //drawNoise();
  //draw forces
  if(view2D) {
    //reset the camera and lights to have a normal 2D view
    camera();
    lights();
  }
  
  if(drawForces && view2D) drawForces();

  noFill();
  stroke(0);
  drawGrid();
  
  if(!view2D) {
    ambientLight(48,48,48);
    lightSpecular(230,230,230);
    directionalLight(255,255,255,0,-0.5,-1);
    specular(255,255,255);
    shininess(16.0);  
    drawFaces();
  }
}

//draw a curve for each line of the grid
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

void drawForces() {
  noStroke();
  for(int i=0;i<physics.numberOfCustomForces();++i) {
    Force cf = physics.getCustomForce(i);
    if(cf instanceof SpiralForce) {
      SpiralForce sf = (SpiralForce) cf;
      fill(0,255,255);
      if(sf.k < 0) fill(255,255,0,50);
      Particle p = sf.a;
      ellipse(p.x,p.y,10,10);
    } else if(cf instanceof Attraction2D) {
      Attraction2D a = (Attraction2D) cf;
      fill(0,0,255);
      if(a.strength() < 0) fill(255,0,0,50);
      Particle p = a.a;
      ellipse(p.x,p.y,10,10);
    }
  }
}

//draw a quad for each "face" of the mesh
void drawFaces() {
  noStroke();
  fill(100);
  beginShape(QUADS);
  for(int i=0;i<faces.size();++i) {
    ArrayList face = (ArrayList) faces.get(i);
    for(int j=0;j<face.size();++j) {
      PVector v = (PVector) face.get(j);
      vertex(v.x,v.y,v.z);
    }
  }
  endShape();
}

void mouseClicked() {
  //only add forces in 2D view
  if(view2D) {
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
  }
}

void keyPressed() {
  if(key == 'f') drawForces = !drawForces;
  else if(key == 'v') {
   view2D = !view2D;
   //turn off mouse control of camera
   if(view2D) camera.setMouseControlled(false);
   else {
     //turn on mouse control
     camera.setMouseControlled(true);
     //force an update from the camera
     camera.rotateX(0.0);
   }
  }
}

void repelAll(Particle p,float strength) {
  for(int i=0;i<particles.length;++i) {
    for(int j=0;j<particles[0].length;++j) {
      physics.addCustomForce(new Attraction2D(p,particles[i][j], strength,10));
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



