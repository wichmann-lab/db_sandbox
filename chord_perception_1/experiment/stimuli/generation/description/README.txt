Stimulus generation

Stimuli in pure tone condition

The stimuli used in the pure tone condition were generated with MATLAB. The chords consisted of 5 superimposed sine wave components of equal amplitude. The probes consisted of single sine wave tones, equal in amplitude to the individual sine wave components that comprised the chords. All chords and probes were windowed with a symmetric tapered cosine window (ratio of cosine-tapered section length to the length of the entire window, a = 0.75; an a of 0 would result in a rectangular window, an a of 1 would result in a Hann window) to eliminate clicking noise at the onset and offset of sound.

Stimuli in piano tone condition

he chords and probe tones in the piano tone condition consisted of artificially generated piano tones. The stimuli were created with the music composition software MuseScore (MuseScore 2.0.3, 2016). First the tones were manually entered using the music notation features of the programme. Its in-built synthesizer was used to generate realistic instrumental playback. The stimuli were then exported from MuseScore in .wav format and further cropped and windowed using an asymmetric tapered cosine window in MATLAB in order to retain the characteristic piano attack (first half of the window used a = 0.1, second half used a = 0.75). The tones were then superimposed to create the chord.

For professional musicians (subjects DC and CS), the amplitude of the probe .wav files was altered in MATLAB to approximate the amplitude of individual the components in the chord, as was done with the pure tone stimuli. This was achieved by dividing the amplitude of the MuseScore output file by the number of chord components. The non-amplitude-corrected versions of the experiment are PianoSession1.m and PianoSession2.m, and the amplitude-corrected versions are newPianoSession1.m and newPianoSession2.m. The subject JS was tested with both versions of the experiment to check if the alteration introduced any noticeable differences in responses.

White noise

Gaussian white noise, presented between trials to minimise the impact of successive trials on each other, was generated in MATLAB. Albeit very rare, the standard Gaussian distribution contains values beyond a standard deviation, outside the range accepted by the DAC. In order to prevent unwanted sound artefacts due to clipping of samples above 1 and below -1, the variance of the distribution was compressed and the few remaining values above 1 and below -1 were replaced with 1 and -1, respectively.