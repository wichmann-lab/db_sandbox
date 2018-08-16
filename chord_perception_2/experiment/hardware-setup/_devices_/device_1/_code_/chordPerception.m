function chordPerception(nSubj,nSess,soundType)

%Runs a yes-no chord component detection experiment. One chord is presented,
%followed by a single tone and the listener has to decide whether the tone
%had been present in the chord or not and indicate their response with a
%button press. The chords can be made of pure tones or piano tones, and
%they can be either consonant or dissonant. The tones vary in their
%position within the chord (5 possible positions), or for foil tones
%combined with consonant chords, the tone may be consonant with the chord
%or not. Direct feedback after every trial is only given in the practice
%rounds.
%   Input: 
%   nSubj = number of subject
%   nSess = number of session
%   soundType = string defining the sound type ('piano' or 'pure')      
%

%% Load variables
load('fixedStimuli.mat')
stimuli; %contains note names of all chords
load('weighting.mat');
weighting; %contains tone names (col 1), corresponding frequencies
%(col 2) and pure tone weighting coefficients (col 3)
load('practiceStimuli.mat')
practiceStimuli; %contains note names of practice chords

if nSess==1;
    load('practiceTrialOrder.mat')
    practiceTrialOrder; %contains an ordered list of practice trials
    load('fixedTrialOrder.mat')
    trialOrder; %contains an ordered list of all trials regarding stimulus
    %shape, starting note,
end

%% Define experimental variables
if nSess==2;
    subjID=['chordPerc_' soundType '_subj' num2str(nSubj) '_sess1'];
    load([subjID '.mat']) %load trial order files and previous responses
    trialOrder=experiment.trialOrder;
    practiceTrialOrder=experiment.practiceTrialOrder;
end

subjID=['chordPerc_' soundType '_subj' num2str(nSubj) '_sess' num2str(nSess)];
%for saving results

%Duration variables (in seconds)
durTone=0.5; %chord and tone presentation
durInterval=0.15; %interval between chord and tone, and noise and chord
durFeedback=0.25; %noise and visual feedback
responseWindow=1; %duration of the response window in seconds

%Stimulus variables
nTones=5; %number of chord components
repetitions=1; %number of times each stimulus should be repeated
beta1=0.75; %Tukey window steepness for pure tones and piano tone offset 
beta2=0.1; %Tukey window steepness for piano tone onset
sampRate=44100; %sampling rate
nChan=2; %number of audio channels (2 for stereo playback)
volumeNoise=0.1; %volume of white noise
volumePiano=0.47; %volume of piano tones
volumePure=1; %volume of pure tones

%Number of trials, sets and blocks
nSets=5;
%nPracticeTrials=5;
nTrials=40; %number of trials in a set

% nTrials=5;
nPracticeTrials=40; 
nSetTrials=nTrials*nSets;


if nSess==1;
    nBlocks=7; %number of blocks in first session
    nPracticeTrials=size(practiceTrialOrder,1);
else
    nBlocks=8; %number of blocks in second session
    nPracticeTrials=nTrials;
end
%nBlocks=1;


nTotalTrials=size(trialOrder,1); %number of trials in the entire experiment
ses1Trials=1400;

%% Randomise trial order
if nSess==1; %only do it in the first session
    if strcmp(soundType,'piano')==1
        rng(nSubj+1,'twister'); %set random number generator for piano tones
    else
        rng(nSubj+2,'twister'); %set random number generator for pure tones
    end
    order=randperm(size(trialOrder,1))'; %generate a random permutation of rows
    trialOrder=trialOrder(order,:); %reorder rows in trialOrder
    
    if strcmp(soundType,'piano')==1
        rng(nSubj+1,'twister'); %set random number generator for piano tones
    else
        rng(nSubj+2,'twister'); %set random number generator for pure tones
    end
    practiceOrder=randperm(size(practiceTrialOrder,1))'; %generate permutation
    practiceTrialOrder=practiceTrialOrder(practiceOrder,:); %reorder rows
