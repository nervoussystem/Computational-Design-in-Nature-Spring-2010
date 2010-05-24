//list of current circles
ArrayList circles;
//radius of the circle
float diameter = 10;
float diameter_sq = sq(diameter);
//where to add new circles
float max_distance = 300;
//maximum move in x or y direction at each step
float max_move = 1;
float sticking_probability = 1;

float max_x, max_y, min_x, min_y;
PVector dla_center;
float dla_radius;
float bounds_addition = 50;
float bounds_scalar = 1.5;

//use bucking for quick interestion
HashMap buckets = new HashMap();

void setup() {
  size(600,600);
  background(255);
  fill(0);
  circles = new ArrayList();
  //seed it with an initial circle in the middle
  PVector first_circle = new PVector(width/2.0,height/2.0);
  //draw circle
  ellipse(first_circle.x, first_circle.y, diameter, diameter);
  dla_center = new PVector();
  max_x = min_x = dla_center.x = first_circle.x;
  max_y = min_y = dla_center.y = first_circle.y;
  dla_radius = 1;
  circles.add(first_circle);
  
  //add first_circle to the bucket
  int x_index = int(first_circle.x/diameter);
  int y_index = int(first_circle.y/diameter);
  Integer index = new Integer(((x_index <<16) >>> 16) | (y_index << 16));
  if(buckets.containsKey(index)) ((ArrayList) buckets.get(index)).add(first_circle);
  else {
    ArrayList new_bucket = new ArrayList();
    new_bucket.add(first_circle);
    buckets.put(index, new_bucket);
  }
}

void draw() {
  addCircle();
}

void addCircle() {
  //computer lower and upper bounds of space
  float bound_radius = dla_radius*bounds_scalar+bounds_addition;
  float bound_radius_sq = sq(bound_radius);
  //rect(lower_bound_x,lower_bound_y,upper_bound_x-lower_bound_x, upper_bound_y-lower_bound_y);
  fill(0);
  //make a new circle on the bounds at a random angle
  float angle = random(0,TWO_PI);
  PVector current_circle = new PVector(cos(angle)*bound_radius+dla_center.x,sin(angle)*bound_radius+dla_center.y);
  
  
  //move the circle randomly until it hits the an existing circle
  while(true) {
    if(intersect(current_circle)) {
      if(random(1.0) < sticking_probability) {
        break;
      } else {
        //move away
      }
    }
    current_circle.add(random(-max_move, max_move),random(-max_move, max_move),0);
    //wrap around so it cannot get too far away
    //get the vector from dla_center to current_circle
    PVector center_to_circle = PVector.sub(current_circle,dla_center);
    float sq_dist = sq(center_to_circle.x)+sq(center_to_circle.y);
    if(sq_dist > bound_radius_sq) {
      float prev_dist = sqrt(sq_dist); 
      float new_dist = 2*bound_radius-prev_dist;
      center_to_circle.mult(-new_dist/prev_dist);
      current_circle.x = center_to_circle.x+dla_center.x;
      current_circle.y = center_to_circle.y+dla_center.y;
    }    
  }
  ellipse(current_circle.x, current_circle.y, diameter, diameter);

  //update bounds
  PVector center_to_circle = PVector.sub(current_circle,dla_center);
  float sq_dist = sq(center_to_circle.x)+sq(center_to_circle.y);
  if(sq_dist > sq(dla_radius)) {
    float curr_dist = sqrt(sq_dist);
    float to_move = (curr_dist-dla_radius)/2;
    dla_radius+=to_move;
    center_to_circle.mult(to_move/curr_dist);
    dla_center.add(center_to_circle);
  }
  
  circles.add(current_circle);
  
  //add circle to the buckets
  int x_index = int(current_circle.x/diameter);
  int y_index = int(current_circle.y/diameter);
  Integer index = new Integer(((x_index <<16) >>> 16) | (y_index << 16));
  if(buckets.containsKey(index)) ((ArrayList) buckets.get(index)).add(current_circle);
  else {
    ArrayList new_bucket = new ArrayList();
    new_bucket.add(current_circle);
    buckets.put(index, new_bucket);
  }
}


boolean intersect(PVector circle) {
  ArrayList near_circles = new ArrayList();
  int x_index = int(circle.x/diameter);
  int y_index = int(circle.y/diameter);

  //get nearby points
  Integer index = new Integer(((x_index <<16) >>> 16) | (y_index << 16));
  if(buckets.containsKey(index)) near_circles.addAll((ArrayList) buckets.get(index));
  index = new Integer((((x_index-1) <<16) >>> 16) | (y_index << 16));
  if(buckets.containsKey(index)) near_circles.addAll((ArrayList) buckets.get(index));
  index = new Integer((((x_index+1) <<16) >>> 16) | (y_index << 16));
  if(buckets.containsKey(index)) near_circles.addAll((ArrayList) buckets.get(index));
  index = new Integer(((x_index <<16) >>> 16) | ((y_index-1) << 16));
  if(buckets.containsKey(index)) near_circles.addAll((ArrayList) buckets.get(index));
  index = new Integer((((x_index-1) <<16) >>> 16) | ((y_index-1) << 16));
  if(buckets.containsKey(index)) near_circles.addAll((ArrayList) buckets.get(index));
  index = new Integer((((x_index+1) <<16) >>> 16) | ((y_index-1) << 16));
  if(buckets.containsKey(index)) near_circles.addAll((ArrayList) buckets.get(index));  
  index = new Integer(((x_index <<16) >>> 16) | ((y_index+1) << 16));
  if(buckets.containsKey(index)) near_circles.addAll((ArrayList) buckets.get(index));
  index = new Integer((((x_index-1) <<16) >>> 16) | ((y_index+1) << 16));
  if(buckets.containsKey(index)) near_circles.addAll((ArrayList) buckets.get(index));
  index = new Integer((((x_index+1) <<16) >>> 16) | ((y_index+1) << 16));
  if(buckets.containsKey(index)) near_circles.addAll((ArrayList) buckets.get(index));
  
  //find intersection with nearby points
  for(Iterator it = near_circles.iterator();it.hasNext();) {
    PVector circle2 = (PVector) it.next();
    float dist_sq = sq(circle2.x-circle.x)+sq(circle2.y-circle.y);
    if(dist_sq < diameter_sq) return true;
  }
  return false;
}
