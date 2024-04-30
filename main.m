% Define global variables and parameters
global NOTE2NUM NUM2NOTE winSize_ms notes_Hz
notes_Hz = 440 * 2 .^ ((-24:1:11) ./ 12);
winSize_ms = 200;

% Initialize note mappings
init_NOTE2NUM_and_NUM2NOTE();

root_dir = './dataset';
[audioData, Fs] = readMp3GUI(root_dir);

segmentAudioData = audioData(Fs*32:Fs*56);

saveAudioAsWav(segmentAudioData, Fs);

noteMat = MusicMatExtraction(segmentAudioData, winSize_ms, notes_Hz, Fs);
size(noteMat)
soundMat =ReplaySoundMat(noteMat',winSize_ms,notes_Hz, Fs);
sound(soundMat, Fs); 
saveAudioAsWav(soundMat, Fs);

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