end
%% Create structure for storing information about the experiment
if nSess==1;
    %Structure for containing all experimental data from the experiment
    experiment.subj=subjID;
    %Main experiment
    experiment.trialOrder=trialOrder; %order of trials
    experiment.order=order; %permutation vector
    responses=NaN(nTotalTrials,3); %col 1 for response (Y=1/N=0),
    %col 2 for accuracy (correct=1/incorrect=0), col 3 for RT in ms
    %Practice trials
    experiment.practiceTrialOrder=practiceTrialOrder; %order of practice trials
    experiment.practiceOrder=practiceOrder; %permutation vector
end

if nSess==2;
    responses=experiment.sess1.responses; %load previous response file
end

%Individually for each session
practiceResponses=NaN(nPracticeTrials,3); %col 1 for response
%(Y=1/N=0), col 2 for accuracy (correct=1/incorrect=0), col 3 for RT in s

%% Psychtoolbox set-up

%Select default PsychToolbox settings, 2 is the highest feature level
PsychDefaultSetup(2);

%Define response keys
yesResponse = KbName('J'); %probe tone was present in chord
noResponse = KbName('F'); %probe tone not present in chord

%AUDIO
%Intitialise sound driver, 1 enables high latencies
InitializePsychSound(1);

%Create a Psych-Audio port (audio device), with the follow arguements
pahandle=PsychPortAudio('Open',4,1,1,sampRate,nChan);

%Set start cue for when the device should start (0 means immediately)
startCue=0;

%Wait for the device to really start
waitForDeviceStart=1;

%VISUAL
%Get the number of monitors
screens = Screen ('Screens');

%Choose a monitor
screenNumber = max(screens);

%Define colours
white = WhiteIndex(screenNumber);
grey = white/2; %background colour
red = [0.5 0 0]; %feedback for incorrect practice trials
green = [0 0.5 0]; %feedback for correct practice trials

%Open screen with grey as the background colour
winSize=[0 0 1500 1000]; %for testing purposes
%winSize=[]
[window,windowRect]=PsychImaging('OpenWindow',screenNumber,grey,winSize);

%Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%Set text parameters
Screen('TextSize',window,30);
Screen('TextFont',window,'Calibri');

%% Create white noise and load into buffer
noiseStereo=createNoise(durFeedback,sampRate,beta1); %function for creating noise
paNoise=PsychPortAudio('CreateBuffer',[],noiseStereo); %load into buffer

%% Begin experiment
% Draw text in the center  of the screen
line1='In every trial, you will hear a chord followed by a single tone.';
line2='\n\n Press J if the second tone was present in the chord ("YES").';
line3='\n Press F if the second tone was not present in the chord ("NO").';
line4='\n\n Each trial is separated by white noise.';
line5=['\n\n In practice trials, you will see the screen change colour'...
    '\n depending on the accuracy of your response ' ...
    '(green - correct, red - false).'];    
