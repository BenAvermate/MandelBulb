import peasy.*;

int DIM = 32;
PeasyCam cam;

void setup() {
    size(600,600,P3D);
    windowMove(1600,100); //move window to side of screen
    cam = new PeasyCam(this,500);
}

void draw() {
    background(0);
    for (int i = 0; i < DIM; ++i) {
      for (int j = 0; j < DIM; ++j) {
        for (int k = 0; k < DIM; ++k) {
          float x = map(i,0,DIM,-100,100);
          float y = map(j,0,DIM,-100,100);
          float z = map(k,0,DIM,-100,100);
          stroke(255);
          point(x, y, z);
        }
      }
    }
}
