/*
 * MIT License. Copyright (c) 2015 Greg Friedland.
 * Adapted from ddf.minim.ugens.Vocoder.java by Damien Di Fede.
 */

// A UGen to shift the pitch of an audio stream without changing it's speed
// Uses FFT and a frequency shift factor (FSF) which translates the amplitude at
// all frequencies f to frequencies FSF*f.

import ddf.minim.UGen;
import ddf.minim.analysis.FFT;

// Modified from ddf.minim.ugens.Vocoder.java
public class PitchShift extends UGen
{
	public UGenInput	audio;
	//public UGenInput	modulator;
	public UGenInput    shiftFactor;

	// the window size we use for analysis
	private int			m_windowSize;

	// how many samples should pass between the
	// beginning of each window
	private int			m_windowSpacing;
	// the sample data from audio
	private float[]		m_audioSamples;
	// our output
	private float[]		m_outputSamples;
	// where we are in our sampling arrays
	private int			m_index;
	// where we are in our output array
	private int			m_outputIndex;

	// sample counter for triggering the next window
	private int			m_triggerCount;
	// the float array we use for constructing our analysis window
	private float[]		m_analysisSamples;
	private float		m_outputScale;

	// used to analyze the audio input
	private FFT			m_audioFFT;

	public PitchShift(float _shiftFactor, int windowSize, int windowCount)
	{
		audio = new UGenInput( InputType.AUDIO );
		shiftFactor = addControl(_shiftFactor);

		float overlapPercent = 1.f;
		m_outputScale = 1.f;
		if ( windowCount > 1 )
		{
			overlapPercent = 1.f / (float)windowCount;
			m_outputScale = overlapPercent / 8.f;
		}
		m_windowSize = windowSize;
		m_windowSpacing = (int)( windowSize * overlapPercent );
		int bufferSize = m_windowSize * 2 - m_windowSpacing;
		m_audioSamples = new float[bufferSize];
		m_outputSamples = new float[bufferSize];
		m_analysisSamples = new float[windowSize];
		m_index = 0;
		m_triggerCount = m_windowSize;
		// need to defer creation of the FFT objects until we know our sample
		// rate.
	}

	protected void sampleRateChanged()
	{
		m_audioFFT = new FFT( m_windowSize, sampleRate() );
		m_audioFFT.window( FFT.HANN );
	}

	private void analyze(FFT fft, float[] src)
	{
		// copy the previous windowSize samples into our analysis window
		for ( int i = m_index - m_windowSize, j = 0; i < m_index; ++i, ++j )
		{
			m_analysisSamples[j] = ( i < 0 ) ? src[src.length + i] : src[i];
		}
		fft.forward( m_analysisSamples );
	}

	protected void uGenerate(float[] out)
	{
		m_audioSamples[m_index] = audio.getLastValue();
		++m_index;
		--m_triggerCount;
		if ( m_index == m_audioSamples.length )
		{
			m_index = 0;
		}

		// we reached the end of our window. analyze and synthesize!
		if ( m_triggerCount == 0 )
		{
			analyze( m_audioFFT, m_audioSamples );

			// store the band amplitude info
			float[] tmp = new float[m_audioFFT.specSize()];
			for ( int i = 0; i < m_audioFFT.specSize(); ++i )
				tmp[i] = m_audioFFT.getBand( i );

			// now set the amplitude based on the frequency multiplied by the scale
			// factor
			for ( int i = 0; i < m_audioFFT.specSize(); ++i )
			{
				float freq = m_audioFFT.indexToFreq(i);
				int ii = m_audioFFT.freqToIndex(freq * shiftFactor.getLastValue());
				m_audioFFT.setBand( i, tmp[ii] );
			}

			// synthesize
			m_audioFFT.inverse( m_analysisSamples );

			// window
			FFT.HANN.apply( m_analysisSamples );

			// accumulate
			for ( int a = 0; a < m_windowSize; ++a )
			{
				int outIndex = m_outputIndex + a;
				if ( outIndex >= m_outputSamples.length )
				{
					outIndex -= m_outputSamples.length;
				}
				m_outputSamples[outIndex] += m_analysisSamples[a] * m_outputScale;
			}

			m_triggerCount = m_windowSpacing;
		}

		for ( int i = 0; i < out.length; ++i )
		{
			out[i] = m_outputSamples[m_outputIndex];
		}
		// eat it.
		m_outputSamples[m_outputIndex] = 0.f;
		// next!
		++m_outputIndex;
		if ( m_outputIndex == m_outputSamples.length )
		{
			m_outputIndex = 0;
		}
	}
}