line6='\n\n\n Please press any button to begin the practice trials.';
    
    DrawFormattedText(window,[line1 line2 line3 line4 line5 line6],...
    'center', 'center', white);
    % Flip to the screen
    Screen('Flip', window);
    %Wait for a key press
    KbStrokeWait;
    % Wait 100 ms before moving on to the next screen
    WaitSecs(0.1);
    
    
    %% Practice trials
    if nSess==1; %first session requires a long practice
    for iSet=1:nSets;
        Screen('FillRect',window,grey); %change display to grey
        Screen('Flip',window);
        for iTrial=1:nTrials;
            trialNum=((iSet-1)*nTrials)+iTrial; %trial number in practiceTrialOrder
            response=practiceTrial(trialNum,iTrial); %function for practice trial
            practiceResponses(trialNum,:)=response; %store response
        end
        Screen('FillRect',window,grey); %change display to grey
        Screen('Flip',window);
        
        %Give feedback
        corrCount=nansum(practiceResponses((trialNum -...
            (nTrials-1):(trialNum)),2)); %correct responses in the last set
        percCorr=((nansum(practiceResponses((1:trialNum),2)))...
            /(nTrials*iSet))*100; %percentage correct in whole practice round
        line1=['You have finished ' num2str(iSet*nTrials) ...
            ' out of ' num2str(nTrials*nSets) ' practice trials.'];
        line2=['\n\n\n You answered ' num2str(corrCount) ...
            ' of the previous ' num2str(nTrials) ' trials correctly.'];
        line3=['\n\n Overall ' num2str(percCorr) '% trials correct.'];
        line4='\n\n\n When you are ready, press any key to continue.';
        DrawFormattedText(window, [line1 line2 line3 line4] ,...
            'center','center',white); %display feedback
        Screen('Flip', window);
        KbStrokeWait
    end
    line1= 'You have now finished the practice trials.';
    line2= '\n\n\n Press any key to proceed to the main experiment.';
    DrawFormattedText(window,[line1 line2],'center','center',white);
    Screen('Flip', window);
    KbStrokeWait;
        
    elseif nSess==2; %second session only requires a short refresing
        for iTrial=1:nTrials;

            trialNum=iTrial; %trial number in practiceTrialOrder
            response=practiceTrial(trialNum,iTrial); %function for practice trial
            practiceResponses(trialNum,:)=response; %store response
        end
        Screen('FillRect',window,grey); %change display to grey
        Screen('Flip',window);
        %Give feedback and finish practice trials
        corrCount=nansum(practiceResponses(1:nTrials,2)); %correct responses
        percCorr=corrCount/nTrials*100; %percentage correct
        line1='You have finished the practice trials.';
        line2=['\n\n\n You answered ' num2str(corrCount) ...
            ' of the ' num2str(nTrials) ' trials correctly.'];
        line3=['\n\n Overall ' num2str(percCorr) '% trials correct.'];
        line4='\n\n\n  Press any key to proceed to the main experiment.';
        DrawFormattedText(window, [line1 line2 line3 line4] ,...
            'center','center',white); %display feedback and end of practice
        Screen('Flip', window);
        KbStrokeWait
    end
       
    %Change display to grey
    Screen('FillRect',window,grey);
    Screen('Flip',window);
    
    %% Main experiment
    
    % Draw text in the center  of the screen
    line1='You are now starting the main experiment.';
    line2='\n There will be no more feedback after every single trial';
    line3=['\n Remember, press J if the second tone was present in the chord ("YES")'...
        '\n and F if the second tone was not present in the chord ("NO").'];
    line4='\n\n\n Please press any button to begin the experiment.';
    DrawFormattedText(window,[line1 line2 line3 line4],...
        'center','center',white);
    Screen('Flip', window);
    %Wait for a key press
    KbStrokeWait;
    % Wait 100 ms before moving on to the next screen
    WaitSecs(0.1);
    
    for iBlock=1:nBlocks;
        for iSet=1:nSets;
            %Change display to grey
            Screen('FillRect',window,grey);
            Screen('Flip',window);
            for iTrial=1:nTrials;
                trialNum=((iBlock-1)*(nSetTrials))+((iSet-1)*nTrials)+iTrial;
                if nSess==2
                    trialNum=trialNum+ses1Trials;
                end
                %number of trial in the total stimulus set
                response=trial(trialNum, iTrial); %function for the trial
                responses(trialNum,:)=response; %store response
            end
            %Give feedback about the results of the set
            corrCount=nansum(responses((trialNum-(nTrials-1):(trialNum)),2)); %correct responses in the last set
            percCorr=((nansum(responses(((trialNum-(iSet*nTrials-1)):trialNum),2)))/...
                (nTrials*iSet))*100; %percent correct in this block
            line1=['You have finished ' num2str(iSet*nTrials) ' out of '...
                num2str(nTrials*nSets) ' trials in this block.'];
            line2=['\n\n\n You answered ' num2str(corrCount)...
                ' of the previous ' num2str(nTrials) ' trials correctly.'];
            line3=['\n\n' num2str(percCorr) '% trials correct in this block.'];
            line4='\n\n\n When you are ready, press any key to continue.';
            DrawFormattedText(window, [line1 line2 line3 line4] ,...
                'center','center',white);
            Screen('Flip', window);
            KbStrokeWait
        end
        line1=['You have reached the end of block ' num2str(iBlock) ' out of '...
            num2str(nBlocks) ' blocks.'];
        line2='\n\n\n Take a break. When you are ready, press any key to continue.';
        DrawFormattedText(window, [line1 line2],'center','center',white);
        Screen('Flip', window);
        KbStrokeWait
    end
    
    line1= 'You have now reached the end of the experiment.';
    line2= '\n\n\n Press any key to proceed to exit.';
    DrawFormattedText(window,[line1 line2],'center','center',white);
    Screen('Flip', window);
    KbStrokeWait;
    %Close the window
    sca;
    
    % Stop playback and close the audio device
    PsychPortAudio('Stop', pahandle);
    PsychPortAudio('Close', pahandle);
    
    %Save responses and all other experimental data into a file
    if nSess==1;
        experiment.sess1.responses=responses;
        experiment.sess1.practiceResponses=practiceResponses;
    else
        experiment.sess2.responses=responses;
        experiment.sess2.practiceResponses=practiceResponses;
    end
    
    save([subjID '.mat'], 'experiment');
    
    
    
    
    %% Function for running a practice trial
    function [response]=practiceTrial(trialNum,iTrial)
        %Runs a practice trial in the chord perception experiment

        
        %Define stimulus features
        shape=practiceTrialOrder(trialNum,2); %number of stimulus shape (1-10)
        start=practiceTrialOrder(trialNum,3); %number of starting pitch (1-5)
        nProbe=practiceTrialOrder(trialNum,6); %number of probe (1-6(D) or 1-3(C))
        response=NaN(1,3); %store response of current trial
        divisor=8; %dividing the standard amplitude (1) of one component with this
        
        %% Piano session
        if strcmp(soundType,'piano')==1 %piano session
            
            %Create chord and load into buffer
            components=NaN(nTones,sampRate*durTone); %cell array for sound waves of
            %all components
            for i=1:nTones;
                note=practiceStimuli{start,shape}.tones{1,i};
                filename=[note '.wav'];
                y=audioread(['/home/johanna/Piano stimuli/', filename]);
                soundwave=mean((y(1:(sampRate*durTone),:)),2)'./divisor;
                components(i,:)=soundwave;
            end
            chord=sum(components,1); %add the components together to create a chord
            %window the chord with an asymmetric window
            win1=tukeywin(size(chord,2),beta2)'; %window with steep slope
            win2=tukeywin(size(chord,2),beta1)'; %window with gentle slope
            %combine the first half of win1 and second half of win
            win(1,1:(size(chord,2)/2))=win1(1,1:(size(chord,2)/2));
            win(1,(size(chord,2)/2+1):size(chord,2))=win2(1,(size(chord,2)/2+1):end);
            winChord=chord.*win; %windowed chord
            %create two channels and load into audio buffer
            chordStereo=[winChord;winChord];
            paChord=PsychPortAudio('CreateBuffer',[],chordStereo);
            
            %Create probe and load into buffer
            %Figure out what probe to use
            if practiceTrialOrder(trialNum,4)==1 %if probe is correct
                probeName=practiceStimuli{start,shape}.tones(nProbe);%correct probes are contained in the 'tones'
            elseif practiceTrialOrder(trialNum,1)==1 %if chord is consonant
                if practiceTrialOrder(trialNum,5)==1 %if probe is consonant
                    probeName=practiceStimuli{start,shape}.consProbes(nProbe);%consonant probes are contained in 'consProbes'
                else %if probe is dissonant
                    probeName=practiceStimuli{start,shape}.dissProbes(nProbe);%dissonant probes are contained in 'dissProbes'
                end
            else %if chord is dissonant, then all probes are dissonant
                probeName=practiceStimuli{start,shape}.dissProbes(nProbe);
            end
            
            probeFilename=[probeName{1,1}, '.wav']; %name of the probe file
            y=audioread(['/home/johanna/Piano stimuli/',probeFilename]); %load audiofile
            probe=mean((y(1:(sampRate*durTone),:)),2)'./divisor; %shorten and reduce amplitude of the probe
            winProbe=probe.*win; %window the probe
            %create two channels and load into audio buffer
            probeStereo=[winProbe;winProbe];
            paProbe=PsychPortAudio('CreateBuffer',[],probeStereo);
            
            %Playback
            if iTrial==1;
                PsychPortAudio('Volume',pahandle,volumeNoise); %set noise volume
                PsychPortAudio('FillBuffer',pahandle,paNoise); %fill buffer
                PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart); %play
            end
            
            %Interval
            WaitSecs(durFeedback+durInterval); %wait for the noise and a small break
            Screen('FillRect',window,grey); %change display to grey
            Screen('Flip',window);
            
            %Chord
            PsychPortAudio('Volume',pahandle,volumePiano); %set piano volume
            PsychPortAudio('FillBuffer',pahandle,paChord);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            %Interval
            WaitSecs(durTone+durInterval); %wait for the chord and a small break
            %Probe
            PsychPortAudio('FillBuffer',pahandle,paProbe);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            
            %Collect responses
            probeStart=GetSecs; %get time of probe playback
            %Check whether response has been made in time period from probe onset
            %until the end of the response period. Record responses.
            while GetSecs > probeStart && GetSecs < probeStart+responseWindow
                [keyIsDown,secs,keyCode]=KbCheck();
                if keyIsDown==1 && find(keyCode,1)==yesResponse;
                    response(1,1)=1; %response
                    response(1,3)=secs-probeStart; %RT
                    if practiceTrialOrder(trialNum,4)==1 %yes is the correct response
                        response(1,2)=1; %accurate
                    else
                        response(1,2)=0; %inaccurate
                    end
                    break
                elseif keyIsDown==1 && find(keyCode,1)==noResponse;
                    response(1,1)=0; %response
                    response(1,3)=secs-probeStart; %RT
                    if practiceTrialOrder(trialNum,4)==0 %no is the correct response
                        response(1,2)=1; %accurate
                    else
                        response(1,2)=0; %inaccurate
                    end
                    break
                end
            end
            
