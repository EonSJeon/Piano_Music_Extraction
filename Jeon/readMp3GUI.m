function [audioData, Fs] = readMp3GUI(root_dir)
    % Check if the root directory exists
    if ~exist(root_dir, 'dir')
        error('Directory does not exist: %s', root_dir);
    end
    
    % Open file selection dialog box
    [filename, pathname] = uigetfile({'*.mp3', 'MP3 files (*.mp3)'}, 'Select an MP3 file', root_dir);
    
    % Check if a file was selected
    if isequal(filename, 0) || isequal(pathname, 0)
        disp('User pressed cancel');
        return;
    else
        fullFileName = fullfile(pathname, filename);
        disp(['User selected ', fullFileName]);
    end
    
    % Read the MP3 file as an audio matrix and get the sample rate
    [audioData, Fs] = audioread(fullFileName);
    
    % Check if the audio data has more than one channel (stereo)
    if size(audioData, 2) > 1
        % Convert stereo to mono by averaging the two channels
        audioData = mean(audioData, 2);
        disp('Converted stereo to mono by averaging both channels.');
    end
end