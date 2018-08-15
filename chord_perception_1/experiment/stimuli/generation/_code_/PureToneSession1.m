%Script for running the first session of experiment, some variables need to
%be saved to make sure that correct stimuli are used in the second session

%Clear workspace
close all;
clearvars;
sca; %shorthand for executing Screen('CloseAll')

%% -----------------------------------------------------------------------
%                   Load variables
%-------------------------------------------------------------------------
%Load file with stimulus order
load('newChordOrder.mat');

%Load structure with stimulus pitches
load('newStimuli.mat');
stimuli=newStimuli;

%Load file with practice stimuli
load('newPracticeStimuli.mat');

%Load file with practice stimulus order
load('newPracticeChordOrder.mat');

%% -----------------------------------------------------------------------
%                   Variables to define
%-------------------------------------------------------------------------
%Subject variables - Change every time!
%=========================================================================
nSubj=56;
nSess=1;
%=========================================================================
subjID=['PureT_subj' num2str(nSubj) '_sess' num2str(nSess)];

%Experiment variables
%Number of trials, sets (5*40 trials) and blocks
nTotalTrials=size(newChordOrder,1); %number of all trials
nTrials=4;
nSets=1;
nBlocks=1;
%Other useful variables for defining stimuli
nSetTrials=nTrials*nSets;

%Structure for containing all experimental data from one session: subjID,
%randomisation seed, responses)
experiment.subj=subjID;
experiment.responses=NaN(nTotalTrials,3); %column 1 for response (Y=1/N=0),
%column 2 for accuracy (correct=1, incorrect=0), column 3 for RT in ms

%Timing variables (in seconds)
%Duration of noise
durNoise=0.25;
%Interval between noise and chord
intNoiseChord=0.15;
%Duration of chord
durChord=0.5;
%Interval between chord and probe
intChordProbe=0.15;
%Duration of probe
durProbe=0.5;
%Duration of feedback
durFeedback=0.25;

%Stimulus variables
%Number of tones in the chord
nTones=5;
%Number of repetitions of each sound (want each sound to be played once)
repetitions=1;
%Window steepness for pure tones
beta=0.75;

%% -----------------------------------------------------------------------
%                   Stimulus randomisation
%-------------------------------------------------------------------------
%Set the random number generator to default values
rng(nSubj,'twister');

%Create a random permutation of the rows in newChordOrder
order=randperm(size(newChordOrder,1))';
%Reorder the rows in newChordOrder according to the permutation
stimOrder=newChordOrder(order,:);

%Save randomisation seed and stimulus order
experiment.seed=rng;
experiment.order=stimOrder;

%% -----------------------------------------------------------------------
%                   Practice trials
%-------------------------------------------------------------------------
%Use different chords in the practice set from the practiceStimuli file
%Reset the random number generator
rng(nSubj,'twister');

%Create a random permutaiton of the rows in practiceChordOrder
practiceOrder=randperm(size(practiceChordOrder,1))';
%Reorder the rows in practiceChordOrder according to the permutation
practiceStimOrder=practiceChordOrder(practiceOrder,:);

%Save practice stimulus order and seed
experiment.practiceOrder=practiceStimOrder;
experiment.practiceSeed=rng;
%Save practice responses
experiment.practiceResponses=NaN(nTrials,3);

%% -----------------------------------------------------------------------
%                   PsychToolbox setup
%-------------------------------------------------------------------------
%Select default PsychToolbox settings, 2 is the highest feature level
PsychDefaultSetup(2);

%Define response keys
yesResponse = KbName('J');
noResponse = KbName('F');

%AUDIO
%Intitialise sound driver, 1 enables high latencies
InitializePsychSound(1);

%Add 15 msecs latency on Windows, to protect against shoddy drivers
%(suggested latency)
sugLat=[];
if IsWin
    sugLat=0.015;
end

%Set sampling frequency in Hz
sampRate=44100;

%Set number of channels (2 for stereo playback)
nChan=2;

%Create a Psych-Audio port (audio device), with the follow arguements
%(1) [] = number of sound device ([]=default)
%(2) 1 = sound playback only
%(3) 1 = requested latency class (how aggressively latency is prioritised)
%(4) Requested frequency in samples per second
%(5) 2 = stereo putput
%(6) []= buffersize ([]=default)
%(7) Suggested latency
pahandle=PsychPortAudio('Open',4,1,1,sampRate,nChan,[],sugLat);

%Set start cue for when the device should start (0=immediately)
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
black = BlackIndex(screenNumber);
grey = white/2;
red = [0.5 0 0];
green = [0 0.5 0];

