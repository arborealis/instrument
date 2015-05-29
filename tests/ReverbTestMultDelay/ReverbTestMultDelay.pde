import ddf.minim.*;
import ddf.minim.ugens.*;
import controlP5.*;

ControlP5 cp5;
Minim minim;
AudioOutput out;
Delay[] delays;
Sampler sample;
MoogFilter highPass;
Gain dryGain, wetGain, wetShiftedGain;
PitchShift pitchShift;
Summer summer;

float amplitude1 = 0.05;
float amplitude2 = 0.05;
float amplitude3 = 0.05;
float amplitude4 = 0.1;

float time1 = 1/64.0;
float time2 = 1/32.0;
float time3 = 3/64.0;
float time4 = 1/8.0;

float high_pass_frequency = 2000;
float high_pass_resonance = 0;

float dry_amplitude_dB = 0;
float wet_amplitude_dB = 0;
float wet_shifted_amplitude_dB = 0;

float wet_shifted_factor = 2;

float MAX_AMP = 1;
float MAX_TIME = 1;
int SLIDER_HEIGHT = 20;
int SLIDER_WIDTH = 500;

void setup()
{
  size( 700, 400 );

  minim = new Minim(this);
  out = minim.getLineOut();
  
  cp5 = new ControlP5(this);
  cp5.addSlider("amplitude1", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("time1", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("amplitude2", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("time2", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("amplitude3", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("time3", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("amplitude4", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("time4", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("high_pass_frequency", 100, 20000).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("high_pass_resonance", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("dry_amplitude_dB", -60, 60).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("wet_amplitude_dB", -60, 60).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("wet_shifted_amplitude_dB", -60, 60).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("wet_shifted_factor", 0.1, 10).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();

  selectInput("Select an audio file to use", "selectFile");
}

void selectFile(File filename)
{
  MultiChannelBuffer buf = new MultiChannelBuffer(1,2);
  minim.loadFileIntoBuffer(filename.getPath(), buf);
  
  sample = new Sampler( buf, 44100, 3 );
  sample.looping = true;
  sample.trigger();

  initUgens();
}

void initUgens()
{
  println("Initing ugens");

  if (summer != null)
    summer.unpatch(out);

  summer = new Summer();

  highPass = new MoogFilter(high_pass_frequency, high_pass_resonance, MoogFilter.Type.HP);

  pitchShift = new PitchShift(wet_shifted_factor, 2048, 4);

  dryGain = new Gain(dry_amplitude_dB);
  wetGain = new Gain(wet_amplitude_dB);
  wetShiftedGain = new Gain(wet_shifted_amplitude_dB);

  delays = new Delay[4];
  delays[0] = new Delay( MAX_AMP, MAX_TIME, true, false );
  delays[1] = new Delay( MAX_AMP, MAX_TIME, true, false );
  delays[2] = new Delay( MAX_AMP, MAX_TIME, true, false );
  delays[3] = new Delay( MAX_AMP, MAX_TIME, true, false );

  updateUgens();

  sample.patch(highPass).patch(delays[0]).patch(delays[1]).patch(delays[2]).patch(delays[3]).patch(wetGain).patch(summer);

  wetGain.patch(pitchShift).patch(wetShiftedGain).patch(summer);

  sample.patch(dryGain).patch(summer);

  summer.patch(out);
}

void draw()
{
  background(0);  
}

public void controlEvent(ControlEvent theEvent)
{
  updateUgens();
}

void updateUgens()
{
  if (delays == null)
    return;

  //println("Updating ugens");

  delays[0].setDelTime(time1);
  delays[0].setDelAmp(amplitude1);
  delays[1].setDelTime(time2);
  delays[1].setDelAmp(amplitude2);
  delays[2].setDelTime(time3);
  delays[2].setDelAmp(amplitude3);
  delays[3].setDelTime(time4);
  delays[3].setDelAmp(amplitude4);

  highPass.frequency.setLastValue(high_pass_frequency);
  highPass.resonance.setLastValue(high_pass_resonance);

  dryGain.setValue(dry_amplitude_dB);
  wetGain.setValue(wet_amplitude_dB);
  wetShiftedGain.setValue(wet_shifted_amplitude_dB);

  pitchShift.shiftFactor.setLastValue(wet_shifted_factor);
}
