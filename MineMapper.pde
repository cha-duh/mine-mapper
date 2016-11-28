/*MineMapper by JrkFace*
 *a clone of the famous*
 *MineSweeper game with*
 *no custom def classes*
 *just arrays and vars.*
 *To change difficulty,*
 *increase/decrease the*
 *BOMBPROB constant.   */


//CONSTANT declarations

//Board width and height measured in tiles
int BW = 40;
int BH = 25;
//Tile width and height measured in pixels
int TW = 20;
int TH = 20;
//Each tile's probability of being a bomb
float BOMBPROB = .125;

//variableDeclarations

//Images
PImage flag;
PImage bomb;
PImage bigBomb;
PImage explosion;
PImage bigExplosion;
//Font
PFont f;
//these arrays will hold all of the information we need to play the game.
//we'll use nested for loops to access the information iteratively.
boolean[][] flagged;
boolean[][] showing;
boolean[][] board;
int[][] adj;

//initialize
void setup() {

  //size is number of tiles times tile width/height + room for an image
  //size(BW*TW, BH*TH+100);
  size(800,600);

  //uncomment to load images from disk
  //bomb = loadImage("BombSmall.png", "png");
  //explosion = loadImage("ExplosionSmall.png", "png");
  //flag = loadImage("RedFlag_Small.png", "png");
  //bigBomb = loadImage("BombBig.png", "png");
  //bigExplosion = loadImage("Explosion.png", "png");

  //uncomment to load images from web
  bomb = loadImage("http://i.imgur.com/6OELWRC.png", "png");
  explosion = loadImage("http://i.imgur.com/xCTxsQ1.png", "png");
  flag = loadImage("http://i.imgur.com/2p7hobD.png", "png");
  bigBomb = loadImage("http://i.imgur.com/jtjrZWW.png", "png");
  bigExplosion = loadImage("http://i.imgur.com/bMxab4R.png", "png");

  //for displaying adjacencies
  f = createFont("Impact", 16);
  textAlign(CENTER, TOP);
  textFont(f);

  //boolean arrays initialize to false;
  flagged = new boolean[BW][BH];
  showing = new boolean[BW][BH];
  board   = new boolean[BW][BH];
  //int arrays initialize to zero
  adj = new int[BW][BH];
  placeBombs();
  setNumbers();
}

//heartbeat 
void draw() {
  if (allFlagged()) {
    float x = noise(frameCount/92.9)*width;
    float y = noise(frameCount/49.4)*height;
    pushMatrix();
    translate(x, y);
    rotate(frameCount/10.3 % TWO_PI);
    imageMode(CENTER);
    image(bigBomb, 0, 0);
    popMatrix();
    float r = noise(frameCount/55.5)*255;
    float g = map(x,0,width,0,255);
    float b = map(y,0,height,0,255);
    color c = color(r,g,b);
    fill(c);
    rectMode(CENTER);
    rect(width/2,height/2,80,60);
    color oc = color(255-r,255-g,255-b);
    fill(oc);
    textAlign(CENTER,CENTER);
    text("You Win!!", width/2, height/2);
  } 
  else {
    background(130);
    //nested for loop iterates through all tiles
    for (int i=0; i<BW; i++) {
      for (int j=0; j<BH; j++) {
        fill(130);
        stroke(80);
        strokeWeight(4);
        rect(i*TW, j*TH, TW, TH);
        //changing stroke color here will give the tiles we've interacted with a
        //raised look.  It will overwrite the top and left edges white/grey
        //and leave the right and bottom edges dark grey.
        stroke(180);

        //if there's a bomb, and you're supposed to see it
        if (board[i][j] && showing[i][j]) {
          imageMode(CORNER);
          image(bomb, i*TW, j*TH);
        }
        //if there's not a bomb and you're supposed to see it
        else if (!board[i][j] && showing[i][j]) {
          int scalar = adj[i][j];
          //fill with whitish rectangle
          fill(200);
          rect(i*TW, j*TH, TW, TH);
          //if there's a bomb nearby
          if (scalar > 0) {
            fill(scalar*30, scalar*20, scalar*10);
            text(scalar, i*TW + TW/2, j*TH);
          }
        }
        else if (flagged[i][j]) {
          imageMode(CORNER);
          image(flag, i*TW + 4, j*TH + 4);
        }
      }
    }
    pushMatrix();
    translate(mouseX, BH*TH + 50);
    rotate(map(mouseX, 0, width, 0, TWO_PI));
    imageMode(CENTER);
    image(bigBomb, 0, 0);
    popMatrix();
  }
}

