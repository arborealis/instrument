//////////// Start of parameters to edit ////////////
static final int OSC_RECEIVE_PORT = 7000;
static final int OSC_SEND_PORT = 8000;
static final int NUM_X = 20;      // how many x sections in the instrument 
static final int NUM_Y = 10;      // how many y sections in the instrument 
static final int BPM = 120;
static final int FPS = 10;       // how many frame per second to run the outer loop
static final boolean VERBOSE = false;

static final int MIN_SILENT_FRAMES_CLIP_SEPARATION = 1000; // min number of frames with value==0, used to separate clips
static final float SILENCE_VALUE_CUTOFF = 0.01;           // sound values below this number are considered silence

public class KeyboardSettings {
  static public final float ADSR_MAX_AMPLITUDE = 0.25;       // constant
  static public final float ADSR_MIN_ATTACK_TIME = 0.25;     // function of 1/y
  static public final float ADSR_MAX_ATTACK_TIME = 2.0;      // function of 1/y
  static public final float ADSR_DECAY_TIME = 0.25;          // constant
  static public final float ADSR_MIN_SUSTAIN_LEVEL = 0.25;   // constant
  static public final float ADSR_MIN_RELEASE_TIME = 0.5;     // function of y
  static public final float ADSR_MAX_RELEASE_TIME = 4;       // function of y

  static public final int HIGH_PASS_MIN_FREQUENCY = 200;
  static public final int HIGH_PASS_MAX_FREQUENCY = 4000;
  static public final float LFO_AMPLITUDE = 0.2;             // the lfo range: percentage of the high pass frequency
  static public final float LFO_FREQUENCY = 0.2;             // how fast does the LFO change

  static public final float CLIP_MIN_FRACTIONAL_LENGTH = 0.5;// how long to make the shortest clip to repeat
  static public final float CLIP_MAX_FRACTIONAL_LENGTH = 1;  // how long to make the shortest clip to repeat

  // Uncomment one of the lines below to load from a default file or trigger the file dialog, respectively.
  static public final String USE_FILE = "../samples/piano.wav";
  //static public final String USE_FILE = "";
}

public class ArpeggioSettings {
  // Uncomment one of the lines below to load from a default file or trigger the file dialog, respectively.
  static public final String USE_FILE = "../samples/arp.wav";
  //static public final String USE_FILE = "";
}

public class GrainSynthSettings {
  static public final float ADSR_MAX_AMPLITUDE = 0.25;       // constant
  static public final float ADSR_MIN_ATTACK_TIME = 0.25;     // function of 1/y
  static public final float ADSR_MAX_ATTACK_TIME = 2.0;      // function of 1/y
  static public final float ADSR_DECAY_TIME = 0.25;          // constant
  static public final float ADSR_MIN_SUSTAIN_LEVEL = 0.25;   // constant
  static public final float ADSR_MIN_RELEASE_TIME = 0.5;     // function of y
  static public final float ADSR_MAX_RELEASE_TIME = 4;       // function of y

  static public final int HIGH_PASS_MIN_FREQUENCY = 200;
  static public final int HIGH_PASS_MAX_FREQUENCY = 4000;
  static public final float LFO_AMPLITUDE = 0.2;             // the lfo range: percentage of the high pass frequency
  static public final float LFO_FREQUENCY = 0.2;             // how fast does the LFO change

  static public final float CLIP_MIN_FRACTIONAL_LENGTH = 0.5;// how long to make the shortest clip to repeat
  static public final float CLIP_MAX_FRACTIONAL_LENGTH = 1;  // how long to make the shortest clip to repeat

  // Uncomment one of the lines below to load from a default file or trigger the file dialog, respectively.
  static public final String USE_FILE = "../samples/grain.wav";
  //static public final String USE_FILE = "";
}
//////////// End of parameters to edit ////////////


public class InstrumentSettings {
  public String useFile;
  InstrumentSettings(String useFile) {
    this.useFile = useFile;
  }
}
