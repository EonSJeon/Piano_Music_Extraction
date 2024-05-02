% Constants
hw = 2;
duration_th = 300;
duration = 8;
wrongDelTh= 380;
h = [1000, wrongDelTh, 500];        % Heights
a = -h./hw^2;               % Precompute 'a' for each parabola (negative acceleration)
t_apex = [2, 4, 5];         % Apex times for each parabola

% Time vector
t  = 0:0.2:duration;

% Preallocate y for efficiency
y = zeros(5*length(h), length(t));

% Calculate each parabola
for j = 1:5*length(h)
    i =ceil(j/5)
    
    y(j, :) = a(i) * (t - t_apex(i)).^2 + h(i) + duration_th;
end



% Zero out negative values (e.g., after the parabola falls below the duration threshold)
y(y < 0) = 0;

figure(8);
bar3(y);

% Plot using bar3
figure(1);
heatmap(y);
grid off;

% Just duration_th
y=y-duration_th;
y(y<0)=0;
figure(2);
heatmap(y);
grid off;

y1=y;
y1(y1>0)=100;
figure(3);
heatmap(y1);
grid off;

% Correct form
y(2,:)=0;
figure(4);
heatmap(y);
grid off;

y(y>0)=100;
figure(5);
heatmap(y);
grid off;


% Calculate each parabola
for i = 1:length(h)
    y(i, :) = a(i) * (t - t_apex(i)).^2 + h(i) + duration_th;
end

y = y - (duration_th + wrongDelTh);
% Delete wrong note but temporal error
y(y<0)=0;
figure(6);
heatmap(y);
grid off;

y(y>0)=100;
figure(7);
heatmap(y);
grid off;





% % Initialize note mappings
% init_NOTE2NUM_and_NUM2NOTE();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Debug Tool
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Generate test matrix with specific notes and durations
% test = [];
% test = [test; genOneNoteMat('G4', 0.3)];
% test = [test; genOneNoteMat('', 0.1)];
% test = [test; genOneNoteMat('E4', 0.3)];
% test = [test; genOneNoteMat('', 0.1)];
% test = [test; genOneNoteMat('E4', 0.3)];
% test = [test; genOneNoteMat('', 0.1)];
% test = [test; genOneNoteMat('F4', 0.3)];
% test = [test; genOneNoteMat('', 0.1)];
% test = [test; genOneNoteMat('D4', 0.3)];
% test = [test; genOneNoteMat('', 0.1)];
% test = [test; genOneNoteMat('D4', 0.3)];
% test = [test; genOneNoteMat('', 0.1)];
% test = [test; genOneNoteMat('C4', 0.3)];
% test = [test; genOneNoteMat('', 0.1)];
% test = [test; genOneNoteMat('D4', 0.3)];
% test = [test; genOneNoteMat('', 0.1)];
% test = [test; genOneNoteMat('E4', 0.3)];
% test = [test; genOneNoteMat('', 0.1)];
% test = [test; genOneNoteMat('F4', 0.3)];
% test = [test; genOneNoteMat('', 0.1)];
% test = [test; genOneNoteMat('G4', 0.3)];
% test = [test; genOneNoteMat('', 0.1)];
% test = [test; genOneNoteMat('G4', 0.3)];
% test = [test; genOneNoteMat('', 0.1)];
% test = [test; genOneNoteMat('G4', 0.3)];
% test = [test; genOneNoteMat('', 0.1)];
% 
% % Assume ReplaySoundMat is defined elsewhere, adapt its signature as needed
% soundMat = ReplaySoundMat(test, winSize_ms, notes_Hz, Fs);
% sound(soundMat, Fs);  % Make sure to specify the sampling frequency

function oneNoteMat = genOneNoteMat(note, duration_s)
    global winSize_ms notes_Hz NOTE2NUM
    numWin = round(duration_s * 1000 / winSize_ms);
    noteWin = zeros(1, length(notes_Hz));
    if isempty(note)
        
    elseif isfield(NOTE2NUM, note)
        noteIndex = NOTE2NUM.(note);
        noteWin(noteIndex) = 1;
    else
        error('Note name does not exist in NOTE2NUM mapping.');
    end
    
    oneNoteMat = repmat(noteWin, numWin, 1);
end


function init_NOTE2NUM_and_NUM2NOTE()
    global NOTE2NUM NUM2NOTE
    % NOTE2NUM: Mapping from note names to numeric values
    NOTE2NUM = struct(...
        'A2', 1, 'As2', 2, 'B2', 3, ...
        'C2', 4, 'Cs2', 5, 'D2', 6, ...
        'Ds2', 7, 'E2', 8, 'F2', 9, ...
        'Fs2', 10, 'G2', 11, 'Gs2', 12, ...
        'A3', 13, 'As3', 14, 'B3', 15, ...
        'C3', 16, 'Cs3', 17, 'D3', 18, ...
        'Ds3', 19, 'E3', 20, 'F3', 21, ...
        'Fs3', 22, 'G3', 23, 'Gs3', 24, ...
        'A4', 25, 'As4', 26, 'B4', 27, ...
        'C4', 28, 'Cs4', 29, 'D4', 30, ...
        'Ds4', 31, 'E4', 32, 'F4', 33, ...
        'Fs4', 34, 'G4', 35, 'Gs4', 36);
    
    % Creating NUM2NOTE by reversing the NOTE2NUM mapping
    noteNames = fieldnames(NOTE2NUM);  % Get all note names as field names
    noteValues = struct2array(NOTE2NUM);  % Get corresponding numeric values
    
    % Initialize NUM2NOTE as an empty struct
    NUM2NOTE = struct();
    
    % Loop through each note and assign it to the correct numeric value
    for i = 1:length(noteNames)
        noteName = noteNames{i};
        noteValue = noteValues(i);
        % Dynamically create fields in NUM2NOTE struct
        NUM2NOTE.(['n' num2str(noteValue)]) = noteName;  % Use 'n' prefix to form valid field names
    end
end
