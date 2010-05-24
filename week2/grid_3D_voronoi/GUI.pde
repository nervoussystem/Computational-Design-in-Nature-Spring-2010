ControlP5 cp5;

void setupGUI() {
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  ControlWindow cwindow = cp5.addControlWindow("controlP5window",600,61,400,200);
  cwindow.setBackground(color(0));
  cwindow.setColorForeground(color(0));
  controlP5.Slider noise_slide = cp5.addSlider("noiseStr",0,500,NOISE_STRENGTH, 1,5,100,10);
  noise_slide.setWindow(cwindow);
  noise_slide.setLabel("Noise Strength");
  //controlP5.Slider force_y_slide = cp5.addSlider("force_y",-2,2,force_y, 1,20,100,10);
  //force_y_slide.setWindow(cwindow);
  //force_y_slide.setLabel("Y Force");
  //controlP5.Button reset = cp5.addButton("reset", 0,1, 35, 40,20);
  //reset.setWindow(cwindow); 
 
}

void noiseStr(float v) {
  NOISE_STRENGTH = v;
  for(int i=0;i<noiseForces.size();++i) {
    NoisePotential2D np = (NoisePotential2D) noiseForces.get(i);
    np.k = NOISE_STRENGTH;
  }
}