//setup function places bombs at random
//based on the probability constant above
void placeBombs() {
  for (int i=0; i<BW; i++) {
    for (int j=0; j<BH; j++) {
      if (random(1) <= BOMBPROB) {
        board[i][j] = true;
      }
    }
  }
}

//setup function looks for bombs and increments
//surrounding tile values by one
void setNumbers() {
  for (int i=0; i<BW; i++) {
    for (int j=0; j<BH; j++) {
      if (board[i][j]) {
        if (i > 0) adj[i-1][j]++;
        if (i < BW-1) adj[i+1][j]++;
        if (j > 0) adj[i][j-1]++;
        if (j < BH-1) adj[i][j+1]++;
        if (i > 0 && j > 0) adj[i-1][j-1]++;
        if (i > 0 && j < BH-1) adj[i-1][j+1]++;
        if (i < BW-1 && j > 0) adj[i+1][j-1]++;
        if (i < BW-1 && j < BH-1) adj[i+1][j+1]++;
      }
    }
  }
}

void mouseClicked() {
  //thanks to integer division, find the index corresponding
  //to the mouse position with a simple divide.
  //this works because integer division in Java ALWAYS truncates/rounds down
  int xIndex = mouseX/TW;
  int yIndex = mouseY/TH;

  //Handles left clicks
  if (mouseButton == LEFT) {
    //if you click on a bomb, show all the bombs and show explosion
    if (board[xIndex][yIndex] && !flagged[xIndex][yIndex]) {
      bigBomb = bigExplosion;
      for (int i=0; i<BW; i++) {
        for (int j=0; j<BH; j++) {
          if (board[i][j]) showing[i][j] = true;
        }
      }
      //otherwise, just flip the tile
    } 
    else if (!flagged[xIndex][yIndex]) {
      flipTile(xIndex, yIndex);
    }
  }

  //Handles right clicks - flags bombs, disabling that square
  else if (mouseButton == RIGHT) {
    if (flagged[xIndex][yIndex]) flagged[xIndex][yIndex] = false;
    else flagged[xIndex][yIndex] = true;
  }
}

//recursive function flips tile and, if zero, calls
//itself at the new tile position.
void flipTile(int x, int y) {
  //if it's already been seen, do nothing
  if (showing[x][y]) return;
  //otherwise, mark it as seen and test value
  else {
    showing[x][y] = true;
    //if zero call the function on the surrounding tiles.
    if (adj[x][y]==0) {
      if (x > 0) flipTile(x-1, y);
      if (x < BW-1) flipTile(x+1, y);
      if (y > 0) flipTile(x, y-1);
      if (y < BH-1) flipTile(x, y+1);
      if (x > 0 && y > 0) flipTile(x-1, y-1);
      if (x > 0 && y < BH-1) flipTile(x-1, y+1);
      if (x < BW-1 && y > 0) flipTile(x+1, y-1);
      if (x < BW-1 && y < BH-1) flipTile(x+1, y+1);
    }
  }
}

boolean allFlagged() {
  
  boolean same = true;  
  for (int i=0; i<BW; i++) {
    for (int j=0; j<BH; j++) {
      if (board[i][j] != flagged[i][j]) same = false;
    }
  }
  return same;
}