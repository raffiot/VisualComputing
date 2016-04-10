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

//ArrayLists containing coordinates for cylinder for each state
ArrayList<PVector> cylindersShifted = new ArrayList();
ArrayList<PVector> cylindersGame = new ArrayList();

Mover mover;
Cylinder c;

//Different State of the game,
//GAME := State in which we can move the plate and the ball moves
//SHIFTED := State in which we enter when we press SHIFT
enum State{
  GAME, SHIFTED
};
State globalState = State.GAME;


void settings() {
  size(500, 500, P3D);
}

void setup() {
  noStroke();
  mover = new Mover();
  c = new Cylinder();
}

void draw() { 
  background(89);
  
  //Draw depending of game mode
  switch (globalState) {
    
   case GAME:
     //Display top left of parameters
     textSize(16);
     text("rotateX: " + degrees(rX) + " rotateZ: " + degrees(rZ) + " MouseW: " + mouseW, 5, 10,0);
     lights();
     camera(width/2.0, height/2.0, 450, 250, 250, 0, 0, 1, 0);
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
  box(boxX,boxY,boxZ);       //Draw vertical box
  translate(mover.location.x, mover.location.y, mover.location.z); //Draw ball at the good position
  sphere(sizeSphere);
  popMatrix();
  
  pushMatrix();
  c.show(mouseX,mouseY, 0);  //Draw cylinder following the cursor
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
  box(boxX,boxY,boxZ); //draw rotated box
  
  pushMatrix();
  translate(0,-15,0);
  mover.computeVelocity(rotZ,rotX);
  mover.checkCylinderCollision(cylindersGame);
  mover.update();
  mover.display();
  mover.checkEdges();
  popMatrix();
  
  pushMatrix();
  rotateX(PI/2);
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
  