%Open screen with grey as the background colour (last argument creates a
%small screen for testing purposes)
testScreen=[0 0 1000 750];
%testScreen=[]
[window,windowRect]=PsychImaging('OpenWindow',screenNumber,grey,testScreen);

%Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%Set text parameters (text too big for small window)
Screen('TextSize',window,30);
Screen('TextFont',window,'Calibri');



%% -----------------------------------------------------------------------
%                   Begin experiment
%-------------------------------------------------------------------------

% Draw text in the center  of the screen
line1='In every trial, you will hear a chord followed by a single tone.';
line2='\n\n Press J if the second tone was present in the chord ("YES").';
line3='\n\n Press F if the second tone was not present in the chord ("NO").';
line4='\n\n\n Please press any button to begin the practice trials.';
DrawFormattedText(window,[line1 line2 line3 line4],...
    'center', 'center', white);
% Flip to the screen (the text only shows up when you do this)
Screen('Flip', window);
%Wait for a key press
KbStrokeWait;
% Wait 100 ms before moving on to the next screen
WaitSecs(0.1);
% 
% 
% Practice trials
%Change display to grey
Screen('FillRect',window,grey);
Screen('Flip',window);

%Create white noise stimulus and load into buffer
noiseStereo=createNoise(durNoise,sampRate,beta);
paNoise=PsychPortAudio('CreateBuffer',[],noiseStereo);

%Play white noise (lower volume than the practiceStimuli)
PsychPortAudio('Volume',pahandle,0.2);
PsychPortAudio('FillBuffer',pahandle,paNoise);
PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);

for iTrial=1:nTrials
    %Change display to grey
    Screen('FillRect',window,grey);
    Screen('Flip',window);
    
    %Define stimulus for the trial
    shape=practiceStimOrder(iTrial,2); %number of stimulus shape
    startPitch=practiceStimOrder(iTrial,3); %number of starting pitch
    nProbe=practiceStimOrder(iTrial,6); %number of probe (1-6(D) or 1-3(C))
    
    %Access tone names and convert into frequencies
    tones=NaN(1,nTones); %vector for storing tone frequencies
    for iTones=1:nTones;
        tones(1,iTones)=toneName(practiceStimuli{startPitch,shape}.tones(iTones));
    end;
    
    %Create chord and load into buffer
    chordStereo=createChord(tones,nTones,durChord,sampRate,beta);
    paChord=PsychPortAudio('CreateBuffer',[],chordStereo);
    
    %Figure out what probe to use
    if practiceStimOrder(iTrial,4)==1 %if probe is correct
        probename=practiceStimuli{startPitch,shape}.tones(nProbe);%correct probes are contained in the 'tones'
    elseif practiceStimOrder(iTrial,1)==1 %if chord is consonant
        if practiceStimOrder(iTrial,5)==1 %if probe is consonant
            probename=practiceStimuli{startPitch,shape}.consProbes(nProbe);%consonant probes are contained in 'consProbes'
        else %if probe is dissonant
            probename=practiceStimuli{startPitch,shape}.dissProbes(nProbe);%dissonant probes are contained in 'dissProbes'
        end
    else %if chord is dissonant, then all probes are dissonant
        probename=practiceStimuli{startPitch,shape}.dissProbes(nProbe);
    end
    
    %Create probe and load into buffer
    probeFreq=toneName(probename);
    probeStereo=createProbe(probeFreq,nTones,durProbe,sampRate,beta);
    paProbe=PsychPortAudio('CreateBuffer',[],probeStereo);
    
    %Start audio playback
    
    %Interval
    WaitSecs(durNoise+intNoiseChord);
    %Chord
    PsychPortAudio('Volume',pahandle,1);
    PsychPortAudio('FillBuffer',pahandle,paChord);
    PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
    %Interval
    WaitSecs(durChord+intChordProbe);
    %Probe
    PsychPortAudio('FillBuffer',pahandle,paProbe);
    PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
    
    %Collect practice responses
    
    %Get time of probe playback
    probeStart=GetSecs;
    
    %Check whether response has been made in time period from probe onset
    %until the end of the response period. Record the practiceResponses,
    %reaction times and response accuracies
    while GetSecs > probeStart
        [keyIsDown,secs,keyCode]=KbCheck();
        if keyIsDown==1 && find(keyCode,1)==yesResponse;
            experiment.practiceResponses(iTrial,1)=1;
            experiment.practiceResponses(iTrial,3)=secs-probeStart;
            if practiceStimOrder(iTrial,4)==1 %yes is the correct response
                experiment.practiceResponses(iTrial,2)=1;
            else
                experiment.practiceResponses(iTrial,2)=0;
            end
            break
        elseif keyIsDown==1 && find(keyCode,1)==noResponse;
            experiment.practiceResponses(iTrial,1)=0;
            experiment.practiceResponses(iTrial,3)=secs-probeStart;
            if practiceStimOrder(iTrial,4)==0 %no is the correct response
                experiment.practiceResponses(iTrial,2)=1;
            else
                experiment.practiceResponses(iTrial,2)=0;
            end
            break
        end
    end
    
    %Give feedback (overlapping with white noise)
    if experiment.practiceResponses(iTrial,2)==1 %correct response
        noiseStereo=createNoise(durNoise,sampRate,beta);
        paNoise=PsychPortAudio('CreateBuffer',[],noiseStereo);
        PsychPortAudio('Volume',pahandle,0.2);
        PsychPortAudio('FillBuffer',pahandle,paNoise);
        PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
        Screen('FillRect',window,green);
        Screen('Flip',window);
        WaitSecs(durFeedback);
    else %incorrect response
        noiseStereo=createNoise(durNoise,sampRate,beta);
        paNoise=PsychPortAudio('CreateBuffer',[],noiseStereo);
        PsychPortAudio('Volume',pahandle,0.2);
        PsychPortAudio('FillBuffer',pahandle,paNoise);
        PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
        Screen('FillRect',window,red);
        Screen('Flip',window);
        WaitSecs(durFeedback);
    end
