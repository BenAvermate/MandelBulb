//TODO find more elegant solution for threading
//TODO render using different methods like fot example raymarching => shaders
//TODO colored points based on? distance?
import peasy.*;

PeasyCam cam;

int DIM = 128;
int n = 32; //order of the mandelbrot set
int t = 4; //amount of threads
ArrayList<PVector> mandelbulb = new ArrayList<PVector>();;
ArrayList<ArrayList> mandelbulbParts = new ArrayList<ArrayList>(4);


int part = 0; 
int threads = 0;

void setup() {
    size(600,600,P3D);
    windowMove(1600,100); //move window to side of screen
    cam = new PeasyCam(this,250); //number is distance away for camera at start
    System.out.println("startting " + t + " threads\n==================================");
}

void calculate() {
    int threadPart = part;
    part++;
    System.out.println("part " + threadPart + " started");
    ArrayList<PVector> mandelbulbPart = new ArrayList<PVector>();
    for (int i = DIM / t * threadPart; i < DIM / t * (threadPart + 1); ++i) {
        for (int j = 0; j < DIM; ++j) {
            boolean edge = false;
            for (int k = 0; k < DIM; ++k) { 
                float x = map(i,0,DIM, -1,1);
                float y = map(j,0,DIM, -1,1);
                float z = map(k,0,DIM, -1,1);
                
                PVector zeta = new PVector(0,0,0); //current mandelbrot iteration
                
                int iterations = 0;
                while(iterations <= 10) {
                    
                    
                    //update c
                    SphereCoordinate zetaSpherical =  spherical(zeta.x,zeta.y,zeta.z);
                    
                    float xnew = pow(zetaSpherical.r, n) * sin(zetaSpherical.theta * n) * cos(zetaSpherical.phi * n);
                    float ynew = pow(zetaSpherical.r, n) * sin(zetaSpherical.theta * n) * sin(zetaSpherical.phi * n);
                    float znew = pow(zetaSpherical.r, n) * cos(zetaSpherical.theta * n);
                    
                    //update zeta
                    zeta.x = xnew + x;
                    zeta.y = ynew + y;
                    zeta.z = znew + z;
                    
                    //stop because mandelbrot-distance
                    if (zetaSpherical.r > 2) {
                        if (edge) {
                            edge = false;
                        }
                        break;
                    }
                    iterations++;
                }
                if (iterations >= 10) {
                    if (!edge) {
                        edge = true;
                        mandelbulbPart.add(new PVector(x * 100,y * 100,z * 100));
                    }
                }
            }
        }
    }
    mandelbulbParts.add(mandelbulbPart);
    System.out.println("part " + threadPart + " added");
}

void draw() {
    //render points in n threads to speedup process
    if (mandelbulbParts.size() < t && threads < t) {
        thread("calculate");
        System.out.println("started thread " + part);
        threads++;
    }
    if (mandelbulbParts.size() == t && mandelbulb.isEmpty()) {
        //mandelbulb  = new ArrayList<PVector>();
        for (int i = 0; i < mandelbulbParts.size(); ++i) {
            mandelbulb.addAll(mandelbulbParts.get(i));
        }
    }
    
    background(0);
    for (PVector p : mandelbulb) {
        stroke(255);
        point(p.x,p.y,p.z);
    }
}

SphereCoordinate spherical(float x, float y, float z) {
    //convert number to spherical coordinates    
    float x2 = x * x;
    float y2 = y * y;      
    float r = sqrt(x2 + y2 + z * z);
    float theta = atan2(sqrt(x2 + y2),z);
    float phi = atan2(y,x);
    return new SphereCoordinate(r,theta,phi);
}

private class SphereCoordinate {
    public float r,theta,phi;
    
    public SphereCoordinate(float r, float theta,float phi) {
        this.r = r;
        this.theta = theta;
        this.phi = phi;
    }
}