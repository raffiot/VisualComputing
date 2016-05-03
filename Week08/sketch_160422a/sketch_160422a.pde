PImage img;
PImage result;
float max=0;
int[][] kernel = {{12,24,12},
                  {24,40,24},
                  {12,24,12}};
int[][] hkernel = {{0,1,0},
                  {0,0,0},
                  {0,-1,0}};
int[][] vkernel = {{0,0,0},
                  {1,0,-1},
                  {0,0,0}};              
  
void settings() {
  size(800, 600);
}
void setup() {
  img = loadImage("C:/Users/Raphael/Documents/VisualComputing/Week08/board1.jpg");
   // create a new, initially transparent, 'result' image
  
  //noLoop(); // no interactive behaviour: draw() will be called only once.
}
void draw() {  
  result = createImage(img.width, img.height, RGB);
  result = sobel(img);
  image(result, 0, 0);
}

float[] convolute(PImage image){
  float[] buffer = new float[img.width * img.height];
  for(int i = 0; i< img.width; i++){
    for(int j = 0; j < img.height; j++){ 
      float sum_h = 0;
      float sum_v = 0;
      for(int k = -1; k < 2; k++){
        for(int l = -1; l<2; l++){
          if( (i+k >= 0 && i+k < img.width) && ( j+l >= 0 && j+l < img.height)){
            sum_h += brightness(image.pixels[(j+l)*img.width + i+k]) * hkernel[k+1][l+1];
            sum_v += brightness(image.pixels[(j+l)*img.width + i+k]) * vkernel[k+1][l+1];
          }  
        }
      }
      float sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
      if(sum > max){
        max = sum;
      }
      buffer[j*img.width +i] = sum;
    }  
  }
  return buffer;
}

PImage convoluteForImage(PImage image){
  PImage result = createImage(image.width,image.height, ALPHA);
  
  for(int i = 0; i< img.width; i++){
    for(int j = 0; j < img.height; j++){ 
      float divid = 0;
      float sum = 0;
      for(int k = -1; k < 2; k++){
        for(int l = -1; l<2; l++){
          if( (i+k >= 0 && i+k < img.width) && ( j+l >= 0 && j+l < img.height)){
            sum += brightness(image.pixels[(j+l)*img.width + i+k]) * kernel[k+1][l+1];
            divid += kernel[k+1][l+1];
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
    result.pixels[i] = color(0);
    if(hue(img.pixels[i]) < 360 && hue(img.pixels[i]) > 140){
      img.pixels[i] = color(0);
    }
    if(hue(img.pixels[i]) < 110 && hue(img.pixels[i]) > 0){
      img.pixels[i] = color(0);
    }
    if(brightness(img.pixels[i]) > 124){
      img.pixels[i] = color(0);
    } 
    
  }
  //image(img,0,0);
  float[] buffer = convolute(convoluteForImage(img));
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