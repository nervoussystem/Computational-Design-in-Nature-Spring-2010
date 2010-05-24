import controlP5.*;

//list of current circles
ArrayList circles;
float diameter = 10;
float diameter_sq = sq(diameter);
float max_distance = 300;
float max_move = 1;

//forces
float force_x = .1;
float force_y = 0;

void setup() {
  size(600,600);
  background(255);
  fill(0);
  initGUI();
  circles = new ArrayList();
  //seed it with an initial circle in the middle
  PVector first_circle = new PVector(width/2.0,height/2.0);
  //draw circle
  ellipse(first_circle.x, first_circle.y, diameter, diameter);
  circles.add(first_circle);
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

//find if there is an itersection between circle and any circle in circle_array
boolean intersect(PVector circle, ArrayList circle_array) {
  for(int i=0;i<circles.size();++i) {
    PVector circle2 = (PVector) circles.get(i);
    //use square distance to avoid a call to sqrt, which is slow
    float dist_sq = sq(circle2.x-circle.x)+sq(circle2.y-circle.y);
    if(dist_sq < diameter_sq) return true;
  }
  //if no intersection return false
  return false;
}

