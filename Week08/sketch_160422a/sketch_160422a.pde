PImage img;
PImage result;
HScrollbar thresholdBar;
void settings() {
  size(800, 600);
}
void setup() {
  thresholdBar = new HScrollbar(0, 580, 800, 20);
  img = loadImage("C:/Users/Raphael/Documents/VisualComputing/Week08/a.jpg");
   // create a new, initially transparent, 'result' image
  
  //noLoop(); // no interactive behaviour: draw() will be called only once.
}
void draw() {  
  result = createImage(img.width, img.height, RGB);
  for(int i = 0; i < img.width * img.height; i++) {
    // do something with the pixel img.pixels[i]
    float br = hue(img.pixels[i]);
    if(br > 160){
      result.pixels[i] = color(255*thresholdBar.getPos());
    }
    else{
      result.pixels[i] = color(255*(1-thresholdBar.getPos()));
    }  
  }
  image(result, 0, 0);
  thresholdBar.display();
  thresholdBar.update();
}