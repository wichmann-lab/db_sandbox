function [chordStereo]=createChord(tones,nTones,durChord,sampRate,beta)
%creates stereo chord with a Tukey window, given input tone frequencies
%duration, sampling rate and beta for the window

%Make the waveforms of the individual components
comps=[]; %matrix for component waveforms
for iComps=1:nTones;
    comp=MakeBeep(tones(iComps),durChord,sampRate);
    comps(iComps,:)=comp./nTones; %divide by number of tones to keep
    %amplitude between -1 and 1
end
%Add components
chord=sum(comps);

%Window with raised cosine
win=tukeywin(size(chord,2),beta)';
winChord=chord.*win;

%Stereo output
chordStereo=[winChord;winChord];