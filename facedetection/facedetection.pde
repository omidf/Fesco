import hypermedia.video.*;          //  Imports the OpenCV library
import java.awt.Rectangle;

OpenCV opencv;                      //  Creates a new OpenCV object
PImage movementImg;                 //  Creates a new PImage to hold the movement image
int poppedBubbles;                  //  Creates a variable to hold the total number of popped bubbles
ArrayList bubbles;                  //  Creates an ArrayList to hold the Bubble objects
PImage bubblePNG;                   //  Creates a PImage that will hold the image of the bubble
PFont font;                         //  Creates a new font object
PImage fishImg;
ArrayList psystems;


void setup(){
	size ( 640, 480 );                      //  Window size of 640 x 480
	opencv = new OpenCV( this );            //  Initialises the OpenCV library
	opencv.capture( 640, 480 );             //  Sets the capture size to 640 x 480
	opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT );    //// load the FRONTALFACE description file
	movementImg = new PImage( 640, 480 );   //  Initialises the PImage that holds the movement image
	poppedBubbles = 0;
	bubbles = new ArrayList();              //  Initialises the ArrayList
	fishImg = loadImage("purpleFish.png");
	bubblePNG = loadImage("bubble.png");    //  Load the bubble image into memory
	font = loadFont("Serif-48.vlw");        //  Load the font file into memory
	textFont(font, 32);
	colorMode(RGB, 255, 255, 255, 100);
	psystems = new ArrayList();
	smooth();
}

void draw(){
	//bubbles.add(new Bubble( (int)random( 0, width - 40),-bubblePNG.height, bubblePNG.width, bubblePNG.height));   //  Adds a new bubble to the array with a random x position
	bubbles.add(new Bubble( (int)random( 0, width - 40), 480, bubblePNG.width, bubblePNG.height));   //  Adds a new bubble to the array with a random x position
	opencv.read();                              //  Captures a frame from the camera
	opencv.flip(OpenCV.FLIP_HORIZONTAL);        //  Flips the image horizontally
	//image(loadImage("/Users/sang/Desktop/underwater.jpg"), 0,0,1000,700 );//drwa detected environemtn
	image( opencv.image(), 0, 0 );              //  Draws the camera image to the screen
	// detect anything ressembling a FRONTALFACE
	Rectangle[] faces = opencv.detect();
	// draw detected face area(s)
	noFill();
	stroke(255,0,0);
	opencv.absDiff();                           //  Creates a difference image
	opencv.convert(OpenCV.GRAY);                //  Converts to greyscale
	opencv.blur(OpenCV.BLUR, 3);                //  Blur to remove camera noise
	opencv.threshold(20);                       //  Thresholds to convert to black and white
	movementImg = opencv.image();               //  Puts the OpenCV buffer into an image object
	for( int i=0; i<faces.length; i++ ) {
		//image( opencv.image(), faces[i].x, faces[i].y,faces[i].width, faces[i].height );  // display the image in memory on the right
        //opencv.loadImage( "/Users/sang/Desktop/home.png", );   //load image from file
		//opencv.convert( GRAY );
		//opencv.ROI( faces[i].x, faces[i].y, faces[i].width, faces[i].height );
		//opencv.brightness( 80 );
		//opencv.contrast( 90 );
		image( fishImg,faces[i].x, faces[i].y, faces[i].width, faces[i].height);
       	//rect( faces[i].x, faces[i].y, faces[i].width, faces[i].height );
        //image( opencv.image(), faces[i].x, faces[i].y );   // show in sketch
       	//movie( "/Users/sang/Desktop/joshFish.mov",  faces[i].x,faces[i].y );    // load movie file
       	//image( loadMovie("/Users/sang/Desktop/joshFish.mov"),faces[i].x, faces[i].y);
	}
	for ( int i = 0; i < bubbles.size(); i++ ){    //  For every bubble in the bubbles array
		Bubble _bubble = (Bubble) bubbles.get(i);    //  Copies the current bubble into a temporary object
		if(_bubble.update() == 1){                  //  If the bubble's update function returns '1'
			bubbles.remove(i);                        //  then remove the bubble from the array
			_bubble = null;                           //  and make the temporary bubble object null
			i--;                                      //  since we've removed a bubble from the array, we need to subtract 1 from i, or we'll skip the next bubble
		}else{                                        //  If the bubble's update function doesn't return '1'
			bubbles.set(i, _bubble);                  //  Copys the updated temporary bubble object back into the array
			_bubble = null;                           //  Makes the temporary bubble object null.
		}
	}
	opencv.remember(OpenCV.SOURCE, OpenCV.FLIP_HORIZONTAL);    // Remembers the camera image so we can generate a difference image next frame. Since we've flipped the image earlier, we need to flip it here too.
	text("Bubbles popped: " + poppedBubbles, 20, 40);          // Displays some text showing how many bubbles have been popped
	// Cycle through all particle systems, run them and delete old ones
 	for (int i = psystems.size()-1; i >= 0; i--) {
		ParticleSystem psys = (ParticleSystem) psystems.get(i);
		psys.run();
		if (psys.dead()) {
			psystems.remove(i);
		}
	}
}

