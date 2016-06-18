import processing.video.*;

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

float score = 0f;
float lastScore = 0f;
float velocityForScore = 0f;

//A shape representing cylinder.
PShape openCylinder;

//ArrayLists containing coordinates for cylinder for each state
ArrayList<PVector> cylindersShifted = new ArrayList();
ArrayList<PVector> cylindersGame = new ArrayList();
ArrayList<Float> scores = new ArrayList();

Mover mover;
Cylinder c;
PGraphics mySurface;
PGraphics topView;
PGraphics displayScore;
PGraphics barChart;
PGraphics webcam;
Movie video;
HScrollbar scroll;
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
  barChart = createGraphics(900,100,P2D);
  webcam = createGraphics(200,200,P2D);
  scroll = new HScrollbar(280,780,300,10);
  
  video = new Movie(this, "testvideo.mp4");
  video.read();
  video.loop();
}

void draw() {

  background(80,255,20);

  drawMySurface();
  image(mySurface,0,650);  
  drawTopView();
  image(topView,10,660);
  drawDisplayScore();
  image(displayScore,150,660);
  drawBarChart();
  image(barChart,270,660);
  drawWebcam();
  image(webcam,0,0);
  
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
  
  if(mouseY < 650){
    c.set(mouseX,mouseY, 0);  //Draw cylinder following the cursor
    c.drawing(mouseX, mouseY, 0);
  }

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
  if(mouseY <= 650){
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

void drawBarChart(){
  barChart.beginDraw();
  barChart.background(255,230,230);
  for(int i =0 ; i < scores.size() ; i++){
     float d = map(scores.get(i),-200f,200f,0f,95f);
     float coefficient = scroll.getPos()*2.5;
     if( d > 0){
       barChart.fill(10,10,240);
       barChart.rect(i*coefficient+ 5*i,(float) (100-d), 5,(float) d);
     }     
  }  
  for(float j = 0; j < 100; j +=7.7){
    barChart.strokeWeight(1);
    barChart.stroke(255,230,230);
    barChart.line(0,j,900,j);
  }  
     
  barChart.endDraw();
}

void drawWebcam(){
  if (video.available() == true) {
    pushMatrix();
    translate(1000,0);
    video.read();
    PImage img = video.get();
    img.resize(200,200);
    image(img,0,0);
    PImage img2 = sobel(img);
    img2.resize(200,200);
    image(img2,0,200);
    ArrayList<PVector> lines = hough(sobel(img), 6, 120);
    ArrayList<ArrayList<PVector>> temporaryIntersect = displayQuads(lines);
    popMatrix();
    TwoDThreeD two = new TwoDThreeD(width, height);
    PVector rotations = new PVector();
    if (temporaryIntersect.size() != 0) {
      rotations = two.get3DRotations(temporaryIntersect.get(0));    
      rX = map(rotations.x, -PI / 3, PI / 3, -1, 1);
      rZ = map(rotations.z, -PI / 3, PI / 3, -1, 1);
    }
    
  }
}  