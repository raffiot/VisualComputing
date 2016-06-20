import processing.video.*;
import java.util.Collections;
import java.util.Random;

ArrayList<Integer> bestCandidates;
ArrayList<PVector> vectors;
ArrayList<PVector> intersections = new ArrayList<PVector>();

PImage result;
float max=0;
int[][] gkernel = {{9,12,9},
                  {12,15,12},
                  {9,12,9}};

int[][] hkernel = {{0,1,0},
                  {0,0,0},
                  {0,-1,0}};
int[][] vkernel = {{0,0,0},
                  {1,0,-1},
                  {0,0,0}};
                  

ArrayList<ArrayList<PVector>> displayQuads(ArrayList<PVector> lines){
  QuadGraph qg = new QuadGraph();
  qg.build(lines, width, height);
  ArrayList<ArrayList<PVector>> result = new ArrayList<ArrayList<PVector>>();
  List<int[]> quads = qg.findCycles();
  for (int[] quad : quads) {
    PVector l1 = lines.get(quad[0]);
    PVector l2 = lines.get(quad[1]);
    PVector l3 = lines.get(quad[2]);
    PVector l4 = lines.get(quad[3]);
    ArrayList<PVector> toSort = new ArrayList<PVector>();
    PVector c12 = intersection(l1, l2);
    PVector c23 = intersection(l2, l3);
    PVector c34 = intersection(l3, l4);
    PVector c41 = intersection(l4, l1);
    
    toSort.add(c12);
    toSort.add(c23);
    toSort.add(c34);
    toSort.add(c41);
    // Choose a random, semi-transparent colour
    if(qg.isConvex(c12, c23, c34, c41) && qg.validArea(c12, c23, c34, c41, width*height, 0) && qg.nonFlatQuad(c12, c23, c34, c41)){
      result.add((ArrayList) sortCorners(toSort, width, height));
    }
    
  }
  return result;
}



float[] convolute(PImage image){
  float[] buffer = new float[image.width * image.height];
  for(int i = 0; i< image.width; i++){
    for(int j = 0; j < image.height; j++){ 
      float sum_h = 0;
      float sum_v = 0;
      for(int k = -1; k < 2; k++){
        for(int l = -1; l<2; l++){
          if( (i+k >= 0 && i+k < image.width) && ( j+l >= 0 && j+l < image.height)){
            sum_h += brightness(image.pixels[(j+l)*image.width + i+k]) * hkernel[k+1][l+1];
            sum_v += brightness(image.pixels[(j+l)*image.width + i+k]) * vkernel[k+1][l+1];
          }  
        }
      }
      float sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
      if(sum > max){
        max = sum;
      }
      buffer[j*image.width +i] = sum;
    }  
  }
  return buffer;
}

PImage gaussianBlur(PImage image){
  PImage result = createImage(image.width,image.height, ALPHA);
  
  for(int i = 0; i< image.width; i++){
    for(int j = 0; j < image.height; j++){ 
      float divid = 0;
      float sum = 0;
      for(int k = -1; k < 2; k++){
        for(int l = -1; l<2; l++){
          if( (i+k >= 0 && i+k < image.width) && ( j+l >= 0 && j+l < image.height)){
            sum += brightness(image.pixels[(j+l)*image.width + i+k]) * gkernel[k+1][l+1];
            divid += gkernel[k+1][l+1];
          }  
        }
      }
      result.pixels[j*image.width +i] = color(sum/divid);
    }  
  }
  return result;
}

PImage sobel(PImage img) {

  PImage result = createImage(img.width, img.height, ALPHA);
  // clear the image
  
  for (int i = 0; i < img.width * img.height; i++) {
    if((hue(img.pixels[i]) < 139 && hue(img.pixels[i]) > 96) && (brightness(img.pixels[i]) > 25) && (saturation(img.pixels[i]) > 112)){
      result.pixels[i] = color(255);
    }
    else{
      result.pixels[i] = color(0);
    }  
  }
  result = gaussianBlur(result);
  
  for(int i = 0; i < result.width * result.height; i++) {
    if(brightness(result.pixels[i]) > 40){
      result.pixels[i] = color(255);
    }
    else{
      result.pixels[i] = color(0);
    }
  }
  
  //result = antiGaussianBlur(result);
  float[] buffer = convolute(result);
  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.4f)) { // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }
  return result;
}

//WEEK09
ArrayList<PVector> hough(PImage edgeImg, int nLines, int minVote) {
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  
  // pre-compute the sin and cos values
  float[] tabSin = new float[phiDim];
  float[] tabCos = new float[phiDim];
  float ang = 0;
  float inverseR = 1.f / discretizationStepsR;
  for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
    // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
    tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
    tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
  }
  
  
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        
        for (int phi = 0; phi < phiDim; phi++) {
          //float p = phi * discretizationStepsPhi;
          int r = (int) (x * tabCos[phi] + y * tabSin[phi]);
          r += (rDim -1) /2;
          accumulator[(phi + 1) * (rDim + 2) + (r + 1)] += 1;
        }
        
        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
        // Be careful: r may be negative, so you may want to center onto
        // the accumulator with something like: r += (rDim - 1) / 2
      }
    }
  }
  
  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
    // You may want to resize the accumulator to make it easier to see:
    // houghImg.resize(400, 400);
  houghImg.resize(400,400);  
  houghImg.updatePixels();
  
  
  
  ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
  ArrayList<PVector> vectors = new ArrayList<PVector>();
    
  
  // size of the region we search for a local maximum
  int neighbourhood = 10;
  // only search around lines with more that this amount of votes
  // (to be adapted to your image)

  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      if (accumulator[idx] > minVote) {
        boolean bestCandidate=true;
        // iterate over the neighbourhood
        for(int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
          // check we are not outside the image
          if( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
          for(int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
            // check we are not outside the image
            if(accR+dR < 0 || accR+dR >= rDim) continue;
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            if(accumulator[idx] < accumulator[neighbourIdx]) {
              // the current idx is not a local maximum!
              bestCandidate=false;
              break;
            }
          }
            if(!bestCandidate) break;
        }
        if(bestCandidate) {
          // the current idx *is* a local maximum
          bestCandidates.add(idx);
        }
      }
    }
  }  
  
  Collections.sort(bestCandidates, new HoughComparator(accumulator));
  int i = 0;
  while((i < nLines) && (i < bestCandidates.size())) {
      int idx = bestCandidates.get(i);
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      vectors.add(new PVector(r,phi));
      i++;
  }
  getIntersections(vectors);
  return vectors;
}

ArrayList<PVector> getIntersections(ArrayList<PVector> lines) {
  intersections = new ArrayList<PVector>();
  for (int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
      double d = Math.cos(line2.y)*Math.sin(line1.y) - Math.cos(line1.y)*Math.sin(line2.y);
      float x = (float) ((line2.x*Math.sin(line1.y)-line1.x*Math.sin(line2.y))/d);
      float y = (float) ((-line2.x*Math.cos(line1.y)+line1.x*Math.cos(line2.y))/d);
      // compute the intersection and add it to 'intersections'
      intersections.add(new PVector(x,y));
    }
  }
  return intersections;
}

PVector intersection(PVector l1, PVector l2) {
      double d = Math.cos(l2.y)*Math.sin(l1.y) - Math.cos(l1.y)*Math.sin(l2.y);
      float x = (float) ((l2.x*Math.sin(l1.y)-l1.x*Math.sin(l2.y))/d);
      float y = (float) ((-l2.x*Math.cos(l1.y)+l1.x*Math.cos(l2.y))/d);      
      return new PVector(x,y);
}