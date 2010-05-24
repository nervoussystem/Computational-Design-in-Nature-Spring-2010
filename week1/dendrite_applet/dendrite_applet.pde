RadiusInterface max_radius;
RadiusInterface min_radius;
float max_agg_rad = 220;

CartInput cart;
RadInput rad;

Button zoomIn;
Button zoomOut;
Button pause;
Button clear, save, checkout, undo, redo;

float price = 60.0;
float cart_force_x = 0;
float cart_force_y = 0;
float polar_force_r = 0;
float polar_force_a = 0;

float agg_off_x = 0;
float agg_off_y = 0;

float agg_scale = 1;

Aggregation curr_agg;

ArrayList historyStack = new ArrayList();

boolean paused = false;
boolean redraw = true;

PApplet me;

PFont descriptionFont;
PFont buttonFont;
PFont titleFont;
PFont priceFont;

String display_msg = "";
int display_timer = 0;

DLA dla = new DLA();
void setup() {
  size(680,335);
  me = this;
  agg_off_x = -width/2+main_width/2.0;
  agg_off_y = 0;
  descriptionFont = loadFont("ArialMT-10.vlw");
  buttonFont = loadFont("ArialMT-10.vlw");
  priceFont = loadFont("Verdana-12.vlw");
  titleFont = loadFont("Arial-BoldMT-14.vlw");
  PFont zoomF = loadFont("Verdana-Bold-15.vlw");
  min_radius = new RadiusInterface(4,main_width+78,50,50,50);
  max_radius = new RadiusInterface(8,main_width+78,110,50,50);
  cart = new CartInput(main_width+142,50);
  rad = new RadInput(main_width+142,110);
  zoomIn = new Button(5,height-20,15,15,"+");
  zoomOut = new Button(27,height-20,15,15,"-");
    zoomOut.font = zoomF;
    zoomIn.font = zoomF;
    zoomIn.fontSize = 15;
    zoomOut.fontSize = 15;
    zoomIn.background = color(0);
    zoomOut.background = color(0);
    zoomIn.text_color = color(255);
    zoomOut.text_color = color(255);
    zoomIn.rollover = color(100);
    zoomOut.rollover = color(100); 
  checkout = new Button(main_width+335+10-128-4-1, 4, 128,20, "ADD TO CART");
  checkout.font = priceFont;
  checkout.fontSize = 12;
  checkout.background = color(0);
  checkout.text_color = color(255);
  checkout.rollover = color(100);
  save = new Button(main_width+14, 50, 50,15,"save");
  clear = new Button(main_width+14,50+19,50,15,"clear");
  pause = new Button(main_width+14,50+19*2,50,15,"pause");
  undo = new Button(main_width+14,50+19*3,50,15,"undo");
  redo = new Button(main_width+14,50+19*4,50,15,"redo");

  try {
    zoomIn.onClick = this.getClass().getMethod("zoomin", new Class[0]);
    zoomOut.onClick = this.getClass().getMethod("zoomout", new Class[0]);
    pause.onClick = this.getClass().getMethod("togglePause", new Class[0]);
    clear.onClick = this.getClass().getMethod("clear", new Class[0]);
    save.onClick = this.getClass().getMethod("saveAggregation", new Class[0]);
    checkout.onClick = this.getClass().getMethod("checkout", new Class[0]);
    undo.onClick = this.getClass().getMethod("undo", new Class[0]);
    redo.onClick = this.getClass().getMethod("redo", new Class[0]);
  } catch (Exception e) {
    
  }
  smooth();
  curr_agg = new Aggregation();
  dla.setPriority(dla.getPriority()-1);
  dla.start();
}

void draw() {
  if(redraw) {
    background(255);
    render();
    redraw = false;
  } else {
    renderInterface();
  }
}

void render() {
  noStroke();
  curr_agg.render();
  renderInterface();
}

void renderInterface() {
  fill(interface_background);
  noStroke();
  rect(main_width+10,0,width,height);
  textAlign(TOP,LEFT);
  textFont(buttonFont,10);
  max_radius.render();
  fill(0);
  text("small circle",main_width+78,49);
  text("large circle",main_width+78,47+62);
  text("linear force", main_width+142,49);
  text("spiral force", main_width+142,47+62);
  min_radius.render();
  rad.render();
  cart.render();
  zoomIn.y = height-20;
  zoomOut.y = height-20;
  zoomIn.render();
  zoomOut.render();
  pause.render();
  clear.render();
  save.render();
  checkout.render();
  undo.render();
  redo.render();
  noStroke();
  fill(255);
  rect(50,height-15,60,10);
  fill(0);
  text("zoom "+int(agg_scale*100)+"%",50,height-15,60,10);
  textFont(titleFont,14);
  textAlign(LEFT,TOP);
  text("CUSTOM DENDRITE",main_width+10+4,8);
  textFont(priceFont, 12);
  text("$"+price+"0", main_width+10+4,27);
  textFont(descriptionFont,10);
  text(description, main_width+10+4,175, 330,200);
  if(display_timer > 0) {
    fill(100,30+display_timer*7);
    noStroke();
    rect(width*3/8+10,height*3/8,width/4+50,height/4);
    fill(0,30+display_timer*20);
    textFont(titleFont,14);
    textAlign(CENTER,CENTER);
    text(display_msg,width/2+30,height/2);
    display_timer--;
    fill(255);
  }
}

void mouseDragged() {
  if(mouseX<=main_width) {
    agg_off_x += mouseX-pmouseX;
    agg_off_y += mouseY-pmouseY;
    redraw = true;
  }
}

void keyPressed() {
  if(key == 'p') {
    togglePause();
  } else if(key == ' ') {
    clear();
  }
}
