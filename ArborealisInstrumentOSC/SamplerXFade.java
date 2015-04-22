
import java.util.Arrays;

import ddf.minim.Minim;
import ddf.minim.MultiChannelBuffer;
import ddf.minim.UGen;

/**
 * SamplerXFade is the UGen version of AudioSample and is
 * the preferred method of triggering short audio files. 
 * You will also find SamplerXFade much more flexible,
 * since it provides ways to trigger only part of a sample, and 
 * to trigger a sample at different playback rates. Also, unlike AudioSample,
 * a SamplerXFade lets you specify how many voices (i.e. simultaneous 
 * playbacks of the sample) should have.
 * <p>
 * SamplerXFade provides several inputs that allow you to control the properties
 * of a triggered sample. When you call the trigger method, the values of these 
 * inputs are "snapshotted" and used to configure the new voice that will play 
 * the sample. So, changing the values does not effect already playing voices,
 * except for <code>amplitude</code>, which controls the volume of the SamplerXFade 
 * as a whole.
 * 
 * @example Advanced/DrumMachine
 * 
 * @related AudioSample
 * @related UGen
 * 
 * @author Damien Di Fede
 * 
 */

public class SamplerXFade extends UGen
{
	/**
	 * The sample number in the source sample 
	 * the voice will start at when triggering this SamplerXFade.
	 */
	public UGenInput begin;
	
	/**
	 * The sample number in the source sample 
	 * the voice will end at when triggering this SamplerXFade.
	 */
	public UGenInput end;
	
	/**
	 * The attack time, in seconds, when triggering 
	 * this SamplerXFade. Attack time is used to ramp up 
	 * the amplitude of the voice. By default it 
	 * is 0 seconds.
	 */
	public UGenInput attack;
	
	/**
	 * The amplitude of this SamplerXFade. This acts as an
	 * overall volume control. So changing the amplitude
	 * will effect all currently active voices.
	 */
	public UGenInput amplitude;
	
	/**
	 * The playback rate used when triggering this SamplerXFade.
	 */
	public UGenInput rate;
	
	/**
	 * Whether triggered voices should loop or not.
	 */
	public boolean looping;
	
	private MultiChannelBuffer sampleData;
	// what's the sample rate of our sample data
	private float			   sampleDataSampleRate;
	// what's the baseline playback rate.
	// this is set whenever sampleRateChanged is called
	// and is used to scale the value of the rate input
	// when starting a trigger. we need this so that,
	// for example, 22k sample data will playback at
	// the correct speed when played through a 44.1k
	// UGen chain.
	private float 			   basePlaybackRate;
	
	// Trigger class is defined at bottom of SamplerXFade imp
	private Trigger[]		   triggers;
	private int				   nextTrigger;

	// CUSTOM: for xfading
	private int xfadeLength;
	
	/**
	 * Create a new SamplerXFade for triggering the provided file.
	 * 
	 * @param filename 
	 * 			String: the file to load
	 * @param maxVoices
	 * 			int: the maximum number of voices for this SamplerXFade
	 * @param system 
	 * 			Minim: the instance of Minim to use for loading the file
	 *
	 */
	public SamplerXFade( String filename, int maxVoices, Minim system, int _xfadeLength )
	{
		triggers = new Trigger[maxVoices];
		for( int i = 0; i < maxVoices; ++i )
		{
			triggers[i] = new Trigger();
		}
		
		sampleData = new MultiChannelBuffer(1,1);
		sampleDataSampleRate = system.loadFileIntoBuffer( filename, sampleData );
		
		xfadeLength = _xfadeLength;
		createInputs();
	}
	
	/**
	 * Create a SamplerXFade that will use the audio in the provided MultiChannelBuffer
	 * for its sample. It will make a copy of the data, so modifying the provided
	 * buffer after the fact will not change the audio in this SamplerXFade.
	 * The original sample rate of the audio data must be provided
	 * so that the default playback rate of the SamplerXFade can be set properly.
	 * Additionally, you must specify how many voices the SamplerXFade should use,
	 * which will determine how many times the sound can overlap with itself
	 * when triggered. 
	 * 
	 * @param sampleData
	 * 		 	MultiChannelBuffer: the sample data this SamplerXFade will use to generate sound
	 * @param sampleRate
	 * 			float: the sample rate of the sampleData
	 * @param maxVoices
	 * 			int: the maximum number of voices for this SamplerXFade
	 * 
	 * @related MultiChannelBuffer
	 */
	public SamplerXFade( MultiChannelBuffer sampleData, float sampleRate, int maxVoices, int _xfadeLength )
	{
		triggers = new Trigger[maxVoices];
		for( int i = 0; i < maxVoices; ++i )
		{
			triggers[i] = new Trigger();
		}
		
		this.sampleData      = new MultiChannelBuffer( sampleData.getChannelCount(), sampleData.getBufferSize() );
		this.sampleData.set(  sampleData );
		sampleDataSampleRate = sampleRate;
		
		xfadeLength = _xfadeLength;
		createInputs();
	}
	
