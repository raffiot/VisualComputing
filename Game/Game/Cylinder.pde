// Cylinder sizes constant
float cylinderBaseSize = 10;
float cylinderHeight = 20;
int cylinderResolution = 10;

class Cylinder{
  PShape openCylinder;
  PShape openTriangle1;
  PShape openTriangle2;

  Cylinder(){
    openCylinder = new PShape();
    openTriangle1 = new PShape();
    openTriangle2 = new PShape();
  }
  
  //Method to draw a cylinder at postion mX,mY,mZ
  void show(float mX , float mY, float mZ){
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
    //get the x and y position on a circle for all the sides
    for(int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
      openTriangle1 = createShape();
      openTriangle1.beginShape(TRIANGLE_FAN);
      openTriangle2 = createShape();
      openTriangle2.beginShape(TRIANGLE_FAN);
      openCylinder = createShape();
      openCylinder.beginShape(QUAD_STRIP);
        //draw the border of the cylinder
        openTriangle1.vertex(0, 0, 0);
        openTriangle2.vertex(0, 0, cylinderHeight);
        for(int i = 0; i < x.length; i++) {
          openTriangle1.vertex(x[i], y[i], 0);
          openTriangle2.vertex(x[i], y[i], cylinderHeight);
          openCylinder.vertex(x[i], y[i] , 0);
          openCylinder.vertex(x[i], y[i], cylinderHeight);
        }
        openTriangle1.endShape();
        openTriangle2.endShape();
        openCylinder.endShape();
        translate(mX, mY, mZ);
        shape(openTriangle1);
        shape(openTriangle2);
        shape(openCylinder);
    }
  
  void drawCylinder(ArrayList<PVector> vectors){
    cylindersGame = new ArrayList<PVector>(); //Update cylindersGame ArrayList with cylinders in cylindersShifted to be use it in checkCylinderCollision()
    for(PVector v : vectors){
      pushMatrix();
      if(globalState == State.GAME){
        show(v.x-width/2, v.y-height/2, 0);  //translate cylinders to be at the right position in game mode
        cylindersGame.add(new PVector(v.x-width/2, v.y-height/2, 0));  
      }
      else{
        show(v.x,v.y, 0);  //In SHIFTED mode only call the show method
      }
      popMatrix();
    }
  }
}