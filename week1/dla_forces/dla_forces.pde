//list of current circles
ArrayList circles;
float diameter = 10;
float diameter_sq = sq(diameter);
float max_distance = 300;
float max_move = 1;

//forces
float force_x = .1;
float force_y = 0;

//noise variables
int seed_noise_x = millis();
int seed_noise_y;
float noise_scale = .1;

void setup() {
  size(600,600);
  background(255);
  fill(0);
  circles = new ArrayList();
  //seed it with an initial circle in the middle
  PVector first_circle = new PVector(width/2.0,height/2.0);
  //draw circle
  ellipse(first_circle.x, first_circle.y, diameter, diameter);
  circles.add(first_circle);
  seed_noise_y = millis();
  drawForces();
}

void draw() {
  //add a new circle and move until it sticks
  addCircle();
}

void addCircle() {
  //make a new circle a distance max_distance
  float angle = random(0, TWO_PI);
  PVector current_circle = new PVector(max_distance*cos(angle)+width/2.0,max_distance*sin(angle)+height/2.0);;
  
  //move the circle randomly until it hits an existing circle
  while(true) {
    if(intersect(current_circle, circles)) {
      break;
    }
    //add a random vector to the current circle
    current_circle.add(random(-max_move, max_move),random(-max_move, max_move),0);
    
    //apply force
    applyForce(current_circle);
    applyForceNoise(current_circle);
    
    //wrap around
    if(current_circle.x < 0) current_circle.x += width;
    else if(current_circle.x > width) current_circle.x -= width;
    if(current_circle.y < 0) current_circle.y += height;
    else if(current_circle.y > height) current_circle.y -= height;

  }
  ellipse(current_circle.x, current_circle.y, diameter, diameter);
  circles.add(current_circle);
}

//move the circle according to some force function
void applyForce(PVector circle) {
  circle.x += force_x;
  circle.y += force_y;
}

void applyForceNoise(PVector circle) {
  float x_noise = noise(circle.x*noise_scale,circle.y*noise_scale)-.5;
  x_noise*=.1;
  float y_noise = noise(circle.x*noise_scale,circle.y*noise_scale+1000)-.5;
  y_noise*=.1;
  //println(x_noise + " " + y_noise);
  circle.x += x_noise;
  circle.y += y_noise;
  //point(circle.x, circle.y);
}

void drawForces() {
  for(int i=0;i<width;i+=10) {
    for(int j=0;j<height;j+=10) {
      noiseSeed(seed_noise_x);
      float x_noise = noise(i*noise_scale,j*noise_scale)-.5;
      x_noise*=5;
      noiseSeed(seed_noise_y);
      float y_noise = noise(i*noise_scale,j*noise_scale)-.5;
      y_noise*=5;
      line(i-x_noise,j-y_noise,i+x_noise,j+y_noise);
    }
  }
}
//find if there is an itersection between circle and any circle in circle_array
boolean intersect(PVector circle, ArrayList circle_array) {
  for(Iterator it = circle_array.iterator();it.hasNext();) {
    PVector circle2 = (PVector) it.next();
    //use square distance to avoid a call to sqrt, which is slow
    float dist_sq = sq(circle2.x-circle.x)+sq(circle2.y-circle.y);
    if(dist_sq < diameter_sq) return true;
  }
  //if no intersection return false
  return false;
}
