%% Begin
clear all;
close all;

rng('Shuffle')
breakout = false;

KbName('UnifyKeyNames');
escape = KbName('ESCAPE');

[keyboardIndices, productNames, allInfos] = GetKeyboardIndices();
kbPointer = keyboardIndices(end);

%% Start the experiment!
exp = input('Please enter the experiment code. ', 's');

%% Code is processed as follows:
%  First digit: 
%      single (0), unbiased ensemble (1), or biased ensemble (2)
%  Second digit:
%      Fives of trials in hex
%  Third digit: 
%      Trait - attractiveness (0), punctuality (1), afraid (2),
%      angry (3), disgusted (4), dominant (5), feminine (6), happy (7),
%      masculine (8), sad (9), surprised (a), threatening (b), trustworthy
%      (c), unusual (d), babyface (e), educated (f)
%  Fourth digit: 
%      if single, 0 (can be used for testing purposes)
%      if ensemble, time per image/set in tens of ms
%  Fifth digit:
%      if single, 0 (can be used for testing purposes)
%      if ensemble, then first race && gender - Asian m (0), Black m (1), Latino m
%      (2), White m (3) - female is male + 4
%  Sixth digit:
%      if single, 0 (can be used for testing purposes)
%      if ensemble, then second race && gender - Asian m (0), Black m (1), Latino m
%      (2), White m (3) - female is male + 4
%% Setup

name = input('Please enter your name. ', 's');
age = input('Please enter your age. ', 's');
hand = input('Please enter your handedness - L for left-handed, R for right-handed. ', 's');

Screen('Preference', 'SkipSyncTests', 1);

[window, rect] = Screen('OpenWindow', 0, []);
[xCenter, yCenter] = RectCenter(rect); % Get the center of the window

window_w = rect(3); % defining size of screen
window_h = rect(4);

xStart = xCenter/2;
xEnd = xCenter * 1.5;
yStart = yCenter/2;
yEnd = yCenter * 1.5;

nRows = 3;
nCols = 2;
xvector = linspace(xStart, xEnd, nRows);
yvector = linspace(yStart, yEnd, nCols);

[x,y] = meshgrid(xvector, yvector);

img_ratio = 0.2095; % 512/2444

w_img = 2444*img_ratio;
h_img = 1718*img_ratio;

xy_rect = [x(:)'-w_img/2; y(:)'-h_img/2; x(:)'+w_img/2; y(:)'+ h_img/2];

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('TextFont', window, 'Arial');

%% Control Logic

[single, ensemble, bias, firstRaceGender, secondRaceGender, trialTime, numTrials, trait, expString] = deal(NaN);

personcodes = ['AM'; 'BM'; 'LM'; 'WM'; 'AF'; 'BF'; 'LF'; 'WF'];
traits = {'attractive', 'punctual', 'afraid', 'angry', 'disgusted', 'dominant', 'feminine', 'happy', 'masculine', 'sad', 'surprised', 'threatening', 'trustworthy', 'unusual', 'babyfaced', 'educated'};

% Single or Ensemble
if (str2double(exp(1)) == 0); single = true; else; single = false; end
ensemble = ~single;

if (ensemble); if (str2double(exp(1)) == 1); bias = false; elseif (str2double(exp(1)) == 2); bias = true; else; bias = false; end; else; bias = false; end

if (ensemble); expString = 'sets of 6 images, each of which will be followed by a pair of'; else; expString = 'pairs of'; end

% Race and Gender

if (ensemble); firstRaceGender = personcodes(str2double(exp(5))+1, :); secondRaceGender = personcodes(str2double(exp(6))+1, :); end
firstPeople = [];
SecondPeople = [];

% Trial time
if (ensemble); trialTime = (str2double(exp(3)).*10)/1000; end

% Number of trials
numTrials = (hex2dec(exp(2))).*10;

% Trait
trait = traits{hex2dec(exp(4))+1};

%% Create stimulus list

data = cell([numTrials 1]);

stimuliorder = randperm(300);
stimuli = zeros([1200 1]);
firstensemble = [];
secondensemble = [];

stimloader = 0;

% Load noisy stimuli
for stimNum = stimuliorder
       tmp = [];
       if (floor(stimNum/100) ~= 0); tmp = num2str(stimNum); elseif (floor(stimNum/10) ~= 0); tmp = ['0' num2str(stimNum)]; else; tmp = ['00' num2str(stimNum)]; end
       stimuli((2.*stimNum)-1) = Screen('MakeTexture', window, imread(['../../stimuli/noisy/rcic_im_1_00' tmp '_ori.jpg']));
       stimuli(2.*stimNum) = Screen('MakeTexture', window, imread(['../../stimuli/noisy/rcic_im_1_00' tmp '_inv.jpg']));
       stimloader = stimloader + 1;
       DrawFormattedText(window, ['Loading Stimuli... ' num2str(round((stimloader/3.0))) '%'], 'center', 'center');
       Screen('Flip', window);
end

