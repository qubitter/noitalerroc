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

%  123456

%  First digit: 
%     single (0), unbiased ensemble (1), or biased ensemble (2)
%  Second digit:
%      Tens of trials in hex
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

%% Data is stored as follows:

%  First row is subject data - {Name, Age, Handedness}
%  Second row is testing data - {kindOfTrial, numTrials, trait, trialTime, firstRG,
%  secondRG}
%  Following rows are testing data - {a, b, c, d}

%  a:
%     Which image was chosen - 1 for left, 0 for right
%  b: 
%     Whether the chosen image was noise or anti-noise - 1 for noise, 0 for
%     anti-noise
%  c: 
%     Which image was used - ID number
%  d:
%     [topLeftImageName topMidImageName topRightImageName;
%     bottomLeftImageName bottomMidImageName bottomRightImageName]
%     (ensemble only)

%% Setup

name = input('Please enter your name. ', 's');
age = input('Please enter your age. ', 's');
hand = input('Please enter your handedness - L for left-handed, R for right-handed. ', 's');

personalData = {name age hand};

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

[kindOfTrial, single, ensemble, bias, firstRaceGender, secondRaceGender, trialTime, numTrials, trait, expString] = deal(NaN);

personcodes = ['AM'; 'BM'; 'LM'; 'WM'; 'AF'; 'BF'; 'LF'; 'WF'];
traits = {'attractive', 'punctual', 'afraid', 'angry', 'disgusted', 'dominant', 'feminine', 'happy', 'masculine', 'sad', 'surprised', 'threatening', 'trustworthy', 'unusual', 'babyfaced', 'educated'};

% Single or Ensemble
if (str2double(exp(1)) == 0); single = true; else; single = false; end
ensemble = ~single;

if (ensemble); if (str2double(exp(1)) == 1); bias = false; kindOfTrial = 'unbiased ensemble'; elseif (str2double(exp(1)) == 2); bias = true; kindOfTrial = 'biased ensemble'; else; bias = false; end; else; bias = false; end

if (ensemble); expString = 'sets of 6 images, each of which will be followed by a pair of'; else; expString = 'pairs of'; kindOfTrial = 'single'; end

% Race and Gender

if (ensemble); firstRaceGender = personcodes(str2double(exp(5))+1, :); secondRaceGender = personcodes(str2double(exp(6))+1, :); end
firstPeople = [];
SecondPeople = [];

% Trial time
if (ensemble); trialTime = (str2double(exp(4)).*10)/1000; end

% Number of trials
numTrials = (hex2dec(exp(2))).*20;

% Trait
trait = traits{hex2dec(exp(3))+1};

if single; trialData = {kindOfTrial num2str(numTrials) trait}; else;  trialData = {kindOfTrial num2str(numTrials) trait [num2str(trialTime*1000) 'ms'] firstRaceGender secondRaceGender};end

%% Create stimulus list

if ensemble
    data = cell([numTrials 9]);
    metadata = cell([1 9]);
else
    data = cell([numTrials 3]);
    metadata = cell([1 6]);
end

for i = 1:3
    metadata{1,i} = personalData{i};
end

if single
    for i = 4:6
        metadata{1,i} = trialData{i-3};
    end
elseif ensemble
    for i = 4:9
        metadata{1, i} = trialData{i-3};
    end
end

