static class CWComparator implements Comparator<PVector> {
  PVector center;
  public CWComparator(PVector center) {
  this.center = center;
  }
  @Override
  public int compare(PVector b, PVector d) {
    if(Math.atan2(b.y-center.y,b.x-center.x)<Math.atan2(d.y-center.y,d.x-center.x))
      return -1;
    else return 1;
    }
}
public static List<PVector> sortCorners(List<PVector> quad, float width, float height){
  // Sort corners so that they are ordered clockwise
  if(quad.size() != 0){
    PVector a = quad.get(0);
    PVector b = quad.get(2);
    PVector center = new PVector((a.x+b.x)/2,(a.y+b.y)/2);
    Collections.sort(quad,new CWComparator(center));
    float dist = distance(new PVector(0,0), new PVector(width,height));
    int index = 0;
    for(int i = 0; i < 4; i++){
      PVector vect = quad.get(i);
      float currDist = distance(vect,new PVector(0,0));
      if( currDist < dist){
        index = i;
        dist = currDist;
      }  
    }
    Collections.rotate(quad,4-index);
  }
  return quad;
}

public static float distance(PVector a, PVector b){
  return (float) Math.sqrt(Math.pow((a.x-b.x),2) + Math.pow((a.y-b.y),2)); 
}