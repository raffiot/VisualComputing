// Cylinder sizes constant
float cylinderBaseSize = 10;
float cylinderHeight = 20;
int cylinderResolution = 10;

class Cylinder{
  PShape topTriangle;

  Cylinder(){
    openCylinder = new PShape();
    topTriangle = new PShape();
  }
  
  //Method to construct a cylinder at postion mX,mY,mZ
  void set(float mX , float mY, float mZ){
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
    //get the x and y position on a circle for all the sides
    for(int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }

    topTriangle = createShape();
    topTriangle.beginShape(TRIANGLE_FAN);
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    topTriangle.vertex(0, 0, cylinderHeight);
    for(int i = 0; i < x.length; i++) {
      topTriangle.vertex(x[i], y[i], cylinderHeight);
      openCylinder.vertex(x[i], y[i] , 0);
      openCylinder.vertex(x[i], y[i], cylinderHeight);
    }
    topTriangle.endShape();
    openCylinder.endShape();
  }
  
  void drawing(float mX, float mY, float mZ){
    translate(mX, mY, mZ);
    shape(topTriangle);
    shape(openCylinder);
  }
  
  void drawCylinder(ArrayList<PVector> vectors){
    cylindersGame = new ArrayList<PVector>(); //Update cylindersGame ArrayList with cylinders in cylindersShifted to be use it in checkCylinderCollision()
    for(PVector v : vectors){
      pushMatrix();
      if(globalState == State.GAME){
        drawing(v.x-width/2, v.y-height/2, 0);  //draw cylinders to be at the right position in game mode
        cylindersGame.add(new PVector(v.x-width/2, v.y-height/2, 0));  
      }
      else{
        drawing(v.x,v.y, 0);  //In SHIFTED mode only call the drawing method
      }
      popMatrix();
    }
  }
}