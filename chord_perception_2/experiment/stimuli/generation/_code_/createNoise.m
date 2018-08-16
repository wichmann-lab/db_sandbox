function [noiseStereo]=createNoise(durNoise,sampRate,beta)
%creates stereo Gaussian white noise ranging from -1 to 1, with a Tukey
%window, given a specific duration, sampling rate and beta for the window

gaussNoise=randn(1,(durNoise*sampRate));
noise=gaussNoise./3;
idx1=logical(noise(1,:)<-1);
idx2=logical(noise(1,:)>1);
noise(idx1)=-1;
noise(idx2)=1;

win=tukeywin(size(noise,2),beta)';
winNoise=noise.*win;

noiseStereo=[winNoise;winNoise]; %ensure stereo output