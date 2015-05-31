class GrainSynthInstrument extends ArborealisInstrument {
	Delay[] delays;
	MoogFilter highPass;
	Gain dryGain, wetGain, wetShiftedGain;
	PitchShift pitchShift;
	Summer summer;

	GrainSynthInstrument(AudioOutput out, MultiChannelBuffer[] bufs) {
		super(InstrumentType.grainsynth, bufs);

    outUgen = new Summer();

    summer = new Summer();

		highPass = new MoogFilter(GrainSynthSettings.HIGH_PASS_MIN_FREQUENCY, 
			GrainSynthSettings.HIGH_PASS_RESONANCE, MoogFilter.Type.HP);

	  pitchShift = new PitchShift(GrainSynthSettings.REVERB_WET_SHIFTED_FACTOR, 2048, 3);

	  dryGain = new Gain(GrainSynthSettings.REVERB_DRY_AMP_DB);
	  wetGain = new Gain(GrainSynthSettings.REVERB_WET_AMP_DB);
	  wetShiftedGain = new Gain(GrainSynthSettings.REVERB_WET_SHIFTED_AMP_DB);

	  delays = new Delay[4];
	  delays[0] = new Delay(1, 1, true, false);
	  delays[1] = new Delay(1, 1, true, false);
	  delays[2] = new Delay(1, 1, true, false);
	  delays[3] = new Delay(1, 1, true, false);

	  delays[0].setDelTime(GrainSynthSettings.REVERB_TIME1);
	  delays[1].setDelTime(GrainSynthSettings.REVERB_TIME2);
	  delays[2].setDelTime(GrainSynthSettings.REVERB_TIME3);
	  delays[3].setDelTime(GrainSynthSettings.REVERB_TIME4);

	  // a placeholder ugen; FIX is this necessary?
	  Line silence = new Line(1, 0, 0);
	  silence.patch(outUgen);

	  // patching the reverb wet
	  outUgen.patch(delays[0]).patch(delays[1]).patch(delays[2]).patch(delays[3]).patch(highPass).patch(wetGain).patch(summer);

	  // patching the shifted reverb wet
	  delays[3].patch(pitchShift).patch(wetShiftedGain).patch(summer);

	  // patching the original signal
	  silence.patch(outUgen).patch(dryGain).patch(summer);

	  summer.patch(out);
	}

	void updateSettings() {
	  if (delays == null)
	    return;

	  delays[0].setDelAmp(GrainSynthSettings.REVERB_AMP1);
	  delays[1].setDelAmp(GrainSynthSettings.REVERB_AMP2);
	  delays[2].setDelAmp(GrainSynthSettings.REVERB_AMP3);
	  delays[3].setDelAmp(GrainSynthSettings.REVERB_AMP4);

	  highPass.frequency.setLastValue(GrainSynthSettings.HIGH_PASS_MIN_FREQUENCY);
	  highPass.resonance.setLastValue(GrainSynthSettings.HIGH_PASS_RESONANCE);

	  dryGain.setValue(GrainSynthSettings.REVERB_DRY_AMP_DB);
	  wetGain.setValue(GrainSynthSettings.REVERB_WET_AMP_DB);
	  wetShiftedGain.setValue(GrainSynthSettings.REVERB_WET_SHIFTED_AMP_DB);

	  pitchShift.shiftFactor.setLastValue(GrainSynthSettings.REVERB_WET_SHIFTED_FACTOR);		
	}
}