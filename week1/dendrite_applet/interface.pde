import java.lang.reflect.Method;

public class RadiusInterface {
  float radius;
  float max = 15;
  float min = 2;
  float x,y,w,h;
  color background = color(blue(interface_background)-70);
  color main = color(0);
  color rollover = color(255);

  RadiusInterface() {
    this(1,0,0,10,10);
  }

  RadiusInterface(float _radius) {
    this(_radius,0,0,10,10);
  }

  RadiusInterface(float _radius, float _x, float _y, float _w, float _h) {
    registerMouseEvent(this);
    radius = _radius;
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }

  void render() {
    noStroke();
    fill(background);
    rect(x,y,w,h);
    fill(main);
    if(mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h) fill(rollover);
    ellipse(x+w/2.0,y+h/2.0,radius*2,radius*2);
  }

  public void mouseEvent(MouseEvent e) {
    if(e.getID() == MouseEvent.MOUSE_PRESSED || e.getID() == MouseEvent.MOUSE_DRAGGED) {
      if(mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h) {
        float dist = sqrt(sq(mouseX-(x+w/2.0))+sq(mouseY-(y+h/2.0)));
        radius = constrain(dist,min,max);
      }
    }
  }  
}

public class CartInput {
  float h,w,x,y;
  float xForce,yForce;
  color background = color(blue(interface_background)-70);
  color main = color(30);
  color rollover = color(255);

  CartInput(float _x, float _y) {
    x = _x;
    y = _y;
    h = 50;
    w = 50;

    registerMouseEvent(this);
  }

  void render() {
    noStroke();
    fill(background);
    rect(x,y,w,h);
    stroke(blue(background)-30);
    line(x+2,y+h/2.0,x+w-2,y+h/2.0);
    line(x+w/2.0,y+2,x+w/2.0,y+h-2);
    stroke(main);
    fill(main);
    if(mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h) {
      fill(rollover);
      stroke(rollover);
    }
    ellipse(x+w/2.0,y+h/2.0,3,3);

    if (xForce != 0 || yForce != 0) {
      strokeWeight(2);

      line(x+w/2.0, y+h/2.0, x+w/2.0-xForce*w/2.0,y+h/2.0-yForce*h/2.0);

      float force_l = sqrt(pow(xForce,2)+pow(yForce,2));
      float arr_vx = xForce/force_l*sqrt(2.0)/2.0*5-yForce/force_l*sqrt(2.0)/2.0*5;
      float arr_vy = xForce/force_l*sqrt(2.0)/2.0*5+yForce/force_l*sqrt(2.0)/2.0*5;
      float arr_vx2 = -xForce/force_l*sqrt(2.0)/2.0*5+yForce/force_l*sqrt(2.0)/2.0*5;
      float arr_vy2 = -xForce/force_l*sqrt(2.0)/2.0*5+yForce/force_l*sqrt(2.0)/2.0*5;

      line(x+w/2.0-xForce*w/2.0,y+h/2.0-yForce*h/2.0,x+w/2.0-xForce*w/2.0+arr_vx,y+h/2.0-yForce*h/2.0+arr_vy);
      line(x+w/2.0-xForce*w/2.0,y+h/2.0-yForce*h/2.0,x+w/2.0-xForce*w/2.0+arr_vx2,y+h/2.0-yForce*h/2.0+arr_vy2);
      strokeWeight(1);
    }
  }

  void mouseEvent(MouseEvent e) {
    if(e.getID() == MouseEvent.MOUSE_CLICKED || e.getID() == MouseEvent.MOUSE_DRAGGED){
      if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h) {
        xForce = -(mouseX-x-w/2.0)/w*2.0; 
        yForce = -(mouseY-y-h/2.0)/h*2.0; 
      }
    }
  }
}

public class RadInput {
  float h,w,x,y;
  float rForce;
  float aForce;
  color background = color(blue(interface_background)-70);
  color main = color(30);
  color rollover = color(255);

  RadInput(float _x, float _y) {
    x = _x;
    y = _y;
    h = 50;
    w = 50;

    registerMouseEvent(this);
  }

