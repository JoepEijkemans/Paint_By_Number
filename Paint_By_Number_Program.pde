/*
By Joep Eijkemans

translates any image into a paint-by-number painting. Can color and / or outline the painting
*/

PImage input;
color c = color(255, 255, 255);
float result;
int index;
boolean FirstRun = true;
boolean saved = false;
float []results = {};
//some default colors such as white
color [] Colors = { color(255, 255, 255), color(0, 0, 0), 
  color(255, 0, 0), color(0, 255, 0), color(0, 0, 255) };
boolean ImageProcessed = false;

color OutlineColor = color(10);

float[][] kernel = 
  {{ -1, -1, -1}, 
  { -1, 9, -1}, 
  { -1, -1, -1}};

void setup() {
  size (425, 800);
  textSize(20);
  fill(0);
  String Instructions = " 1. Select an Image to process (.jpg/ .jpeg or .png) The screen will resize to the image size \n\n 2. Select the color palette by clicking on colors within the image \n\n 3. Press R to outline fields or press E to outline and color fields \n\n 4. Press S to save the resulted image \n\n 5. The processed image will appear within the program folder, note that multiple saves without renaming previous ones overrides the previous saved image";
  text(Instructions, 25, 25, width - 25, height - 25);  
  textAlign(CENTER);
  textSize(14);
  text("Copyright: Joep Eijkemans, all rights reserved", width/2, height - 45);
  selectInput("Select an image to process", "imageSelected");
  colorMode(RGB);
  if (input!=null) {
    image(input, 0, 0);
  }
}


void draw() {
  if (input!=null && ImageProcessed == false) {
    image(input, 0, 0);
  }
  if (keyPressed && key == 'e') {
    ProcessImage();
    ImageProcessed = true;
  }
  if (keyPressed && key == 'r' && FirstRun == true) {
    OutlineFields();
    FirstRun = false;
    ImageProcessed = true;
  }
}

void keyReleased() { //save the result as a .png image
  if (key == 's') {
    saveFrame(input + "_processed.png");
    println("Image saved in program folder");
  }
}

void mouseReleased() {
  c = get(mouseX, mouseY);
  if (c != OutlineColor) { //no outline color allowed, or the outlining of colored fields will fail
    Colors = append(Colors, c);
    println("Amount of colors: ", Colors.length);
    println("R:", int(red(Colors[Colors.length-1])), " G:", int(green(Colors[Colors.length-1])), " B:", int(blue(Colors[Colors.length-1])));
  }
}


void OutlineFields() {
  println("Outline fields");
  boolean FoundColor = false;
  for (int i = 0; i < Colors.length; i++) {
    color c1 = Colors[i];
    for (int y = 1; y < height-1; y++) { // Skip top and bottom edges
      for (int x = 1; x < width-1; x++) { // Skip left and right edges
        if (get(x, y) == c1 && FoundColor == false) {
          set(x - 1, y, color(0, 255, 0));
          FoundColor = true;
        } else if (get(x, y) == c1 && get(x+1, y) != c1 && get(x+1, y) != OutlineColor && FoundColor == true) {
          set(x, y, OutlineColor);
        }
      }
    }
    FoundColor = false;
    for (int x = 1; x < width-1; x++) { // Skip left and right edges
      for (int y = 1; y < height-1; y++) { // Skip top and bottom edges
        if (get(x, y) == c1 && FoundColor == false) {
          set(x, y-1, OutlineColor);
          FoundColor = true;
        } else if (get(x, y) == c1 && get(x, y+1) != c1 && get(x, y+1) != OutlineColor && FoundColor == true) {
          set(x, y, OutlineColor);
        }
      }
    }
  }
  for (int x = 0; x < width; x++) { // Skip left and right edges
    for (int y = 0; y < height; y++) { // Skip top and bottom edges
      if (get(x, y) != OutlineColor) {
        set(x, y, color(255, 255, 255));
      }
    }
  }
}

void ProcessImage() {
  for (int u = 0; u <= height; u++) { //from 0 to down
    for (int i = 0; i <= width; i++) { //from 0 to right
      c = get(i, u);
      float lowestNumber = 1000;
      results = new float[0];
      for (int p = 0; p < Colors.length; p++) {
        ProcessPixel(c, Colors[p]);
        for (int q = 0; q < results.length; q++) {
          if (results[q]<lowestNumber) { 
            lowestNumber=results[q]; 
            index = q;
          }
        }
      }
      set(i, u, Colors[index]);
    }
  }
  println("Image Processed");
}

void ProcessPixel(int c1, int c2) {
  float rmean = ( red(c1) + red(c2)) / 2;
  float r = red(c1) - red(c2);
  float g = green(c1) - green(c2);
  float b = blue(c1) - blue(c2);
  int p1 = int(((512+rmean)*r*r)) >> 8;
  int p2 = int(((767-rmean)*b*b)) >> 8;
  result =  sqrt(p1 + 4*g*g + p2); //min value is best
  results = append(results, result);
}


void imageSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel."); 
    exit(); //EBCAC 
  } else {
    input = loadImage (selection.getAbsolutePath());
    println(input);
    if (input.width <= 1980 && input.height <= 1200) { //resizes the image to a maximum of 1980 width and 1200 height
      surface.setSize(input.width, input.height);
    } else {
      surface.setSize(1980, 1200); //remove later and make window scalable, allowing for higher quality images and removes pixel doubt bug
      input.resize(1980, 1200);
    }
  }
}
