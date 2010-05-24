class DLA extends Thread {
  void start() {
    super.start();
  }
  
  void run() {
    while(true) {
      if(!paused) {
        curr_agg.step();
      } else {
        return;
      }
    }
  }
}
