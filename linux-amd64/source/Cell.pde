class Cell{
  int i, j;
  int red, green, blue;
  float f = 0;
  float g = Integer.MAX_VALUE;
  float h = 0;
  Cell prev;
  Cell[] neighbors = {};
  boolean isCurr = false;
  boolean visited = false;
  boolean[] walls = {true, true, true, true};
  //top, left, bottom, right
  
  Cell(int _i, int _j, int _r, int _g, int _b){
    i = _i;
    j = _j;
    red = _r;
    green = _g;
    blue = _b;
  }
  
  Cell checkNeighbors(){
    Cell[] neighbors = {};
    if (i > 0){ //Left neighbor
      if(!cells[i - 1][j].visited){
        neighbors = Arrays.copyOf(neighbors, neighbors.length + 1);
        neighbors[neighbors.length - 1] = cells[i - 1][j];
      }
    }
    if (i < xBorder - 1){ //Right neighbor
      if(!cells[i + 1][j].visited){
        neighbors = Arrays.copyOf(neighbors, neighbors.length + 1);
        neighbors[neighbors.length - 1] = cells[i + 1][j];
      }
    }
    if (j > 0){ //Top neighbor
      if(!cells[i][j - 1].visited){
        neighbors = Arrays.copyOf(neighbors, neighbors.length + 1);
        neighbors[neighbors.length - 1] = cells[i][j - 1];
      }
    }
    if (j < yBorder - 1){ //Bottom neighbor
      if(!cells[i][j + 1].visited){
        neighbors = Arrays.copyOf(neighbors, neighbors.length + 1);
        neighbors[neighbors.length - 1] = cells[i][j + 1];
      }
    }
    
    if (neighbors.length > 0){
      int r = int(random(0, neighbors.length));
      return neighbors[r];
    }
    else{
      return null;
    }
  }
  
  void show(){
    if (visited){
      noStroke();
      fill(red, green, blue);
      square(i * cellSize + margin, j * cellSize + margin, cellSize);
    }
    noFill();
    stroke(0);
    strokeWeight(2);
    if (walls[0]){ //Top
      line(i * cellSize + margin, j * cellSize + margin, i * cellSize + cellSize + margin, j * cellSize + margin);
    }
    if (walls[1]){ //Left
      line(i * cellSize + margin, j * cellSize + margin, i * cellSize + margin, j * cellSize + cellSize + margin);
    }
    if (walls[2]){ //Bottom
      line(i * cellSize + margin, j * cellSize + cellSize + margin, i * cellSize + cellSize + margin, j * cellSize + cellSize + margin);
    }
    if (walls[3]){ //Right
      line(i * cellSize + cellSize + margin, j * cellSize + margin, i * cellSize + cellSize + margin, j * cellSize + cellSize + margin);
    }
  }
}
