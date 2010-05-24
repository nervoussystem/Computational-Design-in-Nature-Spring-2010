ControlP5 cp5;
void initGUI() {
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  ControlWindow cwindow = cp5.addControlWindow("controlP5window",600,61,400,200);
  cwindow.setBackground(color(0));
  cwindow.setColorForeground(color(0));
  controlP5.Slider force_x_slide = cp5.addSlider("force_x",-2,2,force_x, 1,5,100,10);
  force_x_slide.setWindow(cwindow);
  force_x_slide.setLabel("X Force");
  controlP5.Slider force_y_slide = cp5.addSlider("force_y",-2,2,force_y, 1,20,100,10);
  force_y_slide.setWindow(cwindow);
  force_y_slide.setLabel("Y Force");
  controlP5.Button reset = cp5.addButton("reset", 0,1, 35, 40,20);
  reset.setWindow(cwindow); 
}

void reset() {
  circles.clear();
  background(255);
  PVector first_circle = new PVector(width/2.0,height/2.0);
  ellipse(first_circle.x, first_circle.y, diameter, diameter);
  circles.add(first_circle);
}

void mouseClicked() {
  if(keyPressed && key==CODED && keyCode == CONTROL) {
    PVector new_circle = new PVector(mouseX,mouseY);
    ellipse(new_circle.x,new_circle.y, diameter, diameter);
    circles.add(new_circle);
  }
}

int prev_mouseX = 0;
int prev_mouseY = 0;
void mousePressed() {
  prev_mouseX = mouseX;
  prev_mouseY = mouseY;
}

void mouseDragged() {
  if(keyPressed && key==CODED && keyCode == ALT) {
    background(255);
    noFill();
    float mouse_dist = sqrt(sq(mouseX-prev_mouseX)+sq(mouseY-prev_mouseY));
    ellipse(prev_mouseX,prev_mouseY,mouse_dist*2,mouse_dist*2);
    fill(0);
    drawCircles();
  }
}

void mouseReleased() {
  if(keyPressed && key==CODED && keyCode == ALT) {
    float mouse_dist = sq(mouseX-prev_mouseX)+sq(mouseY-prev_mouseY);
    ArrayList new_circles = new ArrayList(circles.size());
    for(int i=0;i<circles.size();++i) {
      PVector circle = (PVector) circles.get(i);
      if(sq(circle.x-prev_mouseX)+sq(circle.y-prev_mouseY) >= mouse_dist) {
        new_circles.add(circle);
      }
    }
    circles = new_circles;
    background(255);
    drawCircles();
  }
}

void drawCircles() {
  for(int i=0;i<circles.size();++i) {
    PVector circle = (PVector) circles.get(i);
    ellipse(circle.x,circle.y,diameter,diameter);
  }
}



