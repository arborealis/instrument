// Test the CPU load when we play multiple Sampler ugens with effects applied

import ddf.minim.*;
import ddf.minim.ugens.*;
import java.util.Arrays;

Minim       minim;
AudioOutput out;

int numPlayers = 20;
String filename = "/Users/gregfriedland/src/arborealis/instrument/samples/grain.wav";
int sampleLength = 44100/4;

void setup()
{
  frameRate(30);
  
  size(395, 200, P2D);
  minim = new Minim(this);
  out   = minim.getLineOut();
  

  for (int i = 0; i < numPlayers; i++) {
    Oscil lfo = new Oscil(0.2, 1000, Waves.SINE);
    lfo.offset.setLastValue(1000);
    MoogFilter highPass = new MoogFilter(1, 0, MoogFilter.Type.HP);
    lfo.patch(highPass.frequency);
    
    ADSR adsr = new ADSR(0.5, 0.1, 0.1, 0.5, 0.5);

    MultiChannelBuffer buf = new MultiChannelBuffer(1,2);
    minim.loadFileIntoBuffer(filename, buf);
    float[] frames = buf.getChannel(0);
    frames = Arrays.copyOfRange(frames, 0, sampleLength);
    MultiChannelBuffer buf2 = new MultiChannelBuffer(sampleLength, 1);
    buf2.setChannel(0, frames);
 
    Sampler sample  = new Sampler( buf2, 44100, 1 );
    sample.looping = true;

    sample.patch(highPass).patch(adsr).patch(out);

    sample.trigger();  
    adsr.noteOn();
  }
}

void draw()
{
  background(0);

}

