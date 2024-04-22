import java.util.Arrays;
int cellSize = 25;
int xBorder = 800/cellSize;
int yBorder = 800/cellSize;
int[] startPos = {0, 0};
int[] endPos = {xBorder - 1, yBorder - 1};
Cell[][] cells = new Cell[xBorder][yBorder];
Cell current;
Cell[] stack = {};
Cell[] openSet = new Cell[0];
Cell[] closedSet = new Cell[0];
boolean foundEndPos = false;
boolean inClosedSet = false;
int currPathLen = 0;
int resPathLen = 0;
Cell endCell;
boolean isCarving = true;
boolean isPathfinding = false;
int margin = 10;
float randomThreshold = 0.5;
int minWallCount = 2;

float calculateDistance(float x1, float y1, float x2, float y2){
  float xDist = x2 - x1;
  float yDist = y2 - y1;
  return sqrt(xDist*xDist + yDist*yDist);
}

void setup(){
  size(820, 820);
  setupConfig();
  frameRate(60);
}

void setupConfig(){
  for(int i = 0; i < xBorder; i++){
    for(int j = 0; j < yBorder; j++){
      cells[i][j] = new Cell(i, j, 200, 200, 255);
    }
  }
  current = cells[0][0];  
  cells[0][0].walls[0] = false;
  cells[xBorder - 1][yBorder - 1].walls[2] = false;
  
  openSet = Arrays.copyOf(openSet, openSet.length + 1);
  openSet[0] = cells[startPos[0]][startPos[1]];
  cells[startPos[0]][startPos[1]].g = 0;
}

void draw(){
  background(230);
  noFill();
  
  for(int i = 0; i < xBorder; i++){
    for(int j = 0; j < yBorder; j++){
      cells[i][j].show();
    }
  }
  noStroke();
  if (isCarving){
    fill(0, 255, 255, 125);
    square(current.i * cellSize, current.j * cellSize, cellSize);
  
    Cell next = current.checkNeighbors();
    current.visited = true;
    
    if (next != null){
      stack = Arrays.copyOf(stack, stack.length + 1);
      stack[stack.length - 1] = current;
      removeWalls(current, next);
      current = next;
    } else if (stack.length > 0){
      current = stack[stack.length - 1];
      if (random(0, 1) < randomThreshold){
        int wallCount = 0;
        for(int i = 0; i < current.walls.length; i++){
          if (current.walls[i]){
            wallCount++;
          }
        }
        if(wallCount > minWallCount){
          int r = int(random(0, 4));
          if (r == 1 && current.i > 0){
            current.walls[r] = false;
            cells[current.i - 1][current.j].walls[3] = false;
          }
          if (r == 3 && current.i < xBorder - 1){
            current.walls[r] = false;
            cells[current.i + 1][current.j].walls[1] = false;
          }
          if (r == 0 && current.j > 0){
            current.walls[r] = false;
            cells[current.i][current.j - 1].walls[2] = false;
          }
          if (r == 2 && current.j < yBorder - 1){
            current.walls[r] = false;
            cells[current.i][current.j + 1].walls[0] = false;
          }
        }
      }
      stack = Arrays.copyOf(stack, stack.length - 1);
    } else{
      isCarving = false;
      isPathfinding = true;
    }
  } else if (isPathfinding){
    if(foundEndPos || openSet.length == 0){
      if(foundEndPos){
        println("DONE: Complete path has been successfully generated");
      } else{
        println("DONE: Complete path can't be generated");
      }
      resPathLen = max(resPathLen, currPathLen);
      println("Total Length: ", resPathLen);
      isPathfinding = false;
    }
  
    if(openSet.length > 0 && !foundEndPos){
      Cell curr = openSet[0];
      int cheapest = 0;
      for(int i = 0; i < openSet.length; i++){
        if (curr.f > openSet[i].f){
          curr = openSet[i];
          cheapest = i;
        }
      }
      if(curr.i == endPos[0] && curr.j == endPos[1]){
        foundEndPos = true;
      } else {
        for(int i = cheapest; i < openSet.length - 1; i++){
          openSet[i] = openSet[i + 1];
        }
        openSet = Arrays.copyOf(openSet, openSet.length - 1);
        if (curr.i > 0){ //Left neighbor
          if (!cells[curr.i - 1][curr.j].walls[3]){ //Checks right wall of left neighbor
            curr.neighbors = Arrays.copyOf(curr.neighbors, curr.neighbors.length + 1);
            curr.neighbors[curr.neighbors.length - 1] = cells[curr.i - 1][curr.j];
          }
        }
        if (curr.i < xBorder - 1){ //Right neighbor
          if (!cells[curr.i + 1][curr.j].walls[1]){ //Checks left wall of right neighbor
            curr.neighbors = Arrays.copyOf(curr.neighbors, curr.neighbors.length + 1);
            curr.neighbors[curr.neighbors.length - 1] = cells[curr.i + 1][curr.j];
          }
        }
        if (curr.j > 0){ //Top neighbor
          if (!cells[curr.i][curr.j - 1].walls[2]){ //Checks bottom wall of top neighbor
            curr.neighbors = Arrays.copyOf(curr.neighbors, curr.neighbors.length + 1);
            curr.neighbors[curr.neighbors.length - 1] = cells[curr.i][curr.j - 1];
          }
        }
        if (curr.j < yBorder - 1){ //Bottom neighbor
          if (!cells[curr.i][curr.j + 1].walls[0]){ //Checks top wall of bottom neighbor
            curr.neighbors = Arrays.copyOf(curr.neighbors, curr.neighbors.length + 1);
            curr.neighbors[curr.neighbors.length - 1] = cells[curr.i][curr.j + 1];
          }
        }
        
        for(int idx = 0; idx < curr.neighbors.length; idx++){
          float tempG = curr.g + calculateDistance(curr.i, curr.j, curr.neighbors[idx].i, curr.neighbors[idx].j);
          if (tempG < curr.neighbors[idx].g){
            curr.neighbors[idx].prev = curr;
            curr.neighbors[idx].g = tempG;
            curr.neighbors[idx].h = calculateDistance(curr.neighbors[idx].i, curr.neighbors[idx].j, endPos[0], endPos[1]);
            curr.neighbors[idx].f = curr.neighbors[idx].g + curr.neighbors[idx].h;
            
            inClosedSet = false;
            for(int i = 0; i < closedSet.length; i++){
              if (curr.neighbors[idx] == closedSet[i]){
                inClosedSet = true;
                break;
              }
            }
            if (!inClosedSet){
              openSet = Arrays.copyOf(openSet, openSet.length + 1);
              openSet[openSet.length - 1] = curr.neighbors[idx];
            }
          }
        }
        closedSet = Arrays.copyOf(closedSet, closedSet.length + 1);
        closedSet[closedSet.length - 1] = curr;
      }
      
      for(int i = 0; i < openSet.length; i++){
        openSet[i].red = 0;
        openSet[i].green = 255;
        openSet[i].blue = 0;
      }
        
      for(int i = 0; i < closedSet.length; i++){
        closedSet[i].red = 255;
        closedSet[i].green = 0;
        closedSet[i].blue = 0;
      }
      currPathLen = 0;
      endCell = curr;
      while (curr != null){
        curr.red = 0;
        curr.green = 0;
        curr.blue = 255;
        curr = curr.prev;
        currPathLen++;
      }
      
      if (!foundEndPos && openSet.length > 0){
        resPathLen = max(resPathLen, currPathLen);
        println("The current path length is: ", resPathLen);
      }
    }
  }
}