class Bubble{
	int bubbleX, bubbleY, bubbleWidth, bubbleHeight;    //Some variables to hold information about the bubble
	Bubble ( int bX, int bY, int bW, int bH ){           //The class constructor- sets the values when a new bubble object is made
   		bubbleX = bX;
   		bubbleY = bY;
   		bubbleWidth = bW;
   		bubbleHeight = bH;
 	}
	int update(){      //The Bubble update function
		int movementAmount;          //Create and set a variable to hold the amount of white pixels detected in the area where the bubble is
		movementAmount = 0;
		for( int y = bubbleY; y < (bubbleY + (bubbleHeight-1)); y++ ){
			//For loop that cycles through all of the pixels in the area the bubble occupies
			for( int x = bubbleX; x < (bubbleX + (bubbleWidth-1)); x++ ){
       			if ( x < width && x > 0 && y < height && y > 0 ){
					//If the current pixel is within the screen bondaries
         			if (brightness(movementImg.pixels[x + (y * width)]) > 127){
						//and if the brightness is above 127 (in this case, if it is white)
						movementAmount++;
						//Add 1 to the movementAmount variable.
         			}
       			}
     		}
   		}
		if (movementAmount > 5){               //  If more than 5 pixels of movement are detected in the bubble area
			poppedBubbles++;                    //  Add 1 to the variable that holds the number of popped bubbles
			return 1;                           //  Return 1 so that the bubble object is destroyed
 		} else {                                 //  If less than 5 pixels of movement are detected,
    		//bubbleY += 10;                      //  increase the y position of the bubble so that it falls down
        	bubbleY -= 10;                      //  increase the y position of the bubble so that it falls down
     		if (bubbleY < 0){               //  If the bubble has dropped off of the bottom of the screen
       			return 1;                       //  Return '1' so that the bubble object is destroyed
            }
     		image(bubblePNG, bubbleX, bubbleY,30,30);    //  Draws the bubble to the screen
     		return 0;                              //  Returns '0' so that the bubble isn't destroyed
   		}
 	}
}
// When the mouse is pressed, add a new particle system
void mousePressed(){
	psystems.add(new ParticleSystem(int(random(5,25)),new PVector(mouseX,mouseY)));
}
// An ArrayList is used to manage the list of Particles
class ParticleSystem {
	ArrayList particles;    // An arraylist for all the particles
	PVector origin;        // An origin point for where particles are birthed
	ParticleSystem(int num, PVector v) {
		particles = new ArrayList();              // Initialize the arraylist
		origin = v.get();                        // Store the origin point
		for (int i = 0; i < num; i++) {
     		// We have a 50% chance of adding each kind of particle
     		if (random(1) < 0.5) {
       			particles.add(new CrazyParticle(origin));
   			} else {
   				particles.add(new Particle(origin));
     		}
   		}
 	}
	void run() {
		// Cycle through the ArrayList backwards b/c we are deleting
		for (int i = particles.size()-1; i >= 0; i--) {
			Particle p = (Particle) particles.get(i);
			p.run();
			if (p.dead()) {
				particles.remove(i);
			}
		}	
	}
	void addParticle() {
		particles.add(new Particle(origin));
	}
	void addParticle(Particle p) {
		particles.add(p);
	}
	// A method to test if the particle system still has particles
	boolean dead() {
		if (particles.isEmpty()) {
			return true;
		} else {
     		return false;
   		}
 	}
}
// A subclass of Particle
class CrazyParticle extends Particle {
 	//Just adding one new variable to a CrazyParticle
 	// It inherits all other fields from "Particle", and we don't have to retype them!
 	float theta;
 	// The CrazyParticle constructor can call the parent class (super class) constructor
 	CrazyParticle(PVector l) {
   		// "super" means do everything from the constructor in Particle
   		super(l);
   		// One more line of code to deal with the new variable, theta
   		theta = 0.0;
	}
 	// Notice we don't have the method run() here; it is inherited from Particle
 	// This update() method overrides the parent class update() method
 	void update() {
		super.update();
		// Increment rotation based on horizontal velocity
		float theta_vel = (vel.x * vel.mag()) / 10.0f;
		theta += theta_vel;
	}
	// Override timer
	void timer() {
		timer -= 0.5;
	}
	// Method to display
	void render() {
		// Render the ellipse just like in a regular particle
		super.render();
		// Then add a rotating line
		pushMatrix();
		translate(loc.x,loc.y);
		rotate(theta);
		stroke(255,timer);
		popMatrix();
	}
}
// A simple Particle class
class Particle {
	PVector loc;
	PVector vel;
	PVector acc;
	float r;
	float timer;
	// One constructor
	Particle(PVector a, PVector v, PVector l, float r_) {
		acc = a.get();
		vel = v.get();
		loc = l.get();
		r = r_;
		timer = 100.0;
	}
	// Another constructor (the one we are using here)
	Particle(PVector l) {
		acc = new PVector(0,0.05,0);
		vel = new PVector(random(-1,1),random(-2,0),0);
		loc = l.get();
		r = 10.0;
		timer = 100.0;
	}
	void run() {
		update();
		render();
	}
	// Method to update location
	void update() {
		vel.add(acc);
		loc.add(vel);
		timer -= 1.0;
	}
	// Method to display
	void render() {
		ellipseMode(CENTER);
		stroke(255,timer);
  	   	fill(100,timer);
   		ellipse(loc.x,loc.y,r,r);
	}
	// Is the particle still useful?
	boolean dead() {
		if (timer <= 0.0) {
			return true;
		} else {
     		return false;
   		}
 	}
}