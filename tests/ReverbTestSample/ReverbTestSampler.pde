// Test different parameters for a reverb effect

import ddf.minim.*;
import ddf.minim.ugens.*;
import java.util.Arrays;

Minim       minim;
AudioOutput out;

Delay delay;
Sampler sample;

String filename = "/Users/gregfriedland/src/arborealis/instrument/samples/piano.wav";

// # of frames to use from the sample file
int sampleLength = 44100/4;

void setup()
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

void keyPressed() 
{
  if (key == ' ') {
    if (delay != null) {
      delay.unpatch(out);
    }

    float maxDelayTime = float(mouseX) / width;
    delay = new Delay( maxDelayTime, 0.5, true, true );

    sample.patch(delay).patch(out);
    sample.trigger();      
  }
}

void draw()
{
}