void removeWalls(Cell curr, Cell next){
  if (curr.i > next.i){ //Left neighbor
    curr.walls[1] = false;
    next.walls[3] = false;
  }
  if (curr.i < next.i){ //Right neighbor
    curr.walls[3] = false;
    next.walls[1] = false;
  }
  if (curr.j < next.j){ //Bottom neighbor
    curr.walls[2] = false;
    next.walls[0] = false;
  }
  if (curr.j > next.j){ //Top neighbor
    curr.walls[0] = false;
    next.walls[2] = false;
  }
}

void mousePressed(){
  int x = (mouseX / cellSize);
  int y = (mouseY / cellSize);
  if (x < 0){
    x = 0;
  }
  if (x >= xBorder){
    x = xBorder - 1;
  }
  if (y < 0){
    y = 0;
  }
  if (y >= yBorder){
    y = yBorder - 1;
  }
  println("XPos: ", x, "\nYPos: ", y, "\ng cost: ", cells[x][y].g, "\nh cost: ", cells[x][y].h, "\nf cost: ", cells[x][y].f);
}

void keyPressed(){
  if(isCarving || isPathfinding){
    return;
  }
  if(key == 'r'){
    setupConfig();
    isCarving = true;
  }
}

/* 
Notes: 19 Dec

Combined two of my previous projects into this giant one.
Made some modifications to the pathfinding algorithm to check for walls instead of blockades
Maze generation takes much longer than I anticipated for grids bigger than 40x40 :p
The sweet spot for cellSize is 25 (32x32 grid), 
just big enough to make it somewhat complicated, but not so big that it takes too long to generate.

Also added a random factor that erases some walls so that there are multiple potential routes for the 
pathfinding algorithm to take (making it take longer to finish).

Added a reset button
*/
