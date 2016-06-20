class Mover {
  PVector location;
  PVector velocity;
  PVector gravityForce;
  float gravityConstant = 9.81;
  
  //Initialise the gravityForce, location of the ball, velocity of the ball
  Mover() {
    gravityForce = new PVector(0,0,0);
    location = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
  }
  
  //Move the ball according to the computed velocity
  void update() {
    location.add(velocity);
  }
  
  void display() {
    stroke(0);
    strokeWeight(2);
    translate(location.x, location.y, -location.z);
    sphere(sizeSphere);
  }
  //Compute Velocity according to Gravity on the ball
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
    velocityForScore = (float) Math.sqrt((velocity.x*velocity.x) + (velocity.z * velocity.z));
  }
  
  //Make the ball bounce over box bounds
  void checkEdges(){
    //multiply by 0.8 to make the ball slower after bounces 
    if(location.x > 95){
      location.x = 95;
      velocity.set(-velocity.x, velocity.y,velocity.z).mult(0.8);
      updateScore(-velocityForScore);
    }
    else if(location.x < -95){
      location.x = -95;
      velocity.set(-velocity.x, velocity.y,velocity.z).mult(0.8);
      updateScore(-velocityForScore);
    }
    if(location.z > 95){
      location.z = 95;
      velocity.set(velocity.x, velocity.y, -velocity.z).mult(0.8);
      updateScore(-velocityForScore);
    }
    else if(location.z < -95){
      location.z = -95;
      velocity.set(velocity.x, velocity.y, -velocity.z).mult(0.8);
      updateScore(-velocityForScore);
    }  
  }
  
  //Update the velocity when the ball collide with a cylinder
  void checkCylinderCollision(ArrayList<PVector> a){
    for(PVector v: a){
      PVector cyl = new PVector(v.x, 0, -v.y);    // translate Cylinder coordonate to be in same coordonate than ball
      if(distance(cyl, location) < (cylinderBaseSize + sizeSphere)){
        updateScore(velocityForScore);
        PVector n = PVector.sub(cyl, location).normalize();
        PVector n2 = new PVector(n.x, n.y, n.z);
        PVector vel = PVector.sub(velocity, n2.mult(velocity.dot(n2)*2));
        velocity = (new PVector(vel.x, 0, vel.z)).mult(0.8);  //multiply by 0.8 to make the ball slower after bounces 
        location = cyl.sub(n.normalize().mult(sizeSphere+cylinderBaseSize+0.1)); //Relocate the ball after bounce
      }
    }
  }
  
  //Methode to compute distance between two PVector
  double distance(PVector v1, PVector v2){
    return sqrt(pow(v2.x-v1.x, 2)+pow(v2.y-v1.y, 2)+ pow(v2.z-v1.z, 2));
  }
  
  void updateScore(float vel){
    lastScore = vel;
    score += vel;
    scores.add(score);
  }  
}