  void render() {
    noStroke();
    fill(background);
    rect(x,y,w,h);
    stroke(blue(background)-30);
    noFill();
    ellipse(x+w/2.0,y+h/2.0,w/2.0,h/2.0);

    stroke(main);
    fill(main);
    if(mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h) {
      fill(rollover);
      stroke(rollover);
    }
    ellipse(x+w/2.0,y+h/4.0,3,3);

    if (rForce != 0 || aForce != 0) {
      strokeWeight(2);
      line(x+w/2.0, y+h/4.0, x+w/2.0-aForce*w/2.0,y+h/4.0-rForce*h/2.0);

      float force_l = sqrt(pow(rForce,2)+pow(aForce,2));
      float arr_vx = aForce/force_l*sqrt(2.0)/2.0*5-rForce/force_l*sqrt(2.0)/2.0*5;
      float arr_vy = aForce/force_l*sqrt(2.0)/2.0*5+rForce/force_l*sqrt(2.0)/2.0*5;
      float arr_vx2 = aForce/force_l*sqrt(2.0)/2.0*5+rForce/force_l*sqrt(2.0)/2.0*5;
      float arr_vy2 = -aForce/force_l*sqrt(2.0)/2.0*5+rForce/force_l*sqrt(2.0)/2.0*5;

      line(x+w/2.0-aForce*w/2.0,y+h/4.0-rForce*h/2.0,x+w/2.0-aForce*w/2.0+arr_vx,y+h/4.0-rForce*h/2.0+arr_vy);
      line(x+w/2.0-aForce*w/2.0,y+h/4.0-rForce*h/2.0,x+w/2.0-aForce*w/2.0+arr_vx2,y+h/4.0-rForce*h/2.0+arr_vy2);
      strokeWeight(1);

    }
  }

  void mouseEvent(MouseEvent e) {

    if(e.getID() == MouseEvent.MOUSE_CLICKED || e.getID() == MouseEvent.MOUSE_DRAGGED){
      if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h) {
        aForce = -(mouseX-x-w/2.0)/w*2.0; 
        rForce = min(-(mouseY-y-h/4.0)/h*2.0,0); 
      }
    }
  }
}

public class Button {
  float x,y,w,h;
  String name;
  color background = color(50);
  color border = -1;
  color rollover = color(100);
  color text_color = color(255);
  PFont font = buttonFont;
  int fontSize = 10;
  Method onClick;

  Button(float _x, float _y, float _w, float _h, String _name) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    registerMouseEvent(this);
    name = _name;
  }

  void render() {
    if (border==-1) noStroke();
    else stroke(border);
    fill(background);
    if(mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h) fill(rollover);
    rect(x,y,w,h);    
    fill(text_color);
    textFont(font,fontSize);
    textAlign(CENTER,CENTER);
    text(name,x,y,w,h);
  }

  void mouseEvent(MouseEvent e) {

    if (e.getID() == MouseEvent.MOUSE_CLICKED && mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h) {
      try {
        onClick.invoke(me ,new Object[0]);
      } 
      catch(Exception ex) {
        println("OHNO");
      }
    }
  }
}

void zoomin() {
  float prev_scale = agg_scale;
  agg_scale /= .95;
  float middlex = (main_width/2-agg_off_x)/prev_scale;
  float middley = (main_width/2-agg_off_y)/prev_scale;
  agg_off_x = main_width/2-middlex*agg_scale;
  agg_off_y = main_width/2-middley*agg_scale;

  redraw = true;
}

void zoomout() {
  float prev_scale = agg_scale;
  agg_scale *= .95;
  float middlex = (main_width/2-agg_off_x)/prev_scale;
  float middley = (main_width/2-agg_off_y)/prev_scale;
  agg_off_x = main_width/2-middlex*agg_scale;
  agg_off_y = main_width/2-middley*agg_scale;
  redraw = true;
}

void togglePause() {
  paused = !paused;
  pause.name = "play";
  if(!paused) {
    pause.name = "pause";
    dla = new DLA();
    dla.setPriority(dla.getPriority()-1);

    dla.start();
    curr_agg.history = new Circle[0];
  }
}

