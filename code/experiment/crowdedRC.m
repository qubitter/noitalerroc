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
Info = {'Code', 'Initials','Handedness [L = Left, R = Right]','Age','Ethnicity'};

dlg_title = 'Subject Information';

num_lines = 1;

subject_info = inputdlg(Info,dlg_title,num_lines);

%shoutout to ojus 

Screen('Preference', 'SkipSyncTests', 1);
[window, rect] = Screen('OpenWindow', 0); % opening the screen
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % allowing transparency in the photos 
num_pts = 6;
%HideCursor();
window_w = rect(3); % defining size of screen
window_h = rect(4);
x_Center = window_w * .75;
y_Center = window_h/2;
fhas = imread('FHAS.png');
for f = 1:292
    for i = 1:215
        if fhas(f,i) == 0
            fhas(f,i) = 255;
        end
    end
end
% making an array of numbers 1-49
for i = 1:num_pts
    tmp_bmp = fhas
    %tmp_bmp(:,:,4) = Mask_Plain;
    tid(i) = Screen('MakeTexture', window, flip(tmp_bmp));
    Screen('DrawText', window, 'Loading...', window_w/2, y_Center-25); % Write text to confirm loading of images
    Screen('DrawText', window, [int2str(int16(i*100/num_pts)) '%'], window_w/2, y_Center); % Write text to confirm percentage complete
    Screen('Flip', window); % Display text
end

w_img = size(tmp_bmp, 2) .* .75 ; % width of pictures
h_img = size(tmp_bmp, 1) .* .75; % height of pictures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculating the Circle Locations

%num_pts = 12;
radius = 250;

% Get a sequence of angles equally spaced around a circle using the
% function "linspace"
theta = linspace(360/num_pts,360,num_pts);

% Calculate coordinates of image locations centered along the circle
% using basic trigonometry
% Tips: function "cosd" and "sind"
x_circle = x_Center + (cosd(theta) * radius);
y_circle = window_h/2 + (sind(theta) * radius);
xy_circle = [x_circle-w_img/2; y_circle-h_img/2; x_circle + w_img/2; y_circle+h_img/2];
%xy_rect = ; % put all of the coordinates together and center the pictures

%% choosing the faces to show
% choose n faces randomly from the loaded faces 
faces = randsample(num_pts, num_pts); 
face = randsample(num_pts,1);

Mask_Plain = imread('mask.png');
Mask_Plain = 255-Mask_Plain(:,:,1); %use first layer % added


Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('TextFont', window, 'Arial');

%% Control Logic
% Trial time
trialTime = 1;

% Number of trials
numTrials = 300;

% Trait
trait = 'happy';

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

%% Introduction

DrawFormattedText(window, ['Welcome to the experiment. \n \n You will be shown a series of 300 images. \n \n You will be asked to choose the image that most corresponds with a certain trait. \n \n A break will be taken after every 49 trials, or you can cancel the experiment at any time by pressing Escape. \n \n Press any key to continue. '], 'center', 'center', 0, 50);
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
    q = Screen('MakeTexture', window, imresize(fhas, .75));
    Screen('DrawLines', window, [695 - 400 745 - 400 720 - 400 720 - 400; 450 450 425 475], 5, 0); %fixation cross
    Screen('DrawTexture', window, q, [], [x_Center - (162/2) y_Center - (219/2) x_Center + (162/2) y_Center + (219/2)]);
    Screen('DrawTextures', window, tid(faces), [], xy_circle); % display the faces
    Screen('Flip', window);
    WaitSecs(trialTime);    
    
    % Show noisy images
    
    imagesToShowThisTrial = stimuli((2*stimuliorder(trail))-1:(2*stimuliorder(trail)));
    listToCheckNoiseOrAntiNoise = imagesToShowThisTrial;
    noiseOrAntiNoise = [0 0]; % true if noise, false if antinoise

    imagesToShowThisTrial = imagesToShowThisTrial(randperm(2));
    if listToCheckNoiseOrAntiNoise(1) == imagesToShowThisTrial(1); noiseOrAntiNoise(1) = true; end
    noiseOrAntiNoise(2) = ~noiseOrAntiNoise(1);
    x_center = window_w/2
    [pressed, firstPress] = KbQueueCheck(kbPointer);
    if firstPress(KbName('ESCAPE')); break; end

    Screen('DrawLines', window, [695 745 720 720; 450 450 425 475], 5, 0); % Draw the fixation cross
    Screen('DrawTexture', window, imagesToShowThisTrial(1), [], [x_center-384  y_Center-128 x_center-128 y_Center+128]);
    Screen('DrawTexture', window, imagesToShowThisTrial(2), [], [x_center+128, y_Center-128 x_center+384 y_Center+128]);

    DrawFormattedText(window, ['Click on the image that you think is more ' trait '.'], 'center' , y_Center+250);

    Screen('Flip', window);
    
    [pressed, firstPress] = KbQueueCheck(kbPointer);
    if firstPress(KbName('ESCAPE')); break; end
    
    [x,y,clicks] = GetMouse(window);
    while true
        if any(clicks) && (((x > x_center-384 && x < x_center-128) || (x > x_center + 128 && x < x_center + 384)) && (y > y_Center - 128 && y < y_Center + 128))
            break
        end
        
        [pressed, firstPress] = KbQueueCheck(kbPointer);
        if firstPress(KbName('ESCAPE')); breakout = true; break; end
    
        [x,y,clicks] = GetMouse(window);
    end
    if breakout; break; end
    
    noiser = noiseOrAntiNoise(~(x > x_center-384 && x < x_center-128) + 1);
    if noiser == 0; noiser = -1; end
    
    trailData = {(x > x_center-384 && x < x_center-128) noiser stimuliorder(trail)};
    
    for i = 1:3
        data{trail, i} = trailData{i};
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
for i = 1:5
    metadata(i) = string(subject_info{i});
end
data = cell2table(data);


writetable(data, ['../../data/response_' + string(metadata(1)) + string(metadata(2)) + string(metadata(3)) + string(metadata(4)) + string(metadata(5)) +  '.csv']);
%writetable(metadata, ['../../data/response_' + string(metadata(1)) + string(metadata(2)) + string(metadata(3)) + string(metadata(4)) + string(metadata(5)) +  '_meta.csv']);

Screen('Close');
Screen('CloseAll');
