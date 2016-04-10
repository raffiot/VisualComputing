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
    sphere(sizeSphere);
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
    if(location.x > 95){
      location.x = 95;
      velocity.set(-velocity.x, velocity.y,velocity.z).mult(0.8);
    }
    else if(location.x < -95){
      location.x = -95;
      velocity.set(-velocity.x, velocity.y,velocity.z).mult(0.8);
    }
    if(location.z > 95){
      location.z = 95;
      velocity.set(velocity.x, velocity.y, -velocity.z).mult(0.8);
    }
    else if(location.z < -95){
      location.z = -95;
      velocity.set(velocity.x, velocity.y, -velocity.z).mult(0.8);
    }  
  }
  
  void checkCylinderCollision(ArrayList<PVector> a){
    for(PVector v: a){
      PVector cyl = new PVector(v.x, 0, -v.y);
      if(distance(cyl, location) < (cylinderBaseSize + sizeSphere)){
        PVector n = PVector.sub(location, cyl).normalize();
        PVector vel = PVector.sub(velocity, n.mult(velocity.dot(n)*2));
        velocity = new PVector(vel.x, 0, vel.z);
        location = cyl.sub(n.normalize().mult(sizeSphere+cylinderBaseSize+0.1));
      }
    }
  }
  
  double distance(PVector v1, PVector v2){
    return sqrt(pow(v2.x-v1.x, 2)+pow(v2.y-v1.y, 2)+ pow(v2.z-v1.z, 2));
  }
}