float mouseW = 0.01;
float rX = 0;
float rZ = 0;
float mx = 0;
float my = 0;

void settings() {
  size(500, 500, P3D);
}
void setup() {
  noStroke();
}
void draw() { 
 background(89);
 textSize(16);
 text("rotateX: " + degrees(rX) + " rotateZ: " + degrees(rZ) + " MouseW: " + mouseW, 5, 10,0);
 lights();
 camera(width/2.0, height/2.0, 450, 250, 250, 0, 0, 1, 0);
 translate(width/2, height/2, 0);
 rotateX(map(rX,-1,1,-PI/3.0, PI/3.0 ));
 rotateZ(map(rZ,-1,1,-PI/3.0, PI/3.0));
 box(200,10,200);
}

void mousePressed(){
 mx = mouseX;
 my = mouseY;
}  

void mouseDragged(){
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

void mouseWheel(MouseEvent event){
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