void saveAggregation() {
  if(online) {
    display_msg = "SAVING...";
    display_timer = 1000;
    displayMsg();
    paint();
    String userId = param("osCsid");
    String configuration = curr_agg.circles[0].x+","+curr_agg.circles[0].y+","+curr_agg.circles[0].radius;
    for(int i=1;i<min(curr_agg.display_index, curr_agg.circles.length);++i) {
      Circle c = curr_agg.circles[i];
      configuration += ":"+c.x+","+c.y+","+c.radius;
    }
    String content = "configuration=" + URLEncoder.encode(configuration) + "&add_to_cart=false" + "&id=" + URLEncoder.encode(userId) ;
    
    String response = postRequest("http://n-e-r-v-o-u-s.com/shop/add_custom_dendrite.php", content);
    if(response.equals("GOOD")) {
      clear(); 
      display_timer = 50;
      display_msg = "SAVED";
    } else {
      display_timer = 50;
      display_msg = "ERROR: UNABLE TO SAVE";
    }
  } else {
      display_timer = 50;
      display_msg = "ERROR: UNABLE TO SAVE";

    /*PGraphics pdf = createGraphics(500,500,PDF,"dendrite_"+frameCount+".pdf");
    pdf.beginDraw();
    pdf.background(255);
    for(int i=0;i<min(curr_agg.circles.length, curr_agg.display_index);++i) {
      Circle c = curr_agg.circles[i];
      pdf.ellipse(c.x,c.y,c.radius*2,c.radius*2);
    }
    pdf.dispose();
    pdf.endDraw();*/
  }
}

void checkout () {
  if(online) {
    display_msg = "ADDING...";
    display_timer = 1000;
    displayMsg();
    paint();
    String userId = param("osCsid");
    String configuration = curr_agg.circles[0].x+","+curr_agg.circles[0].y+","+curr_agg.circles[0].radius;
    for(int i=1;i<min(curr_agg.display_index, curr_agg.circles.length);++i) {
      Circle c = curr_agg.circles[i];
      configuration += ":"+c.x+","+c.y+","+c.radius;
    }
    String content = "configuration=" + URLEncoder.encode(configuration) + "&add_to_cart=true" + "&id=" + URLEncoder.encode(userId) ;
    
    String response = postRequest("http://n-e-r-v-o-u-s.com/shop/add_custom_dendrite.php", content);
    if(response.equals("GOOD")) {
      link("http://n-e-r-v-o-u-s.com/shop/shopping_cart.php"); 
    } else {
      display_msg = "ERROR: UNABLE TO SAVE";
      display_timer = 100;
    }
  } else {
    display_msg = "ERROR: OFFLINE";
    display_timer = 100;
  }
}

void displayMsg() {
    fill(100,30+display_timer*7);
    noStroke();
    rect(width*3/8+10,height*3/8,width/4+50,height/4);
    fill(0,30+display_timer*20);
    textFont(titleFont,14);
    textAlign(CENTER,CENTER);
    text(display_msg,width/2+30,height/2);
}

void clear() {
  dla.stop();
  curr_agg = new Aggregation();
  dla = new DLA();
  dla.setPriority(dla.getPriority()-1);
  redraw = true;
  dla.start();

}

void undo() {
  if(!paused) togglePause();
  if(curr_agg.display_index>1) {
    Circle[] toStack = (Circle[]) subset(curr_agg.circles,-1+curr_agg.display_index--);
    toStack = (Circle[]) reverse(toStack);
    curr_agg.history = (Circle[]) concat(curr_agg.history, toStack);
    curr_agg.circles = (Circle[]) subset(curr_agg.circles,0,curr_agg.display_index);
    redraw = true;
  }
}

void redo() {
  if(curr_agg.history.length > 0) {
    Circle c = curr_agg.history[curr_agg.history.length-1];
    curr_agg.circles = (Circle[]) append(curr_agg.circles,c);
    curr_agg.history = (Circle[]) shorten(curr_agg.history);
    curr_agg.display_index++;
    redraw = true;
  }
}

String postRequest(String urlString, String content) {
  String output = "";

  try{
    URL  url;
    HttpURLConnection   urlConn;
    DataOutputStream    printout;
    DataInputStream     input;
    // URL of CGI-Bin script.
    url = new URL (urlString);
    // URL connection channel.
    urlConn = (HttpURLConnection) url.openConnection();
    // Let the run-time system (RTS) know that we want input.
    urlConn.setDoOutput (true);
    urlConn.setDoInput(true);
    urlConn.setRequestMethod("POST");
    // No caching, we want the real thing.
    //  urlConn.setUseCaches (false);
    // Specify the content type.
    // urlConn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
    // Send POST output.
    printout = new DataOutputStream (urlConn.getOutputStream ());
    printout.writeBytes (content);
    printout.flush ();
    printout.close ();
    //println(message);
    BufferedReader in = new BufferedReader( new InputStreamReader( urlConn.getInputStream()));
    String inputLine;
    while ((inputLine = in.readLine()) != null) {
      output += inputLine;
      println(inputLine);
    }
    in.close();
  } 
  catch (Exception e) {
    exit();
  }
  return output;

}

