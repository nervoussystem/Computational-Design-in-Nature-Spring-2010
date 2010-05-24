//import traer.physics.*;

import nervous.physics2.*;

ParticleSystem physics;
Particle[][] particles;
int gridSize = 20;

float SPRING_STRENGTH = 0.2;
float SPRING_DAMPING = 0.1;
float REPEL = 1000;

boolean drawForces = true;

float noiseScale = .01;
PImage img;
void setup()
{
  size(400, 400);
  //smooth();
  fill(0);
  img = loadImage("bubbles.JPG");
  img.loadPixels();

  physics = new ParticleSystem(0, 0.1);
  //physics.setIntegrator(ParticleSystem.VERLET);
  particles = new Particle[gridSize][gridSize];

  float gridStepX = (float) ((width ) / (gridSize-1));
  float gridStepY = (float) ((height) / (gridSize-1));
  
  for (int i = 0; i < gridSize; i++)
  {
    for (int j = 0; j < gridSize; j++)
    {
      particles[i][j] = physics.makeParticle(0.2, j * gridStepX, i * gridStepY, 0.0);
      //physics.addCustomForce(new NoiseForce(particles[i][j],5,noiseScale));
      physics.addCustomForce(new NoisePotential2D(particles[i][j],100,noiseScale));
      //physics.addCustomForce(new ImagePotential(particles[i][j],.1,img));
      if(i==0 || i == gridSize-1 || j==0 || j== gridSize-1) particles[i][j].makeFixed();
      if (j > 0)
      {
        physics.makeSpring(particles[i][j - 1], particles[i][j], SPRING_STRENGTH, SPRING_DAMPING, gridStepX/3.0);
      }
    }
  }

  for (int j = 0; j < gridSize; j++)
  {
    for (int i = 1; i < gridSize; i++)
    {
      physics.makeSpring(particles[i - 1][j], particles[i][j], SPRING_STRENGTH, SPRING_DAMPING, gridStepY/3.0);
    }
  }
  
  particles[0][0].makeFixed();
  particles[0][gridSize - 1].makeFixed();
  particles[gridSize - 1][0].makeFixed();
  particles[gridSize - 1][gridSize - 1].makeFixed();
}

void draw()
{
  physics.tick(.25);  

  background(255);

  drawNoise();
  //draw forces
  if(drawForces) {
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

  noFill();
  stroke(0);
  //draw a curve for each horizontal and vertical line in the grid
  for (int i = 0; i < gridSize; i++)
  {
    beginShape();
    curveVertex(particles[i][0].x, particles[i][0].y);
    for (int j = 0; j < gridSize; j++)
    {
      curveVertex(particles[i][j].x, particles[i][j].y);
    }
    curveVertex(particles[i][gridSize - 1].x, particles[i][gridSize - 1].y);
    endShape();
  }
  for (int j = 0; j < gridSize; j++)
  {
    beginShape();
    curveVertex(particles[0][j].x, particles[0][j].y);
    for (int i = 0; i < gridSize; i++)
    {
      curveVertex(particles[i][j].x, particles[i][j].y);
    }
    curveVertex(particles[gridSize - 1][j].x, particles[gridSize - 1][j].y);
    endShape();
  }
}

void mouseClicked() {
  //click to add forces
  if(keyPressed && key == CODED && keyCode == CONTROL) {
    Particle p = physics.makeParticle(1.0,mouseX,mouseY,0);
    p.makeFixed();
    //positive is an attraction, negative is repeling
    if(mouseButton == LEFT) repelAll(p,REPEL);
    else repelAll(p,-REPEL);
  } else if(keyPressed && key == CODED && keyCode == ALT) {
    Particle p = physics.makeParticle(1.0,mouseX,mouseY,0);
    p.makeFixed();
    if(mouseButton == LEFT) repelAllSpiral(p,10);
    else repelAllSpiral(p,-10);
  }
}

void keyPressed() {
  //toggle drawing forces
  if(key == 'f') drawForces = !drawForces;
}

//go through all particles and add an attractive force
void repelAll(Particle p,float strength) {
  for(int i=0;i<particles.length;++i) {
    for(int j=0;j<particles[0].length;++j) {
      physics.makeAttraction(p,particles[i][j], strength,10);
    }  
  }
}

//go through all particles and add a spiral force
void repelAllSpiral(Particle p,float strength) {
  for(int i=0;i<particles.length;++i) {
    for(int j=0;j<particles[0].length;++j) {
      physics.addCustomForce(new SpiralForce(p,particles[i][j], strength,10));
    }  
  }
}

//draw a black and white image of the noise
void drawNoise() {
  loadPixels();
  for(int i=0;i<width;++i) {
    for(int j=0;j<height;++j) {
      pixels[j*width+i] = color(noise(i*noiseScale,j*noiseScale)*255);
    }
  }
  updatePixels();
}

