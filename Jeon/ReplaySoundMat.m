function soundMat = ReplaySoundMat(seq, winSize_ms, notes_Hz, Fs)
    % Validate the size of the sequence and frequencies
    [L, numFreqs] = size(seq);
    if numFreqs ~= length(notes_Hz)
        error('The number of columns in seq must match the length of freqs');
    end
    
    % Calculate the number of samples in each window and total duration
    winSize_sp = round(winSize_ms / 1000 * Fs);  % Number of samples per window
    duration_s = L * winSize_ms / 1000;          % Total duration in seconds
    numSamples = round(Fs * duration_s);         % Total number of samples
    t_s = linspace(0, duration_s, numSamples);   % Time vector for the entire duration
    
    % Initialize the sound matrix
    soundMat = zeros(1, numSamples);
    
    % Iterate over each frequency
    for i = 1:numFreqs
        f_Hz = notes_Hz(i);
        singleNoteSound = sin(2 * pi * f_Hz * t_s);  % Generate the sound for this note
        
        % Create a mask based on the sequence activation
        mask = zeros(1, numSamples);  % Initialize mask
        noteStartIdx = 1;
        playing = false;  % Correctly initialize the logical variable
        
        for j = 1:L
            if seq(j, i) > 0 && ~playing  % Detect rising edge, start playing
                playing = true;
                noteStartIdx = j;
            elseif (seq(j, i) <= 0 || j == L) && playing  % Detect falling edge or end, stop playing
                playing = false;
                noteStart = (noteStartIdx - 1) * winSize_sp + 1;
                noteEnd = min(j * winSize_sp, numSamples);
                noteLength = noteEnd - noteStart + 1;
                
                if noteLength > 0  % Check if there is a valid length to apply Hann window
                    t= 1:noteLength;
                    target_fraction = 0.75;
                    alpha = log(target_fraction) / noteLength;
                    tone= 0.5*exp(alpha*t);
                    mask(noteStart:noteEnd) = tone';
                end
            end
        end

        
        % Apply the mask to the note sound
        singleNoteSound = singleNoteSound .* mask;  % Element-wise multiplication to apply mask
        soundMat = soundMat + singleNoteSound;      % Add this note's contribution to the overall sound
    end
end