%             %If response faster than response window, add time
%             if GetSecs < probeStart+responseWindow
%                WaitSecs((probeStart+responseWindow)-GetSecs);
%             end
            
            %Give feedback (overlapping with white noise)
            PsychPortAudio('Volume',pahandle,volumeNoise);
            PsychPortAudio('FillBuffer',pahandle,paNoise);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            if response(1,2)==1 %correct response
                Screen('FillRect',window,green);
                Screen('Flip',window);
            else %incorrect response
                Screen('FillRect',window,red);
                Screen('Flip',window);
            end
            
            %% Pure tone session
        elseif strcmp(soundType,'pure')==1 %pure tone session
            
            %Create chord and load into buffer
            weightedWaves=NaN(nTones,sampRate*durTone); %cell array for all the
            %weighted components of the chord
            for i=1:nTones;
                note=practiceStimuli{start,shape}.tones{1,i};
                freq=toneName(note);
                sineWave=MakeBeep(freq,durTone,sampRate)./(nTones*2);
                idx=strcmp(note,weighting(:,1));
                weight=weighting{idx,3};
                weightedWave=sineWave*weight;
                weightedWaves(i,:)=weightedWave(1,1:size(weightedWaves,2));
            end
            
            %add the components together to create a chord
            chord=sum(weightedWaves,1);
            
            %window the chord with a symmetric tukey window
            win=tukeywin(size(chord,2),beta1)'; %window with gentle slope
            winChord=chord.*win; %windowed chord
            
            %create two channels and load into audio buffer
            chordStereo=[winChord;winChord];
            paChord=PsychPortAudio('CreateBuffer',[],chordStereo);
            
            %Create probe and load into buffer
            %Figure out what probe to use
            if practiceTrialOrder(trialNum,4)==1 %if probe is correct
                probeName=practiceStimuli{start,shape}.tones(nProbe);%correct probes are contained in the 'tones'
            elseif practiceTrialOrder(trialNum,1)==1 %if chord is consonant
                if practiceTrialOrder(trialNum,5)==1 %if probe is consonant
                    probeName=practiceStimuli{start,shape}.consProbes(nProbe);%consonant probes are contained in 'consProbes'
                else %if probe is dissonant
                    probeName=practiceStimuli{start,shape}.dissProbes(nProbe);%dissonant probes are contained in 'dissProbes'
                end
            else %if chord is dissonant, then all probes are dissonant
                probeName=practiceStimuli{start,shape}.dissProbes(nProbe);
            end
            
            probeFreq=toneName(probeName); %frequency of probe
            probeStereo=createProbe(probeFreq,nTones,durTone,sampRate,beta1,weighting,probeName); %function for creating probe
            paProbe=PsychPortAudio('CreateBuffer',[],probeStereo);
            
            %Playback
            if iTrial==1;
                PsychPortAudio('Volume',pahandle,volumeNoise); %set noise volume
                PsychPortAudio('FillBuffer',pahandle,paNoise); %fill buffer
                PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart); %play
            end
            
            %Interval
            WaitSecs(durFeedback+durInterval); %wait for the noise and a small break
            Screen('FillRect',window,grey); %change display to grey
            Screen('Flip',window); 
            
            %Chord
            PsychPortAudio('Volume',pahandle,volumePure); %set piano volume
            PsychPortAudio('FillBuffer',pahandle,paChord);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            %Interval
            WaitSecs(durTone+durInterval); %wait for the chord and a small break
            %Probe
            PsychPortAudio('FillBuffer',pahandle,paProbe);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            
            %Collect responses
            probeStart=GetSecs; %get time of probe playback
            %Check whether response has been made in time period from probe onset
            %until the end of the response period. Record responses.
            while GetSecs > probeStart && GetSecs < probeStart+responseWindow
                [keyIsDown,secs,keyCode]=KbCheck();
                if keyIsDown==1 && find(keyCode,1)==yesResponse;
                    response(1,1)=1; %response
                    response(1,3)=secs-probeStart; %RT
                    if practiceTrialOrder(trialNum,4)==1 %yes is the correct response
                        response(1,2)=1; %accurate
                    else
                        response(1,2)=0; %inaccurate
                    end
                    break
                elseif keyIsDown==1 && find(keyCode,1)==noResponse;
                    response(1,1)=0; %response
                    response(1,3)=secs-probeStart; %RT
                    if practiceTrialOrder(trialNum,4)==0 %no is the correct response
                        response(1,2)=1; %accurate
                    else
                        response(1,2)=0; %inaccurate
                    end
                    break
                end
            end
            
