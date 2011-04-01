// This file only shows the level of noise on the screen by number

import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim; //object that we control the library
AudioInput in;
FFT fft; //fft object: fast fre?? transport. it splits up the sound signal ..
int w;
PImage fade;



void setup()
{
size(640,480);

minim = new Minim(this); //initialize the minim object
in = minim.getLineIn(Minim.STEREO,512);
fft = new FFT(in.bufferSize(),in.sampleRate());
fft.logAverages(60,7);

background(0);

}

void draw()
{
 background(0);



fft.forward(in.mix);


for(int i=0; i<fft.avgSize();i++)
{

  println(fft.getAvg(i));
}


}