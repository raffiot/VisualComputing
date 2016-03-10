float mouseW = 1;
float rx = 0;
float rz = 0;
float mx = 0;
float my = 0;

void settings() {
  size(500, 500, P3D);
}
void setup() {
  noStroke();
}
void draw() { 
 background(200);
 textSize(16);
 text("rotateX: " + degrees(rx) + " rotateZ: " + degrees(rz) + " MouseW: " + mouseW, 5, 10,0);
 lights();
 camera(width/2.0, height/2.0, 450, 250, 250, 0, 0, 1, 0);
 translate(width/2, height/2, 0);
 rotateX(-rx);
 rotateZ(rz);
 box(200,10,200);
}

void mousePressed(){
 mx = mouseX;
 my = mouseY;
}  

void mouseDragged(){
  float a = map(mouseY, my, height, 0, PI) * mouseW;
  float b = map(mouseX, mx, width, 0, PI) * mouseW;
  if((a > -(1/3.0)*PI) && (a < (1/3.0)*PI)){
    rx = a; 
  }
  if((b > -(1/3.0)*PI) && (b < (1/3.0)*PI)){
   rz = b; 
  }
}

void mouseWheel(MouseEvent event){
  float e = event.getCount();
  float k;
  if(e > 0){
     k = mouseW + 0.01;
  }
  else{
    k = mouseW - 0.01;
  }
  if((k <= 1.5) && ( k >= 0.2)){
   mouseW = k; 
  }
}