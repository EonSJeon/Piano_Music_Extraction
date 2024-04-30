function saveAudioAsWav(audioData, Fs)
    % Check if audioData is a valid audio signal
    if isempty(audioData) || min(size(audioData)) ~= 1
        error('Input must be a non-empty audio vector.');
    end
    
    % Check for valid sample rate
    if ~isscalar(Fs) || Fs <= 0
        error('Sample rate must be a positive scalar.');
    end
    
    % Define the default file name for the save dialog
    defaultFileName = 'outputAudio.wav';

    % Open save dialog box to specify the filename and path for the WAV file
    [fileName, pathName] = uiputfile({'*.wav', 'WAV-files (*.wav)'}, 'Save as WAV', defaultFileName);

    % Check if the user pressed cancel
    if isequal(fileName, 0) || isequal(pathName, 0)
        disp('User cancelled the save operation.');
        return;
    else
        fullFileName = fullfile(pathName, fileName);
        disp(['Saving file: ', fullFileName]);
    end

    % Write the audio vector to a WAV file
    try
        audiowrite(fullFileName, audioData, Fs);
        disp(['File successfully saved to: ', fullFileName]);
    catch ME
        error('Failed to write file: %s', ME.message);
    end
end