	private void createInputs()
	{
		begin 			= addControl(0);
		end   			= addControl(sampleData.getBufferSize()-1);
		attack 			= addControl();
		amplitude		= addControl(1);
		rate			= addControl(1);
	}
	
	/**
	 * Trigger this SamplerXFade. If all of the SamplerXFade's voices 
	 * are currently in use, it will use the least recently 
	 * triggered voice, which means whatever that voice is 
	 * currently playing will get cut off. For this reason,
	 * choose the number of voices you want carefully.
	 * 
	 * @shortdesc Trigger this SamplerXFade.
	 */
	public void trigger()
	{
		triggers[nextTrigger].activate();
		nextTrigger = (nextTrigger+1)%triggers.length;
	}
	
	/**
	 * Stop all active voices. In other words,
	 * immediately silence this SamplerXFade.
	 */
	public void stop()
	{
		for( Trigger t : triggers )
		{
			t.stop();
		}
	}
	
	/**
	 * Sets the sample data used by this SamplerXFade by <em>copying</em> the 
	 * contents of the provided MultiChannelBuffer into the internal buffer.
	 * 
	 * @param newSampleData 
	 * 				MultiChannelBuffer: the new sample data for this SamplerXFade
	 * @param sampleRate 
	 * 				float: the sample rate of the sample data
	 * 
	 * @related MultiChannelBuffer
	 */
	public void setSample( MultiChannelBuffer newSampleData, float sampleRate )
	{
		sampleData.set( newSampleData );
		sampleDataSampleRate = sampleRate;
		basePlaybackRate	 = sampleRate / sampleRate();
	}
	
	@Override
	protected void sampleRateChanged()
	{
		basePlaybackRate = sampleDataSampleRate / sampleRate();
	}
	
	@Override
	protected void uGenerate(float[] channels)
	{
		Arrays.fill( channels, 0 );
		for( Trigger t : triggers )
		{
			t.generate( channels );
		}
	}

	private class Trigger
	{
		// begin and end sample numbers
		float beginSample;
		float endSample;
		// playback rate
		float playbackRate;
		// what sample we are at in our trigger. expressed as a float to handle variable rate.
		float sample;
		// how many output samples we have generated, tracked for attack/release
		float outSampleCount;
		// attack time, in samples
		int   attackLength;
		// current amplitude mod for attack
		float attackAmp;
		// how much to increase the attack amp each sample frame
		float attackAmpStep;
		// release time, in samples
		int   release;
		// whether we are done playing our bit of the sample or not
		boolean  done;
		// whether we should start triggering in the next call to generate
		boolean  triggering;
		
		Trigger()
		{
			done = true;
		}
		
		// start this Trigger playing with the current settings of the SamplerXFade
		void activate()
		{
			triggering = true;
		}
        
        // stop this trigger
        void stop()
        {
        	done = true;
        }
		
		// generate one sample frame of data
		void generate( float[] sampleFrame )
		{
			if ( triggering )
			{
				beginSample  = (int)Math.min( begin.getLastValue(), sampleData.getBufferSize()-2);
				endSample    = (int)Math.min( end.getLastValue(), sampleData.getBufferSize()-1 );
				playbackRate = rate.getLastValue();
				attackLength = (int)Math.max( sampleRate() * attack.getLastValue(), 1.f );
				attackAmp    = 0;
				attackAmpStep = 1.0f / attackLength;
				release		  = 0;
				sample		  = beginSample;
				outSampleCount = 0;
				done		  = false;
				triggering    = false;
			}
			
			if ( done ) return;
			
			final float outAmp = amplitude.getLastValue() * attackAmp;
			
			for( int c = 0; c < sampleFrame.length; ++c )
			{
				int sourceChannel = c < sampleData.getChannelCount() ? c : sampleData.getChannelCount() - 1;

				// Custom code ///
				// This where the cross fading happens
				float sampleRel1 = sample - beginSample;
				float sampleRel2 = endSample - sample;

				if (sampleRel1 < xfadeLength) {
					float f1 = outAmp * sampleData.getSample( sourceChannel, sample );
					float f2 = outAmp * sampleData.getSample( sourceChannel, endSample-(xfadeLength-sampleRel1) );
					sampleFrame[c] += f1 * sampleRel1 / xfadeLength + f2 * (xfadeLength - sampleRel1) / xfadeLength;
				} else if (sampleRel2 < xfadeLength) {
					float f1 = outAmp * sampleData.getSample( sourceChannel, sample );
					float f2 = outAmp * sampleData.getSample( sourceChannel, endSample-(xfadeLength-sampleRel2) );
					sampleFrame[c] += f1 * sampleRel2 / xfadeLength + f2 * (xfadeLength - sampleRel2) / xfadeLength;
				} else {
					sampleFrame[c] = outAmp * sampleData.getSample( sourceChannel, sample );					
				}
			}
			
			sample += playbackRate*basePlaybackRate;
			
			if ( sample > endSample )
			{
				if ( looping ) 
				{
					sample -= endSample - beginSample;
				}
				else 
				{
					done = true;
				}
			}
			
			++outSampleCount;
			if ( outSampleCount <= attackLength )
			{
				attackAmp += attackAmpStep;
			}
		}
	}
}
