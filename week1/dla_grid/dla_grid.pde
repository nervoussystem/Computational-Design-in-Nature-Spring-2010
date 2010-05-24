int[][] grid;
//the pixels taken up by one grid square
int grid_size = 2;

void setup() {
  size(600,600);
  background(255);
  fill(0);
  //initialize grid
  grid = new int[width/grid_size][height/grid_size];
  for(int i=0;i<grid.length;++i) {
    for(int j=0;j<grid[0].length;++j) {
      grid[i][j] = 0;
    }
  }
  grid[grid.length/2][grid[0].length/2] = 1;
  drawGridSquare(grid.length/2,grid[0].length/2);
}

void draw() {
  addPoint();
}

void drawGridSquare(int x, int y) {
  rect(x*grid_size,y*grid_size,grid_size,grid_size);
}

void addPoint() {
  //initialize random boundary point
  int x,y;
  if(random(1) < .5) {
    x = int(random(grid.length));
    y = int(random(2))*(grid[0].length-1);
  } else {
    x = int(random(2))*(grid.length-1);
    y = int(random(grid[0].length));    
  }
  while(true) {
    //check neighbors
    if(checkNeighbors(x,y) > 0) break;
    //move in a random direction
    float rand = random(1.0);
    //wrap around the grid
    if(rand < .25) {
      x = (x+1)%grid.length;
    } else if(rand < .5) {
      x = (x+grid.length-1)%grid.length;
    } else if(rand < .75) {
      y = (y+1)%grid[0].length;      
    } else {
      y = (y+grid[0].length-1)%grid[0].length;      
    }
  }
  grid[x][y] = 1;
  drawGridSquare(x,y);
}

int checkNeighbors(int x, int y) {
  int neighbors = 0;
  if(x > 0) neighbors += grid[x-1][y];
  if(x < grid.length-1) neighbors += grid[x+1][y];
  if(y > 0) neighbors += grid[x][y-1];
  if(y < grid[0].length-1) neighbors += grid[x][y+1];
  return neighbors;
}
