import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import ddf.minim.ugens.*; 
import java.util.Arrays; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ReverbTest extends PApplet {

// Test different parameters for a reverb effect





Minim       minim;
AudioOutput out;

Delay delay;
Sampler sample;

String filename = "/Users/gregfriedland/src/arborealis/instrument/samples/piano.wav";

// # of frames to use from the sample file
int sampleLength = 44100/4;

public void setup()
{
  frameRate(30);
  
  size(395, 200, P2D);
  minim = new Minim(this);
  out   = minim.getLineOut();

	MultiChannelBuffer buf = new MultiChannelBuffer(1,2);
	minim.loadFileIntoBuffer(filename, buf);
	float[] frames = buf.getChannel(0);
	frames = Arrays.copyOfRange(frames, 0, sampleLength);
	MultiChannelBuffer buf2 = new MultiChannelBuffer(sampleLength, 1);
	buf2.setChannel(0, frames);

  sample  = new Sampler( buf, 44100, 1 );
  delay = null;
}

public void keyPressed() 
{
  if (key == ' ') {
    if (delay != null) {
      delay.unpatch(out);
    }

    float maxDelayTime = PApplet.parseFloat(mouseX) / width;
    delay = new Delay( maxDelayTime, 0.5f, true, true );

    sample.patch(delay).patch(out);
    sample.trigger();      
  }
}

public void draw()
{
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ReverbTest" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
