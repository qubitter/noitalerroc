%put this up front
window, rect = Screen('OpenWindow', 0, []);
window_w = rect(3); % defining size of screen
window_h = rect(4);

x_center = window_w/2;
y_center = window_h/2;

xStart = x_center/2;
xEnd = x_center * 1.5;
yStart = y_center/2;
yEnd = y_center * 1.5;
nRows = 2;
nCols = 3;
xvector = linspace(xStart, xEnd, nRows);
yvector = linspace(yStart, yEnd, nCols);
[x,y] = meshgrid(xvector, yvector);
w_img = 2444;
h_img = 1718;
xy_rect = [x(:)'-w_img/2; y(:)'-h_img/2; x(:)'+w_img/2; y(:)'+ h_img/2];

%put this at the bottom
for trial = 1:numTrials
    [pressed, firstPress] = KbQueueCheck(1);
    if firstPress(KbName('ESCAPE')); break; end
    if (single)
            
    elseif ~bias
        Shuffle(firstensemble)
        Shuffle(secondensemble)
        textlist = zeros([6 1]);
        textlist(1:6) = [firstensemble(1:3) secondensemble(1:3)];
        Screen('DrawTexture', window, textlist, [], xy_rect);
        Screen('Flip', window);
        WaitSecs(.1);
    else
        Shuffle(firstensemble)
        Shuffle(secondensemble)
        textlist = zeros([6 1]);
        textlist(1:6) = [firstensemble(1:5) secondensemble(1)];
        Screen('DrawTextures', window, Shuffle(textlist), [], xy_rect);
        Screen('Flip', window);
        WaitSecs(.1);
        
    end
end    