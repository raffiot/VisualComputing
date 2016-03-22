class Mover {
  PVector location;
  PVector velocity;
  PVector gravityForce;
  float gravityConstant = 9.81;
  
  Mover() {
    gravityForce = new PVector(0,0,0);
    location = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
  }
  void update() {
    location.add(velocity);
  }
  void display() {
    stroke(0);
    strokeWeight(2);
    fill(127);
    translate(location.x, location.y, -location.z);
    sphere(10);
  }
  
  void computeVelocity(float rotZ, float rotX){
    gravityForce.x = sin(rotZ) * gravityConstant/30.0;
    gravityForce.z = sin(rotX) * gravityConstant/30.0;
    float normalForce = 1;
    float mu = 0.01;
    float frictionMagnitude = normalForce * mu;
    PVector friction = new PVector(velocity.x, velocity.y, velocity.z);
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    velocity.add(friction).add(gravityForce);
  }
  
  void checkEdges(){
    if(location.x+5 > 100){
      location.x = 95;
      velocity.set(-velocity.x, velocity.y,velocity.z).mult(0.6);
    }
    else if(location.x-5 < -100){
      location.x = -95;
      velocity.set(-velocity.x, velocity.y,velocity.z).mult(0.6);
    }
    if(location.z+5 > 100){
      location.z = 95;
      velocity.set(velocity.x, velocity.y, -velocity.z).mult(0.6);
    }
    else if(location.z-5 < -100){
      location.z = -95;
      velocity.set(velocity.x, velocity.y, -velocity.z).mult(0.6);
    }  
  }
}