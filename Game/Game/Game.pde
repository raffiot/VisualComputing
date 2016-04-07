float mouseW = 0.01;
float rX = 0;
float rZ = 0;
float mx = 0;
float my = 0;
int boxX = 200;
int boxY = 10;
int boxZ = 200;
int sizeSphere = 10;
ArrayList<PVector> cylinderState = new ArrayList();
ArrayList<PVector> cylinderOnPlate = new ArrayList();
Mover mover;
Cylinder c;

enum State{
  GAME, CYLINDER
};
State globalState = State.GAME;


void settings() {
  size(500, 500, P3D);
}

void setup() {
  noStroke();
  mover = new Mover();
}

void draw() { 
  background(89);

  switch (globalState) {
   
   case GAME: 
     textSize(16);
     text("rotateX: " + degrees(rX) + " rotateZ: " + degrees(rZ) + " MouseW: " + mouseW, 5, 10,0);
     lights();
     camera(width/2.0, height/2.0, 450, 250, 250, 0, 0, 1, 0);
     drawGame();
     break;
     
   case CYLINDER:
     placeCylinder();
     break;
  } 
}

void placeCylinder(){
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(PI/2);
  box(200,10,200);
  translate(mover.location.x, mover.location.y, mover.location.z);
  sphere(sizeSphere);
  popMatrix();
  pushMatrix();
  c = new Cylinder();
  c.show(mouseX,mouseY, 0);
  popMatrix();
  pushMatrix();
  c.drawCylinder(cylinderState);
  popMatrix();
}

void drawGame(){
  translate(width/2, height/2, 0);
  float rotZ = map(rZ,-1,1,-PI/3.0, PI/3.0);
  float rotX = map(rX,-1,1,-PI/3.0, PI/3.0 );
  rotateX(rotX);
  rotateZ(rotZ);
  box(boxX,boxY,boxZ);
  pushMatrix();
  translate(0,-15,0);
  mover.computeVelocity(rotZ,rotX);
  mover.checkHits(cylinderOnPlate);
  mover.update();
  mover.display();
  mover.checkEdges();
  popMatrix();
  pushMatrix();
  rotateX(PI/2);
  c = new Cylinder();
  c.drawCylinder(cylinderState);
  popMatrix();
}

void mousePressed(){
  mx = mouseX;
  my = mouseY;
  if((globalState == State.CYLINDER)){
    if((mx-width/2 > -boxX/2) && (mx-width/2 < boxX/2) && (my-height/2 > -boxZ/2) && (my-height/2 < boxZ/2)){
      cylinderState.add(new PVector(mouseX,mouseY,0));
    }
  } 
}  

void mouseDragged(){
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
  if(key == CODED && keyCode == SHIFT){
    globalState = State.CYLINDER;
  }
}

void keyReleased(){
  if(key == CODED && keyCode == SHIFT){
    globalState = State.GAME;
  }
}  
  