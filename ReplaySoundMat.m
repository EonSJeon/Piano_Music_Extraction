function soundMat = ReplaySoundMat(seq, winSize_ms, notes_Hz, Fs)
    % Validate the size of the sequence and frequencies
    [L, numFreqs] = size(seq);
    if numFreqs ~= length(notes_Hz)
        error('The number of columns in seq must match the length of freqs');
    end
    
    % Calculate the number of samples in each window
    numSamples = round(Fs * winSize_ms / 1000);
    win_t_s = linspace(0, winSize_ms/1000, numSamples);
    
    % Initialize the sound array
    soundMat = [];
    
    % Generate the sound for each window
    for i = 1:L
        winSound = zeros(1, numSamples);
        for j = 1:numFreqs
            if seq(i, j) == 1
                f_Hz = notes_Hz(j);
                winSound = winSound + sin(2 * pi * f_Hz * win_t_s);
            end
        end
        soundMat = [soundMat, winSound];
    end
end
