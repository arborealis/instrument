import ddf.minim.*;
import ddf.minim.ugens.*;
import controlP5.*;

ControlP5 cp5;
Minim minim;
AudioOutput out;
Delay[] delays;
Sampler sample = null;

float amplitude1 = 0.05;
float amplitude2 = 0.05;
float amplitude3 = 0.05;
float amplitude4 = 0.1;

float time1 = 1/64.0;
float time2 = 1/32.0;
float time3 = 3/64.0;
float time4 = 1/8.0;

float MAX_AMP = 1;
float MAX_TIME = 1;
int SLIDER_HEIGHT = 20;
int SLIDER_WIDTH = 500;

void setup()
{
  size( 700, 400 );

  minim = new Minim(this);
  out = minim.getLineOut();
  
  delays = new Delay[4];
  delays[0] = new Delay( MAX_AMP, MAX_TIME, true, true );
  delays[1] = new Delay( MAX_AMP, MAX_TIME, true, true );
  delays[2] = new Delay( MAX_AMP, MAX_TIME, true, true );
  delays[3] = new Delay( MAX_AMP, MAX_TIME, true, true );
  updateDelays();

  selectInput("Select an audio file to use", "selectFile");

  cp5 = new ControlP5(this);
  cp5.addSlider("amplitude1", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("time1", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("amplitude2", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("time2", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("amplitude3", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("time3", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("amplitude4", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("time4", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
}

void selectFile(File filename)
{
  MultiChannelBuffer buf = new MultiChannelBuffer(1,2);
  minim.loadFileIntoBuffer(filename.getPath(), buf);
  
  sample  = new Sampler( buf, 44100, 1 );
  sample.looping = true;

  sample.patch(delays[0]).patch(delays[1]).patch(delays[2]).patch(delays[3]).patch(out);
  sample.trigger();      
}

void draw()
{
  background(0);  
}

public void controlEvent(ControlEvent theEvent)
{
  updateDelays();
}

void updateDelays()
{
  delays[0].setDelTime(time1);
  delays[0].setDelAmp(amplitude1);
  delays[1].setDelTime(time2);
  delays[1].setDelAmp(amplitude2);
  delays[2].setDelTime(time3);
  delays[2].setDelAmp(amplitude3);
  delays[3].setDelTime(time4);
  delays[3].setDelAmp(amplitude4);
}