%             %If response faster than response window, add time
%             if GetSecs < probeStart+responseWindow
%                 WaitSecs((probeStart+responseWindow)-GetSecs);
%             end
                        
            %Give feedback (overlapping with white noise)
            PsychPortAudio('Volume',pahandle,volumeNoise);
            PsychPortAudio('FillBuffer',pahandle,paNoise);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            if response(1,2)==1 %correct response
                Screen('FillRect',window,green);
                Screen('Flip',window);
            else %incorrect response
                Screen('FillRect',window,red);
                Screen('Flip',window);
            end
        end
        
    end





%% Function for running a trial of the main experiment
    function [response]=trial(trialNum,iTrial)
        %Define stimulus features
        shape=trialOrder(trialNum,2); %number of stimulus shape (1-10)
        start=trialOrder(trialNum,3); %number of starting pitch (1-5)
        nProbe=trialOrder(trialNum,6); %number of probe (1-6(D) or 1-3(C))
        response=NaN(1,3); %store response ofcurrent trial
        divisor=8; %dividing the standard amplitude (1) of one component with this
                
        
        %% Piano session
        if strcmp(soundType,'piano')==1 %piano session
            
            %Create chord and load into buffer
            components=NaN(nTones,sampRate*durTone); %cell array for sound waves of
            %all components
            for i=1:nTones;
                note=stimuli{start,shape}.tones{1,i};
                filename=[note '.wav'];
                y=audioread(['/home/johanna/Piano stimuli/', filename]);
                soundwave=mean((y(1:(sampRate*durTone),:)),2)'./divisor;
                components(i,:)=soundwave;
            end
            chord=sum(components,1); %add the components together to create a chord
            %window the chord with an asymmetric window
            win1=tukeywin(size(chord,2),beta2)'; %window with steep slope
            win2=tukeywin(size(chord,2),beta1)'; %window with gentle slope
            %combine the first half of win1 and second half of win
            win(1,1:(size(chord,2)/2))=win1(1,1:(size(chord,2)/2));
            win(1,(size(chord,2)/2+1):size(chord,2))=win2(1,(size(chord,2)/2+1):end);
            winChord=chord.*win; %windowed chord
            %create two channels and load into audio buffer
            chordStereo=[winChord;winChord];
            paChord=PsychPortAudio('CreateBuffer',[],chordStereo);
            
            %Create probe and load into buffer
            %Figure out what probe to use
            if trialOrder(trialNum,4)==1 %if probe is correct
                probeName=stimuli{start,shape}.tones(nProbe);%correct probes are contained in the 'tones'
            elseif trialOrder(trialNum,1)==1 %if chord is consonant
                if trialOrder(trialNum,5)==1 %if probe is consonant
                    probeName=stimuli{start,shape}.consProbes(nProbe);%consonant probes are contained in 'consProbes'
                else %if probe is dissonant
                    probeName=stimuli{start,shape}.dissProbes(nProbe);%dissonant probes are contained in 'dissProbes'
                end
            else %if chord is dissonant, then all probes are dissonant
                probeName=stimuli{start,shape}.dissProbes(nProbe);
            end
            
            probeFilename=[probeName{1,1}, '.wav']; %name of the probe file
            y=audioread(['/home/johanna/Piano stimuli/',probeFilename]); %load audio file
            probe=mean((y(1:(sampRate*durTone),:)),2)'./divisor; %shorten and reduce amplitude of the probe
            winProbe=probe.*win; %window the probe
            %create two channels and load into audio buffer
            probeStereo=[winProbe;winProbe];
            paProbe=PsychPortAudio('CreateBuffer',[],probeStereo);
            
            %Playback
            if iTrial==1;
                PsychPortAudio('Volume',pahandle,volumeNoise); %set noise volume
                PsychPortAudio('FillBuffer',pahandle,paNoise); %fill buffer
                PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart); %play
            end
            
            %Interval
            WaitSecs(durFeedback+durInterval); %wait for the noise and a small break
            %Chord
            PsychPortAudio('Volume',pahandle,volumePiano); %set piano volume
            PsychPortAudio('FillBuffer',pahandle,paChord);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            %Interval
            WaitSecs(durTone+durInterval); %wait for the chord and a small break
            %Probe
            PsychPortAudio('FillBuffer',pahandle,paProbe);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            
            %Collect responses
            probeStart=GetSecs; %get time of probe playback
            %Check whether response has been made in time period from probe onset
            %until the end of the response period. Record responses.
            while GetSecs > probeStart && GetSecs < probeStart+responseWindow
                [keyIsDown,secs,keyCode]=KbCheck();
                if keyIsDown==1 && find(keyCode,1)==yesResponse;
                    response(1,1)=1; %response
                    response(1,3)=secs-probeStart; %RT
                    if trialOrder(trialNum,4)==1 %yes is the correct response
                        response(1,2)=1; %accurate
                    else
                        response(1,2)=0; %inaccurate
                    end
                    break
                elseif keyIsDown==1 && find(keyCode,1)==noResponse;
                    response(1,1)=0; %response
                    response(1,3)=secs-probeStart; %RT
                    if trialOrder(trialNum,4)==0 %no is the correct response
                        response(1,2)=1; %accurate
                    else
                        response(1,2)=0; %inaccurate
                    end
                    break
                end
            end
            
