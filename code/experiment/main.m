clear all;
close all;

exp = input('Please enter the experiment code. ', 's');

%% Code is processed as follows:
%  First digit: 
%      single (0), unbiased ensemble (1), or biased ensemble (2)
%  Second digit: 
%      if single, then race && gender - Asian m (0), Black m (1), Latino m
%      (2), White m (3) - female is male + 4
%      if ensemble, then first race && gender - Asian m (0), Black m (1), Latino m
%      (2), White m (3) - female is male + 4
%  Third digit: 
%      Time per image/set in tens of ms
%  Fourth digit:
%      Fives of trials in hex
%  Fifth digit: 
%      Trait - attractiveness (0), punctuality (1), afraid (2),
%      angry (3), disgusted (4), dominant (5), feminine (6), happy (7),
%      masculine (8), sad (9), surprised (a), threatening (b), trustworthy
%      (c), unusual (d), babyface (e), educated (f)
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

%% Control Logic

[single, ensemble, bias, firstRaceGender, secondRaceGender, trialTime, numTrials, trait, expString] = deal(NaN);

personcodes = ['AM'; 'BM'; 'LM'; 'WM'; 'AF'; 'BF'; 'LF'; 'WF'];
traits = {'Attractive', 'Punctual', 'Afraid', 'Angry', 'Disgusted', 'Dominant', 'Feminine', 'Happy', 'Masculine', 'Sad', 'Surprised', 'Threatening', 'Trustworthy', 'Unusual', 'Babyfaced', 'Educated'};

% Single or Ensemble
if (str2double(exp(1)) == 0); single = true; else; single = false; end
ensemble = ~single;

if (ensemble); if (str2double(exp(1)) == 1); bias = false; elseif (str2double(exp(1)) == 2); bias = true; end; end

if (ensemble); expString = 'sets of 6'; else; expString = 'pairs of'; end

% Race and Gender
firstRaceGender = personcodes(str2double(exp(2))+1, :);
if (ensemble); secondRaceGender = personcodes(str2double(exp(6))+1, :); else; secondRaceGender = NaN; end

% Trial time
trialTime = str2double(exp(3)).*10;

% Number of trials
numTrials = (hex2dec(exp(4))+1).*10;

% Trait
trait = traits{hex2dec(exp(5))+1};

%% Introduction

DrawFormattedText(window, ['Welcome to the experiment. \n \n You will be shown a series of ' expString ' images. \n \n You will be asked to choose the image that most corresponds with a certain trait. \n \n A break will be taken after 50 trials, or you can cancel the experiment at any time by pressing Escape. \n \n Press any key to continue. '], 'center', 'center', 0, 50);
Screen('Flip', window);
KbWait();

Screen('Close', window);