end

%% =======================================================================
%Real experiment

%Change display to grey
Screen('FillRect',window,grey);
Screen('Flip',window);
% Draw text in the center  of the screen
line1='You have now finished the practice.';
line2='\n\n\n Please press any button to begin the experiment.';
DrawFormattedText(window,[line1 line2],...
    'center', 'center', white);
% Flip to the screen (the text only shows up when you do this)
Screen('Flip', window);
%Wait for a key press
KbStrokeWait;
% Wait 100 ms before moving on to the next screen
WaitSecs(0.1);

for iBlock=1:nBlocks
    for iSet=1:nSets
        %Change display to grey
        Screen('FillRect',window,grey);
        Screen('Flip',window);
        
        %Create white noise stimulus and load into buffer
        noiseStereo=createNoise(durNoise,sampRate,beta);
        paNoise=PsychPortAudio('CreateBuffer',[],noiseStereo);
        
        %Play white noise (lower volume than the stimuli)
        PsychPortAudio('Volume',pahandle,0.2);
        PsychPortAudio('FillBuffer',pahandle,paNoise);
        PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
        
        for iTrial=1:nTrials
            %Change display to grey
            Screen('FillRect',window,grey);
            Screen('Flip',window);
            
            %Define stimulus for the trial
            trialNum=((iBlock-1)*(nSetTrials))+((iSet-1)*nTrials)+iTrial; %number of trial in the total stimulus set
            shape=stimOrder(trialNum,2); %number of stimulus shape (1-10)
            startPitch=stimOrder(trialNum,3); %number of starting pitch (1-5)
            nProbe=stimOrder(trialNum,6); %number of probe (1-6(D) or 1-3(C))
            
            %Access tone names and convert into frequencies
            tones=NaN(1,nTones); %vector for storing tone frequencies
            for iTones=1:nTones;
                tones(1,iTones)=toneName(stimuli{startPitch,shape}.tones(iTones));
            end;
            
            %Create chord and load into buffer
            chordStereo=createChord(tones,nTones,durChord,sampRate,beta);
            paChord=PsychPortAudio('CreateBuffer',[],chordStereo);
            
            %Figure out what probe to use
            if stimOrder(trialNum,4)==1 %if probe is correct
                probename=stimuli{startPitch,shape}.tones(nProbe);%correct probes are contained in the 'tones'
            elseif stimOrder(trialNum,1)==1 %if chord is consonant
                if stimOrder(trialNum,5)==1 %if probe is consonant
                    probename=stimuli{startPitch,shape}.consProbes(nProbe);%consonant probes are contained in 'consProbes'
                else %if probe is dissonant
                    probename=stimuli{startPitch,shape}.dissProbes(nProbe);%dissonant probes are contained in 'dissProbes'
                end
            else %if chord is dissonant, then all probes are dissonant
                probename=stimuli{startPitch,shape}.dissProbes(nProbe);
            end
            
            %Create probe and load into buffer
            probeFreq=toneName(probename);
            probeStereo=createProbe(probeFreq,nTones,durProbe,sampRate,beta);
            paProbe=PsychPortAudio('CreateBuffer',[],probeStereo);

            %Start audio playback
            
            %Interval
            WaitSecs(durNoise+intNoiseChord);
            %Chord
            PsychPortAudio('Volume',pahandle,1);
            PsychPortAudio('FillBuffer',pahandle,paChord);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            %Interval
            WaitSecs(durChord+intChordProbe);
            %Probe
            PsychPortAudio('FillBuffer',pahandle,paProbe);
            PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
            
            %Collect responses
            
            %Get time of probe playback
            probeStart=GetSecs;
            
            %Check whether response has been made in time period from probe onset
            %until the end of the response period. Record the responses,
            %reaction times and response accuracies
            while GetSecs > probeStart
                [keyIsDown,secs,keyCode]=KbCheck();
                if keyIsDown==1 && find(keyCode,1)==yesResponse;
                    experiment.responses(trialNum,1)=1;
                    experiment.responses(trialNum,3)=secs-probeStart;
                    if stimOrder(trialNum,4)==1 %yes is the correct response
                        experiment.responses(trialNum,2)=1;
                    else
                        experiment.responses(trialNum,2)=0;
                    end
                    break
                elseif keyIsDown==1 && find(keyCode,1)==noResponse;
                    experiment.responses(trialNum,1)=0;
                    experiment.responses(trialNum,3)=secs-probeStart;
                    if stimOrder(trialNum,4)==0 %no is the correct response
                        experiment.responses(trialNum,2)=1;
                    else
                        experiment.responses(trialNum,2)=0;
                    end
                    break
                end
            end
            
            %Give feedback (overlapping with white noise)
            if experiment.responses(trialNum,2)==1 %correct response
                noiseStereo=createNoise(durNoise,sampRate,beta);
                paNoise=PsychPortAudio('CreateBuffer',[],noiseStereo);
                PsychPortAudio('Volume',pahandle,0.2);
                PsychPortAudio('FillBuffer',pahandle,paNoise);
                PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
                Screen('FillRect',window,green);
                Screen('Flip',window);
                WaitSecs(durFeedback);
            else %incorrect response
                noiseStereo=createNoise(durNoise,sampRate,beta);
                paNoise=PsychPortAudio('CreateBuffer',[],noiseStereo);
                PsychPortAudio('Volume',pahandle,0.2);
                PsychPortAudio('FillBuffer',pahandle,paNoise);
                PsychPortAudio('Start',pahandle,repetitions,startCue,waitForDeviceStart);
                Screen('FillRect',window,red);
                Screen('Flip',window);
                WaitSecs(durFeedback);
            end
        end
        
        %Change display to grey
        Screen('FillRect',window,grey);
        Screen('Flip',window);
        %Give feedback about the results of the set
        percCorr=(sum(experiment.responses((trialNum-(nTrials-1):(trialNum)),2)))/nTrials*100;
        trialCount=iSet*nTrials;
        line1=['You have finished ' num2str(trialCount) '/' num2str(nSetTrials) ' trials in this block.'];
        line2=['\n\n\n You answered ' num2str(percCorr) '% of the previous 40 trials correctly.'];
        line3='\n\n\n When you are ready, press any key to continue.';
        DrawFormattedText(window, [line1 line2 line3] ,...
            'center', 'center', white);
        Screen('Flip', window);
        KbStrokeWait
    end
    
    %Change display to grey
    Screen('FillRect',window,grey);
    Screen('Flip',window);
    %give feedback about results of the block
    percCorr=(sum(experiment.responses((trialNum-(nSetTrials-1):(trialNum)),2)))/nSetTrials*100;
    line1=['You have now finished block ' num2str(iBlock) ' out of ' num2str(nBlocks)];
    line2=['\n\n\n You answered ' num2str(percCorr) '% of the trials in this block correctly.'];
    line3='\n\n\n Take a break. When you are ready, press any key to continue.';
    DrawFormattedText(window, [line1 line2 line3] ,...
        'center', 'center', white);
    Screen('Flip', window);
    KbStrokeWait
end

% Stop playback
PsychPortAudio('Stop', pahandle);

% Close the audio device
PsychPortAudio('Close', pahandle);

% End of experiment
DrawFormattedText(window, 'Experiment finished.\n\n\nPress any key to exit.',...
    'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;

%Save responses and other info into file
save([subjID '.mat'],'experiment');

% Clear the screen
sca;

