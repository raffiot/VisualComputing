// Constant for mouse wheel with initial value 0.01
float mouseW = 0.01;
// Actual rotation of the box
float rX = 0;
float rZ = 0;
// Postion of the mouse when mouse is pressed
float mx = 0;
float my = 0;
// Constant sizes of the box
int boxX = 200;
int boxY = 10;
int boxZ = 200;
// Constant size of the ball
int sizeSphere = 10;

double score = 0f;
double lastScore = 0f;
double velocityForScore = 0f;

//A shape representing cylinder.
PShape openCylinder;

//ArrayLists containing coordinates for cylinder for each state
ArrayList<PVector> cylindersShifted = new ArrayList();
ArrayList<PVector> cylindersGame = new ArrayList();

Mover mover;
Cylinder c;
PGraphics mySurface;
PGraphics topView;
PGraphics displayScore;
PGraphics barChart;
//Different State of the game,
//GAME := State in which we can move the plate and the ball moves
//SHIFTED := State in which we enter when we press SHIFT
enum State{
  GAME, SHIFTED
};
State globalState = State.GAME;


void settings() {
  size(1200, 800, P3D);
}

void setup() {
  noStroke();
  mover = new Mover();
  c = new Cylinder();
  mySurface = createGraphics(1200,150,P2D);
  topView = createGraphics(130,130,P2D);
  displayScore = createGraphics(100,130,P2D);
  barChart = createGraphics(700,130,P2D);
}

void draw() {

  background(80,255,20);
  drawMySurface();
  image(mySurface,0,650);  
  drawTopView();
  image(topView,10,660);
  drawDisplayScore();
  image(displayScore,150,660);
  
  //Draw depending of game mode
  switch (globalState) {
    
   case GAME:
     //Display top left of parameters
     textSize(16);
     fill(0);
     text("rotateX: " + degrees(rX) + " rotateZ: " + degrees(rZ) + " MouseW: " + mouseW, 5, 15,0);
     lights();
     drawGame();
     break;
     
   case SHIFTED:
     placeCylinder();
     break;
  }
}

void placeCylinder(){
  
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(PI/2);
  fill(255,255,255);
  box(boxX,boxY,boxZ);       //Draw vertical box
  translate(mover.location.x, mover.location.y, mover.location.z); //Draw ball at the good position
  fill(220,220,10);
  sphere(sizeSphere);
  popMatrix();
  
  pushMatrix();
  fill(255,0,127);
  c.set(mouseX,mouseY, 0);  //Draw cylinder following the cursor
  c.drawing(mouseX, mouseY, 0);
  popMatrix();
  pushMatrix();
  c.drawCylinder(cylindersShifted); //Draw cylinders already placed
  popMatrix();
}

void drawGame(){
  translate(width/2, height/2, 0);
  //Translate the rotation between -PI/3 and PI/3
  float rotZ = map(rZ,-1,1,-PI/3.0, PI/3.0);
  float rotX = map(rX,-1,1,-PI/3.0, PI/3.0 );
  rotateX(rotX);
  rotateZ(rotZ);
  fill(255,255,255);
  box(boxX,boxY,boxZ); //draw rotated box
  
  pushMatrix();
  translate(0,-15,0);
  fill(220,220,10);
  mover.computeVelocity(rotZ,rotX);
  mover.checkCylinderCollision(cylindersGame);
  mover.update();
  mover.display();
  mover.checkEdges();
  popMatrix();
  
  pushMatrix();
  rotateX(PI/2);
  fill(255,0,127);
  c.drawCylinder(cylindersShifted);  //draw all cylinders placed
  popMatrix();
}

void mousePressed(){
  mx = mouseX;
  my = mouseY;
  if((globalState == State.SHIFTED)){
    //Cylinder can be placed if and only if it is in the box dimension
    if((mx-width/2 > -boxX/2) && (mx-width/2 < boxX/2) && (my-height/2 > -boxZ/2) && (my-height/2 < boxZ/2)){
      cylindersShifted.add(new PVector(mouseX,mouseY,0));
    }
  } 
}  

void mouseDragged(){
  //Compute the rotation maked by a mouseDragged
  if(globalState == State.GAME){
    rZ += (mouseX - mx) * mouseW;
    rX -= (mouseY - my) * mouseW;
    if(rZ > 1){
      rZ=1;
    }
    else if(rZ < -1){
      rZ=-1; 
    }
    if(rX> 1){
      rX=1;
    }
    else if(rX < -1){
      rX=-1; 
    } 
    mx = mouseX;
    my = mouseY;
  }
}

void mouseWheel(MouseEvent event){
  // Increment or decrement mouseWheel by 0.0005 in between 0.025 and 0.0008 
  if(globalState == State.GAME){
    float e = event.getCount();
    float k;
    if(e > 0){
      k = mouseW - 0.0005;
    }
    else{
      k = mouseW + 0.0005;
    }
    if((k <= 0.025) && ( k >= 0.0008)){
      mouseW = k; 
    }
  }
}

void keyPressed(){
  // If SHIFT pressed, got to SHIFTED mode
  if(key == CODED && keyCode == SHIFT){
    globalState = State.SHIFTED;
  }
}

void keyReleased(){
  // If SHIFT released, go to GAME mode
  if(key == CODED && keyCode == SHIFT){
    globalState = State.GAME;
  }
}  

void drawMySurface() {
  mySurface.beginDraw();
  mySurface.background(0,51,51);
  mySurface.endDraw();
}

void drawTopView() {
  topView.beginDraw();
  topView.background(255,255,255);
  float x = map(mover.location.x,-boxX/2,boxX/2,0,130);
  float y = map(mover.location.z,-boxZ/2,boxZ/2,-130,0);
  float ratio = 2*130.0/boxX;
  topView.fill(0,0,0);
  topView.ellipse(x, -y,sizeSphere*ratio, sizeSphere*ratio);
  for(PVector v : cylindersShifted){
    float i = map(v.x-width/2,-boxX/2,boxX/2,0,130);
    float j = map(v.y-height/2,-boxZ/2,boxZ/2, 0,130);
    topView.fill(255,0,127);
    topView.ellipse(i, j, cylinderBaseSize*ratio, cylinderBaseSize*ratio);
  }  
  topView.endDraw();
} 

void drawDisplayScore(){
  displayScore.beginDraw();
  displayScore.background(230,4,35);
  displayScore.textSize(14);
  displayScore.text("Score : \n" + score, 5 , 15);
  displayScore.text("Velocity : \n" + velocityForScore, 5, 60);
  displayScore.text("Last score: \n" + lastScore, 5, 100);
  displayScore.endDraw();
}  