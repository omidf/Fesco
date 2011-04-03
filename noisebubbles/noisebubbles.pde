import hypermedia.video.*;          //  Imports the OpenCV library
import java.awt.Rectangle;
import ddf.minim.analysis.*;
import ddf.minim.*;

OpenCV opencv;                      //  Creates a new OpenCV object
Minim minim;
AudioInput in;
FFT fft;
int w;
PImage fade;
PImage movementImg;                 //  Creates a new PImage to hold the movement image
ArrayList bubbles;                  //  Creates an ArrayList to hold the Bubble objects
PImage bubblePNG;                   //  Creates a PImage that will hold the image of the bubble
PImage fishImg;

void setup(){
	size ( 640, 480 );                      //  Window size of 640 x 480
	opencv = new OpenCV( this );            //  Initialises the OpenCV library
	movementImg = new PImage(640, 480 );   //  Initialises the PImage that holds the movement image
	bubbles = new ArrayList();              //  Initialises the ArrayList
	bubblePNG = loadImage("bubble.png");    //  Load the bubble image into memory
	smooth();
//Sound stuff
        minim = new Minim(this);
        in = minim.getLineIn(Minim.STEREO, 512);
        fft = new FFT(in.bufferSize(),in.sampleRate());
        fft.logAverages(60,7);

}
void youareloud(){
        fft.forward(in.mix);
        for(int i=0; i<fft.avgSize();i++){
          if(fft.getAvg(i) > 3){
            bubbles.add(new Bubble( (int)random( 0, width - 40), 480, ((bubblePNG.width)/10), ((bubblePNG.height)/10)));   //  Adds a new bubble to the array with a random x position
          }  
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
        
}

void draw(){
        background(loadImage("/Users/josepilove/Dropbox/Team Fesco/video proto/underwater_640x480_stretched.jpg"));//drwa detected environemtn
        youareloud();
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
		//poppedBubbles++;                    //  Add 1 to the variable that holds the number of popped bubbles
		return 1;                           //  Return 1 so that the bubble object is destroyed
 	} else {                                 //  If less than 5 pixels of movement are detected,
    		//bubbleY += 10;                      //  increase the y position of the bubble so that it falls down
        	bubbleY -= 10;                      //  increase the y position of the bubble so that it falls down
     		if (bubbleY < 0){               //  If the bubble has dropped off of the bottom of the screen
       			return 1;                       //  Return '1' so that the bubble object is destroyed
                }
	        image(bubblePNG, bubbleX, bubbleY,10,10);    //  Draws the bubble to the screen
     	        return 0;                              //  Returns '0' so that the bubble isn't destroyed
	}

 	}
} 
