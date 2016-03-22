float cylinderBaseSize = 50;
float cylinderHeight = 50;
int cylinderResolution = 40;
PShape openCylinder = new PShape();
PShape openTriangle1 = new PShape();
PShape openTriangle2 = new PShape();

void settings() {
      size(400, 400, P3D);
}
    void setup() {
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
}
    void draw() {
        background(255);
        translate(mouseX, mouseY, 0);
        shape(openTriangle1);
        shape(openTriangle2);
        shape(openCylinder);
    }