%             %If response faster than response window, add time
%             if GetSecs < probeStart+responseWindow
%                 WaitSecs((probeStart+responseWindow)-GetSecs);
%             end
                   
            
            %Present white noise to signal end of trial
            PsychPortAudio('Volume',pahandle,volumeNoise);
            PsychPortAudio('FillBuffer',pahandle,paNoise);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            
            
            %% Pure tone session
        elseif strcmp(soundType,'pure')==1 %pure tone session
            
            %Create chord and load into buffer
            weightedWaves=NaN(nTones,sampRate*durTone); %cell array for all the
            %weighted components of the chord
            for i=1:nTones;
                note=stimuli{start,shape}.tones{1,i};
                freq=toneName(note);
                sineWave=MakeBeep(freq,durTone,sampRate)./(nTones*2);
                idx=strcmp(note,weighting(:,1));
                weight=weighting{idx,3};
                weightedWave=sineWave*weight;
                weightedWaves(i,:)=weightedWave(1,1:size(weightedWaves,2));
            end
            
            %add the components together to create a chord
            chord=sum(weightedWaves,1);
            
            %window the chord with a symmetric tukey window
            win=tukeywin(size(chord,2),beta1)'; %window with gentle slope
            winChord=chord.*win; %windowed chord
            
            %create two channels and load into audio buffer
            chordStereo=[winChord;winChord];
            paChord=PsychPortAudio('CreateBuffer',[],chordStereo);
            
            %Create probe and load into buffer
            %Figure out what probe to use
            if trialOrder(trialNum,4)==1 %if probe is correct
                probeName=stimuli{start,shape}.tones(nProbe);%correct probes are contained in the 'tones'
            elseif trialOrder(trialNum,1)==1 %if chord is consonant
                if trialOrder(trialNum,5)==1 %if probe is consonant
                    probeName=stimuli{start,shape}.consProbes(nProbe);%consonant probes are contained in 'consProbes'
                else %if probe is dissonant
                    probeName=stimuli{start,shape}.dissProbes(nProbe);%dissonant probes are contained in 'dissProbes'
                end
            else %if chord is dissonant, then all probes are dissonant
                probeName=stimuli{start,shape}.dissProbes(nProbe);
            end
                             
            probeFreq=toneName(probeName); %frequency of probe
            probeStereo=createProbe(probeFreq,nTones,durTone,sampRate,beta1,weighting,probeName); %function for creating probe
            paProbe=PsychPortAudio('CreateBuffer',[],probeStereo);
            
            %Playback
            if iTrial==1;
                PsychPortAudio('Volume',pahandle,volumeNoise); %set noise volume
                PsychPortAudio('FillBuffer',pahandle,paNoise); %fill buffer
                PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart); %play
            end
            
            %Interval
            WaitSecs(durFeedback+durInterval); %wait for the noise and a small break
            %Chord
            PsychPortAudio('Volume',pahandle,volumePure); %set piano volume
            PsychPortAudio('FillBuffer',pahandle,paChord);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            %Interval
            WaitSecs(durTone+durInterval); %wait for the chord and a small break
            %Probe
            PsychPortAudio('FillBuffer',pahandle,paProbe);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            
            %Collect responses
            probeStart=GetSecs; %get time of probe playback
            %Check whether response has been made in time period from probe onset
            %until the end of the response period. Record responses.
            while GetSecs > probeStart && GetSecs < probeStart+responseWindow
                [keyIsDown,secs,keyCode]=KbCheck();
                if keyIsDown==1 && find(keyCode,1)==yesResponse;
                    response(1,1)=1; %response
                    response(1,3)=secs-probeStart; %RT
                    if trialOrder(trialNum,4)==1 %yes is the correct response
                        response(1,2)=1; %accurate
                    else
                        response(1,2)=0; %inaccurate
                    end
                    break
                elseif keyIsDown==1 && find(keyCode,1)==noResponse;
                    response(1,1)=0; %response
                    response(1,3)=secs-probeStart; %RT
                    if trialOrder(trialNum,4)==0 %no is the correct response
                        response(1,2)=1; %accurate
                    else
                        response(1,2)=0; %inaccurate
                    end
                    break
                end
            end
            
%             %If response faster than response window, add time
%             if GetSecs < probeStart+responseWindow
%                 WaitSecs((probeStart+responseWindow)-GetSecs);
%             end
                   
            
            %Present white noise to signal end of trial
            PsychPortAudio('Volume',pahandle,volumeNoise);
            PsychPortAudio('FillBuffer',pahandle,paNoise);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            
        end
    end
end

