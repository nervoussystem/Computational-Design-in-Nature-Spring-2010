import toxi.geom.*;
import toxi.geom.util.*;
import toxi.volume.*;
import processing.opengl.*;
import peasy.*;

//list of current circles
ArrayList spheres;
float max_distance = 300;
float max_move = 1;

//circle size variables
float max_diameter = 20;
float min_diameter = 5;

//forces
float force_x = 0;
float force_y = 0;
float force_r = .01;

int depth = 600;
PeasyCam camera;

boolean drawMesh = false;

void setup() {
  size(300,300, OPENGL);
  max_distance = width/2.0;
  depth = width;
  //initialize automatic camera pointed towards (width/2,height/2,depth/2) from +400 in the z direction
  camera = new PeasyCam(this, width/2.0, height/2.0, depth/2.0, 400);
  sphereDetail(15);
  
  spheres = new ArrayList();
  //seed it with an initial circle in the middle
  float first_diameter = random(min_diameter, max_diameter);
  PVector first_sphere = new Sphere(width/2.0,height/2.0, depth/2.0,first_diameter/2.0);
  spheres.add(first_sphere);
  
  //create thread to run the simulation
  RunDLA dla = new RunDLA();
  dla.start();
  
  setupVolume();
}

void draw() {
  //setup lighting
  background(255);
  ambientLight(48,48,48);
  lightSpecular(230,230,230);
  directionalLight(255,255,255,0,-0.5,-1);
  specular(255,255,255);
  shininess(16.0);
  fill(255);
  noStroke();
  if(drawMesh) {
    computeMetaballs();
    drawFilledMesh();
  }
  else drawSpheres();
  
}

void drawSpheres() {
  int num_spheres = spheres.size();
  for(int i = 0;i<num_spheres;i++) {
    Sphere current_sphere = (Sphere) spheres.get(i);
    pushMatrix();
    translate(current_sphere.x, current_sphere.y, current_sphere.z);
    sphere(current_sphere.r);
    popMatrix();
  }
}

void addSphere() {
  //make a new circle a distance max_distance
  float angle = random(0, TWO_PI);
  float angle2 = random(-HALF_PI, HALF_PI);
  float current_diameter = random(min_diameter, max_diameter);
  Sphere current_sphere = new Sphere(max_distance*cos(angle)*cos(angle2)+width/2.0,max_distance*sin(angle)*cos(angle2)+height/2.0,sin(angle2)*max_distance +depth/2.0,current_diameter/2.0);
  
  //move the circle randomly until it hits an existing circle
  while(true) {
    if(intersect(current_sphere, spheres)) {
      break;
    }
    //add a random vector to the current circle
    current_sphere.add(random(-max_move, max_move),random(-max_move, max_move),random(-max_move,max_move));
    
    //apply force
    applyForce(current_sphere);
    //applyForceNoise(current_circle);
    
    //wrap around
    if(current_sphere.x < 0) current_sphere.x += width;
    else if(current_sphere.x > width) current_sphere.x -= width;
    if(current_sphere.y < 0) current_sphere.y += height;
    else if(current_sphere.y > height) current_sphere.y -= height;
    if(current_sphere.z < 0) current_sphere.z += depth;
    else if(current_sphere.z > depth) current_sphere.z -= depth;

  }
  spheres.add(current_sphere);
}

//move the circle according to some force function
void applyForce(Sphere sphere) {
  sphere.x += force_x;
  sphere.y += force_y;
  PVector center_dir = new PVector(width/2.0-sphere.x,height/2.0-sphere.y,depth/2.0-sphere.z);
  center_dir.normalize();
  center_dir.mult(force_r);
  sphere.add(center_dir);
}

//find if there is an intersection between circle and any circle in circle_array
boolean intersect(Sphere sphere1, ArrayList circle_array) {
  for(Iterator it = circle_array.iterator();it.hasNext();) {
    Sphere sphere2 = (Sphere) it.next();
    //use square distance to avoid a call to sqrt, which is slow
    float dist_sq = sq(sphere2.x-sphere1.x)+sq(sphere2.y-sphere1.y)+sq(sphere2.z-sphere1.z);
    if(dist_sq < sq(sphere1.r+sphere2.r)) return true;
  }
  //if no intersection return false
  return false;
}

class Sphere extends PVector {
  float r;
  Sphere(float x, float y, float z, float r) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.r = r;
  }
  
  float distSq(PVector v) {
    return(sq(v.x-x)+sq(v.y-y)+sq(v.z-z));
  }
}

int grid_size = 100;
float cell_size;
float isoThreshold = 1;
VolumetricSpace volume;
IsoSurface surface;
TriangleMesh mesh = new TriangleMesh("why");

void setupVolume() {
  volume = new VolumetricSpace(new Vec3D(width,height,depth),grid_size,grid_size,grid_size);
  surface = new IsoSurface(volume); 
}

void computeMetaballs() {
  float[] volumeData = volume.getData();
  cell_size = 1.0*width/grid_size;
  PVector pos = new PVector();
  int num_spheres = spheres.size();
  float total = 0;
  for(int z=0,index=0; z<grid_size; z++) {
    pos.z=z*cell_size;
    for(int y=0; y<grid_size; y++) {
      pos.y=y*cell_size;
      for(int x=0; x<grid_size; x++) {
        pos.x=x*cell_size;
        float val=0;
        for(int i=0; i<num_spheres; i++) {
          Sphere s =(Sphere) spheres.get(i);
          float mag_sq=s.distSq(pos)+0.00001;
          
          val+=sq(sq(s.r))/sq(mag_sq);
        }
        volumeData[index++]=val;
        total+=val;
      }
    }
  }
  println(total/(grid_size*grid_size*grid_size));
  volume.closeSides();
  surface.reset();
  surface.computeSurfaceMesh(mesh,isoThreshold);
  
}

void drawFilledMesh() {
  pushMatrix();
  translate(width/2.0,height/2.0,depth/2.0);
  int num=mesh.getNumFaces();
  //println(num);
  mesh.computeVertexNormals();
  beginShape(TRIANGLES);
  for(int i=0; i<num; i++) {
    TriangleMesh.Face f=mesh.faces.get(i);
    normal(f.a.normal);
    vertex(f.a);
    normal(f.b.normal);
    vertex(f.b);
    normal(f.c.normal);
    vertex(f.c);
  }
  endShape();
  popMatrix();
}

void normal(Vec3D v) {
  normal(v.x,v.y,v.z);
}

void vertex(Vec3D v) {
  vertex(v.x,v.y,v.z);
}

void keyPressed() {
  if(key == 'v') {
    drawMesh = !drawMesh;
  }
}

class RunDLA extends Thread {
  RunDLA() {}
  
  void run() {
    while(true) addSphere();
  }
}
