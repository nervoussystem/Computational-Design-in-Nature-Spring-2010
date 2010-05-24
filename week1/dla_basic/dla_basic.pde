//list of current circles
ArrayList circles;
//diameter of the circle
float diameter = 10;
float diameter_sq = sq(diameter);
//where to add new circles
float max_distance = 300;
//maximum move in x or y direction at each step
float max_move = 1;

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
  }
  ellipse(current_circle.x, current_circle.y, diameter, diameter);
  circles.add(current_circle);
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