% Load ensemble stimuli
if (~single)
    firstdir = dir(['../../stimuli/cfd/img/' firstRaceGender '-*/*.jpg']);
    secondir = dir(['../../stimuli/cfd/img/' secondRaceGender '-*/*.jpg']);
    for fileNum = 1:length(firstdir)
        firstensemble = [firstensemble Screen('MakeTexture', window, imread([firstdir(fileNum).folder '/' firstdir(fileNum).name]))];
        DrawFormattedText(window, ['Loading Ensemble Stimuli...' num2str(round(100*(fileNum/(length(firstdir)+length(secondir))))) '%'], 'center', 'center');
        Screen('Flip', window);
    end
    for fileNum = 1:length(secondir)
        secondensemble = [secondensemble Screen('MakeTexture', window, imread([secondir(fileNum).folder '/' secondir(fileNum).name]))];
        DrawFormattedText(window, ['Loading Ensemble Stimuli...' num2str(round(100*((fileNum+length(firstdir))/(length(firstdir)+length(secondir))))) '%'], 'center', 'center');
        Screen('Flip', window);
    end
end

% Shuffle ensemble stimuli
%firstensemble = firstensemble(randperm(length(firstensemble)));
%secondensemble = secondensemble(randperm(length(secondensemble)));

%% Introduction

DrawFormattedText(window, ['Welcome to the experiment. \n \n You will be shown a series of ' expString ' images. \n \n You will be asked to choose the image that most corresponds with a certain trait. \n \n A break will be taken after every 50 trials, or you can cancel the experiment at any time by pressing Escape. \n \n Press any key to continue. '], 'center', 'center', 0, 50);
Screen('Flip', window);
KbWait();

%% Start experiment
KbQueueCreate(kbPointer);
while KbCheck; end
KbQueueStart(kbPointer);

for trail = 1:numTrials
    [pressed, firstPress] = KbQueueCheck(kbPointer);
    if firstPress(KbName('ESCAPE')); break; end
    
    if mod(trail, 50) == 0
        DrawFormattedText(window, ["You've reached " num2str(trail) " trials. Please feel free to take a break. Press any key to continue when you're ready."], 'center', 'center', 0, 50);
        Screen('Flip', window);
    end
        
    if ~bias && ~single
        Shuffle(firstensemble);
        Shuffle(secondensemble);
        
        textlist = zeros([6 1]);
        textlist = [firstensemble(1:3) secondensemble(1:3)];
        
        [pressed, firstPress] = KbQueueCheck(kbPointer);
        if firstPress(KbName('ESCAPE')); break; end
    
        Screen('DrawTextures', window, textlist, [], xy_rect);
        Screen('Flip', window);
        
        WaitSecs(trialTime);
        Screen('Flip', window);
    elseif bias && ~single
        Shuffle(firstensemble)
        Shuffle(secondensemble)
        
        textlist = zeros([6 1]);
        textlist = [firstensemble(1:5) secondensemble(1)];
        Shuffle(textlist)
        
        [pressed, firstPress] = KbQueueCheck(kbPointer);
        if firstPress(KbName('ESCAPE')); break; end
        
        Screen('DrawTextures', window, textlist, [], xy_rect);
        Screen('Flip', window);
        
        WaitSecs(trialTime);  
        Screen('Flip', window);
    end
    
    % Show noisy images
    
    imagesToShowThisTrial = stimuli((2*stimuliorder(trail))-1:(2*stimuliorder(trail)));
    listToCheckNoiseOrAntiNoise = imagesToShowThisTrial;
    noiseOrAntiNoise = [0 0]; % true if noise, false if antinoise

    imagesToShowThisTrial = imagesToShowThisTrial(randperm(2));
    if listToCheckNoiseOrAntiNoise(1) == imagesToShowThisTrial(1); noiseOrAntiNoise(1) = true; else; noiseOrAntiNoise(1) = false; end
    noiseOrAntiNoise(2) = ~noiseOrAntiNoise(1);

    [pressed, firstPress] = KbQueueCheck(kbPointer);
    if firstPress(KbName('ESCAPE')); break; end

    Screen('DrawLines', window, [695 745 720 720; 450 450 425 475], 5, 0); % Draw the fixation cross
    Screen('DrawTexture', window, imagesToShowThisTrial(1), [], [xCenter-384  yCenter-128 xCenter-128 yCenter+128]);
    Screen('DrawTexture', window, imagesToShowThisTrial(2), [], [xCenter+128, yCenter-128 xCenter+384 yCenter+128]);

    DrawFormattedText(window, ['Click on the image that you think is more ' trait '.'], xCenter-250, yCenter+250);

    Screen('Flip', window);
    
    [pressed, firstPress] = KbQueueCheck(kbPointer);
    if firstPress(KbName('ESCAPE')); break; end
    
    [x,y,clicks] = GetMouse(window);
    while true
        if any(clicks) && (((x > xCenter-384 && x < xCenter-128) || (x > xCenter + 128 && x < xCenter + 384)) && (y > yCenter - 256 && y < yCenter + 256))
            break
        end
        
        [pressed, firstPress] = KbQueueCheck(kbPointer);
        if firstPress(KbName('ESCAPE')); breakout = true; break; end
    
        [x,y,clicks] = GetMouse(window);
    end
    if breakout; break; end
    
    data{trail} = [[x y] noiseOrAntiNoise];

    DrawFormattedText(window, 'Press any key to continue.', 'center', 'center');
    Screen('Flip', window);

    KbWait();
        
    [pressed, firstPress] = KbQueueCheck(kbPointer);
    if firstPress(KbName('ESCAPE')); break; end
end    

DrawFormattedText(window, 'You have reached the end of the experiment. Thank you for working with us. ', 'center', 'center');
Screen('Flip', window);
KbWait();

Screen('Close');
Screen('CloseAll');