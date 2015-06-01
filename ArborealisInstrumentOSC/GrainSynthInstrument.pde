/*
 * MIT License. Copyright (c) 2015 Greg Friedland
 */

// Definition of GrainSynthInstrument class which controls the individual notes made by each player on
// this instrument and the output UGens common to all its notes.

class GrainSynthInstrument extends ArborealisInstrument {
	Delay[] delays;
	MoogFilter highPass;
	Gain dryGain, wetGain, wetShiftedGain;
	PitchShift pitchShift;
	Oscil lfo;
	Summer summer;


	GrainSynthInstrument(AudioOutput out, MultiChannelBuffer[] bufs) {
		super(InstrumentType.grainsynth, bufs);

		// the ugen to output notes to
    outUgen = new Summer();

    // the final ugen to pass to AudioOutput
    summer = new Summer();

    // create the LFO feeding into a high pass filter
    lfo = new Oscil(GrainSynthSettings.LFO_FREQUENCY, GrainSynthSettings.LFO_AMPLITUDE, Waves.SINE);
    updateLFO();
    highPass = new MoogFilter(1, GrainSynthSettings.HIGH_PASS_RESONANCE, MoogFilter.Type.HP);
    lfo.patch(highPass.frequency);
	      
	  // Ugen to do pitch-shifting on the wet reverb output
	  pitchShift = new PitchShift(GrainSynthSettings.REVERB_WET_SHIFTED_FACTOR, 2048, 3);

	  // Ugens to control the volume of the dry, wet and wet shifted outputs
	  dryGain = new Gain(GrainSynthSettings.REVERB_DRY_AMP_DB);
	  wetGain = new Gain(GrainSynthSettings.REVERB_WET_AMP_DB);
	  wetShiftedGain = new Gain(GrainSynthSettings.REVERB_WET_SHIFTED_AMP_DB);

	  // the delay Ugens used in the reverb
	  delays = new Delay[4];
	  delays[0] = new Delay(1, 1, true, false);
	  delays[1] = new Delay(1, 1, true, false);
	  delays[2] = new Delay(1, 1, true, false);
	  delays[3] = new Delay(1, 1, true, false);
	  delays[0].setDelTime(GrainSynthSettings.REVERB_TIME1);
	  delays[1].setDelTime(GrainSynthSettings.REVERB_TIME2);
	  delays[2].setDelTime(GrainSynthSettings.REVERB_TIME3);
	  delays[3].setDelTime(GrainSynthSettings.REVERB_TIME4);

	  // patching the reverb wet
	  outUgen.patch(delays[0]).patch(delays[1]).patch(delays[2]).patch(delays[3]).patch(highPass).patch(wetGain).patch(summer);

	  // patching the shifted reverb wet
	  delays[3].patch(pitchShift).patch(wetShiftedGain).patch(summer);

	  // patching the original signal
	  outUgen.patch(dryGain).patch(summer);

	  summer.patch(out);
	}


  // change the mean and amplitude of the LFO feeding into the high pass filter
  // to reflect any changes in the number of notes
  void updateLFO() {
  	float hpFreq = GrainSynthFuncs.highPassFreq(numNotes());
  	lfo.frequency.setLastValue(GrainSynthSettings.LFO_FREQUENCY);
    lfo.amplitude.setLastValue(GrainSynthSettings.LFO_AMPLITUDE * hpFreq);
    lfo.offset.setLastValue(hpFreq);		
	}


  void activate(int x, int y, float z, ArborealisNote note) {
  	super.activate(x, y, z, note);
    updateGain();
    updateLFO();
    updateSettings(); // not sure why this is necessary but it removes a nasty audio feedback loop before the first note is played
  }


  void deactivate(int x, int y) {
  	super.deactivate(x, y);
    updateGain();
    updateLFO();
	}


  void updateGain() {
    int numNotes = constrain(numNotes(), 1, NUM_X);
    float amplitude = map(numNotes, 1, NUM_X, GrainSynthSettings.ADSR_MAX_AMPLITUDE, GrainSynthSettings.ADSR_MAX_AMPLITUDE/NUM_X);//log(NUM_X));

    for (int x = 0; x < NUM_X; x++)
      for (int y = 0; y < NUM_Y; y++)
        if (notes[x][y] != null)
          notes[x][y].update(amplitude);
  }


	void updateSettings() {    
	  if (delays == null)
	    return;

	  delays[0].setDelAmp(GrainSynthSettings.REVERB_AMP1);
	  delays[1].setDelAmp(GrainSynthSettings.REVERB_AMP2);
	  delays[2].setDelAmp(GrainSynthSettings.REVERB_AMP3);
	  delays[3].setDelAmp(GrainSynthSettings.REVERB_AMP4);

	  updateLFO();
	  highPass.resonance.setLastValue(GrainSynthSettings.HIGH_PASS_RESONANCE);

	  dryGain.setValue(GrainSynthSettings.REVERB_DRY_AMP_DB);
	  wetGain.setValue(GrainSynthSettings.REVERB_WET_AMP_DB);
	  wetShiftedGain.setValue(GrainSynthSettings.REVERB_WET_SHIFTED_AMP_DB);

	  pitchShift.shiftFactor.setLastValue(GrainSynthSettings.REVERB_WET_SHIFTED_FACTOR);		
	}
}