%% Load Stimuli

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
end

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
        DrawFormattedText(window, ['You''ve reached ' num2str(trail) ' trials. Please feel free to take a break. Press any key to continue when you''re ready.'], 'center', 'center', 0, 50);
        Screen('Flip', window);
    end
    
    % Show ensemble images, if necessary
        
    if ~bias && ~single
        firstdir = Shuffle(firstdir);
        secondir = Shuffle(secondir);
        
        timer = GetSecs();
        
        textlist = Shuffle({[firstdir(1).folder '/' firstdir(1).name] [firstdir(2).folder '/' firstdir(2).name] [firstdir(3).folder '/' firstdir(3).name] [secondir(1).folder '/' secondir(1).name] [secondir(2).folder '/' secondir(2).name] [secondir(3).folder '/' secondir(3).name]});
        
        datawrite = cell([1 6]);
        
        for i = 1:6
            temp = strsplit(textlist{i}, '/');
            temp = temp{end};
            datawrite{i} = temp;
        end    
        
        textlist = Shuffle([Screen('MakeTexture', window, imread(textlist{1})) Screen('MakeTexture', window, imread(textlist{2})) Screen('MakeTexture', window, imread(textlist{3})) Screen('MakeTexture', window, imread(textlist{4})) Screen('MakeTexture', window, imread(textlist{5})) Screen('MakeTexture', window, imread(textlist{6}))]);
        timer = GetSecs()-timer;
        
        WaitSecs(1.5-timer); % ITI is roughly between 0.9 and 1.1 seconds - WaitSecs is used to normalize to 1.5 seconds
        
        [pressed, firstPress] = KbQueueCheck(kbPointer);
        if firstPress(KbName('ESCAPE')); break; end
    
        Screen('DrawTextures', window, textlist, [], xy_rect);
        Screen('Flip', window);
        
        WaitSecs(trialTime);
        Screen('Flip', window);
    elseif bias && ~single
        firstdir = Shuffle(firstdir);
        secondit = Shuffle(secondir);
        
        timer = GetSecs();
        
        textlist = Shuffle({[firstdir(1).folder '/' firstdir(1).name] [firstdir(2).folder '/' firstdir(2).name] [firstdir(3).folder '/' firstdir(3).name] [firstdir(4).folder '/' firstdir(4).name] [firstdir(5).folder '/' firstdir(5).name] [secondir(1).folder '/' secondir(1).name]});
        
        datawrite = cell([1 6]);
        
        for i = 1:6
            temp = strsplit(textlist{i}, '/');
            temp = temp{end};
            datawrite{i} = temp;
        end  
        
        textlist = Shuffle([Screen('MakeTexture', window, imread(textlist{1})) Screen('MakeTexture', window, imread(textlist{2})) Screen('MakeTexture', window, imread(textlist{3})) Screen('MakeTexture', window, imread(textlist{4})) Screen('MakeTexture', window, imread(textlist{5})) Screen('MakeTexture', window, imread(textlist{6}))]);
        
        timer = GetSecs()-timer;
        
        WaitSecs(1.5-timer); % ITI is roughly between 0.9 and 1.1 seconds - WaitSecs is used to normalize to 1.5 seconds
        
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
    if listToCheckNoiseOrAntiNoise(1) == imagesToShowThisTrial(1); noiseOrAntiNoise(1) = true; end
    noiseOrAntiNoise(2) = ~noiseOrAntiNoise(1);

    [pressed, firstPress] = KbQueueCheck(kbPointer);
    if firstPress(KbName('ESCAPE')); break; end

    Screen('DrawLines', window, [695 745 720 720; 450 450 425 475], 5, 0); % Draw the fixation cross
    Screen('DrawTexture', window, imagesToShowThisTrial(1), [], [xCenter-384  yCenter-128 xCenter-128 yCenter+128]);
    Screen('DrawTexture', window, imagesToShowThisTrial(2), [], [xCenter+128, yCenter-128 xCenter+384 yCenter+128]);

    DrawFormattedText(window, ['Click on the image that you think is more ' trait '.'], 'center' , yCenter+250);

    Screen('Flip', window);
    
    [pressed, firstPress] = KbQueueCheck(kbPointer);
    if firstPress(KbName('ESCAPE')); break; end
    
    [x,y,clicks] = GetMouse(window);
    while true
        if any(clicks) && (((x > xCenter-384 && x < xCenter-128) || (x > xCenter + 128 && x < xCenter + 384)) && (y > yCenter - 128 && y < yCenter + 128))
            break
        end
        
        [pressed, firstPress] = KbQueueCheck(kbPointer);
        if firstPress(KbName('ESCAPE')); breakout = true; break; end
    
        [x,y,clicks] = GetMouse(window);
    end
    if breakout; break; end
    
    noiser = noiseOrAntiNoise(~(x > xCenter-384 && x < xCenter-128) + 1);
    if noiser == 0; noiser = -1; end
    
    trailData = {(x > xCenter-384 && x < xCenter-128) noiser stimuliorder(trail)};
    
    for i = 1:3
        data{trail, i} = trailData{i};
    end
    
    if ensemble
        for i = 1:6
            data{trail, i+3} = datawrite{i};
        end
    end    

    DrawFormattedText(window, 'Press any key to continue.', 'center', 'center');
    Screen('Flip', window);

    KbWait();
    Screen('Flip', window);
        
    [pressed, firstPress] = KbQueueCheck(kbPointer);
    if firstPress(KbName('ESCAPE')); break; end
    
end    

%% Store Data

DrawFormattedText(window, 'You have reached the end of the experiment. Thank you for working with us. ', 'center', 'center');
Screen('Flip', window);
KbWait();

data = cell2table(data);
metadata = cell2table(metadata);

if single
    data.Properties.VariableNames = {'Side', 'Noise', 'Image'};
    metadata.Properties.VariableNames = {'Name', 'Age', 'Handedness', 'KindOfTrials', 'NumberOfTrials', 'Trait'};
elseif ensemble
    data.Properties.VariableNames = {'Side', 'Noise', 'Image', 'TopLeft', 'TopMid', 'TopRight', 'BottomLeft', 'BottomMid', 'BottomRight'};
    metadata.Properties.VariableNames = {'Name', 'Age', 'Handedness', 'KindOfTrials', 'NumberOfTrials', 'Trait', 'TrialTime', 'firstRaceGender', 'secondRaceGender'};

end 

writetable(data, ['../../data/response_' name num2str(age) hand '.csv']);
writetable(metadata, ['../../data/response_' name num2str(age) hand '_meta.csv']);

Screen('Close');
Screen('CloseAll');