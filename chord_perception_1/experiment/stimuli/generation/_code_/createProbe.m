function [probeStereo]=createProbe(probeFreq,nTones,durProbe,sampRate,beta,weighting,probeName)
%creates stereo probe with a Tukey window, given input frequency, duration,
%sampling rate and beta for the window, amplitude is divided by number of
%tones in the chord to ensure equal amplitude of individual components
%INPUTS:
%   probeFreq = frequency of probe in Hz
%   nTones = number of tones in the chord
%   durProbe = duration of probe in seconds
%   sampRate = sampling rate
%   beta = steepness of Tukey window
%   weighting = cell containing note names, frequencies and their relative
%   amplitude weights
%   probeName = string of the probe note name


probe=MakeBeep(probeFreq,durProbe,sampRate)./(nTones*2);
idx=strcmp(probeName,weighting(:,1));
weight=weighting{idx,3};
weightedProbe=probe*weight;
win=tukeywin(size(weightedProbe,2),beta)';
winProbe=weightedProbe.*win;
probeStereo=[winProbe;winProbe];
