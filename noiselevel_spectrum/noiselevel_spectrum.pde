// This file only shows the level of noise on the screen by spectrum
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim; //object that we control the library
AudioInput in;
FFT fft; //fft object: fast fre?? transport. it splits up the sound signal ..
int w;
PImage fade;

int hVal;


float rWidth, rHeight;


void setup()
{
size(640,480,P3D);

minim = new Minim(this); //initialize the minim object
in = minim.getLineIn(Minim.STEREO,512);
fft = new FFT(in.bufferSize(),in.sampleRate());
fft.logAverages(60,7);
stroke(255);
w = width/fft.avgSize();
strokeWeight(w);
strokeCap(SQUARE);

background(0);
fade = get(0,0,width,height);
rWidth = width*0.99;
rHeight= height*0.99;
hVal=0;
}

void draw()
{
 background(0);

 tint(255,255,255,254); //everything that you draw to the scatch is tinted
 image(fade,(width-rWidth)/2,(height-rHeight)/2,rWidth,rHeight);
 noTint();

fft.forward(in.mix);

colorMode(HSB);
stroke(hVal,255,255);
colorMode(RGB);

for(int i=0; i<fft.avgSize();i++)
{
  line((i*w)+(w/2),height,(i*w)+(w/2), height-fft.getAvg(i)*4);
  println(fft.getAvg(i));
}

fade = get(0,0,width,height);

stroke(255);
for(int i=0; i<fft.avgSize();i++)
{
  line((i*w)+(w/2),height,(i*w)+(w/2), height-fft.getAvg(i)*4);
}

hVal+=2;
if(hVal>255)
{
  hVal=0;
}

}