/*
 * MIT License. Copyright (c) 2015 Greg Friedland
 */


// Provides on screen controls for some settings and handles the events
// for these controls

ControlP5 cp5;

// ControlP5 requires simple global variables to work 
float grainsynth_reverb_amp1 = GrainSynthSettings.REVERB_AMP1;
float grainsynth_reverb_amp2 = GrainSynthSettings.REVERB_AMP2;
float grainsynth_reverb_amp3 = GrainSynthSettings.REVERB_AMP3;
float grainsynth_reverb_amp4 = GrainSynthSettings.REVERB_AMP4;
float grainsynth_reverb_dry_amp_db = GrainSynthSettings.REVERB_DRY_AMP_DB;
float grainsynth_reverb_wet_amp_db = GrainSynthSettings.REVERB_WET_AMP_DB;
float grainsynth_reverb_wet_shifted_amp_db = GrainSynthSettings.REVERB_WET_SHIFTED_AMP_DB;
float grainsynth_reverb_wet_shifted_factor = GrainSynthSettings.REVERB_WET_SHIFTED_FACTOR;
float grainsynth_lfo_frequency = GrainSynthSettings.LFO_FREQUENCY;
float grainsynth_lfo_amplitude = GrainSynthSettings.LFO_AMPLITUDE;
int grainsynth_high_pass_min_frequency = GrainSynthSettings.HIGH_PASS_MIN_FREQUENCY;
int grainsynth_high_pass_max_frequency = GrainSynthSettings.HIGH_PASS_MAX_FREQUENCY;
float grainsynth_high_pass_resonance = GrainSynthSettings.HIGH_PASS_RESONANCE;

void createControls() {
  cp5 = new ControlP5(this);

  cp5.addSlider("grainsynth_reverb_amp1", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("grainsynth_reverb_amp2", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("grainsynth_reverb_amp3", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("grainsynth_reverb_amp4", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("grainsynth_reverb_dry_amp_db", -90, 90).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("grainsynth_reverb_wet_amp_db", -90, 90).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("grainsynth_reverb_wet_shifted_amp_db", -90, 90).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("grainsynth_reverb_wet_shifted_factor", 0.1, 10).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("grainsynth_lfo_frequency", 0.1, 10).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("grainsynth_lfo_amplitude", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("grainsynth_high_pass_min_frequency", 100, 20000).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("grainsynth_high_pass_max_frequency", 100, 20000).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
  cp5.addSlider("grainsynth_high_pass_resonance", 0, 1).setSize(SLIDER_WIDTH,SLIDER_HEIGHT).linebreak();
}

// Handle a control event such as a slider drag
void controlEvent(ControlEvent theEvent) {
  GrainSynthSettings.REVERB_AMP1 = grainsynth_reverb_amp1;
  GrainSynthSettings.REVERB_AMP2 = grainsynth_reverb_amp2;
  GrainSynthSettings.REVERB_AMP3 = grainsynth_reverb_amp3;
  GrainSynthSettings.REVERB_AMP4 = grainsynth_reverb_amp4;
  GrainSynthSettings.REVERB_DRY_AMP_DB = grainsynth_reverb_dry_amp_db;
  GrainSynthSettings.REVERB_WET_AMP_DB = grainsynth_reverb_wet_amp_db;
  GrainSynthSettings.REVERB_WET_SHIFTED_AMP_DB = grainsynth_reverb_wet_shifted_amp_db;
  GrainSynthSettings.REVERB_WET_SHIFTED_FACTOR = grainsynth_reverb_wet_shifted_factor;
  GrainSynthSettings.LFO_FREQUENCY = grainsynth_lfo_frequency;
  GrainSynthSettings.LFO_AMPLITUDE = grainsynth_lfo_amplitude;
  GrainSynthSettings.HIGH_PASS_MIN_FREQUENCY = grainsynth_high_pass_min_frequency;
  GrainSynthSettings.HIGH_PASS_MAX_FREQUENCY = grainsynth_high_pass_max_frequency;
  GrainSynthSettings.HIGH_PASS_RESONANCE = grainsynth_high_pass_resonance;

  for (ArborealisInstrument instrument : instruments) {
    if (instrument != null)
      instrument.updateSettings();
  }
}
