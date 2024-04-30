function noteMat = MusicMatExtraction(audioData, winSize_ms, overlap_portion, notes_Hz, Fs)
    duration_sp = length(audioData);
    winSize_sp = round(winSize_ms / 1000 * Fs);
    stride_sp = round(winSize_sp * (1 - overlap_portion));
    numWin = 1 + ceil((duration_sp - winSize_sp) / stride_sp);
    specMat = zeros(length(notes_Hz), numWin);  % Preallocate for efficiency
    
    % Calculate frequency indices
    freqs = Fs * (0:(winSize_sp/2)) / winSize_sp;
    notes_Hz_idxs = zeros(1, length(notes_Hz));
    for i = 1:length(notes_Hz)
        [~, idx] = min(abs(freqs - notes_Hz(i)));
        notes_Hz_idxs(i) = idx;
    end

    % Spectrogram computation
    for i = 1:numWin
        st_idx = 1 + (i - 1) * stride_sp;
        end_idx = min(winSize_sp + (i - 1) * stride_sp, duration_sp);
        winData = audioData(st_idx:end_idx);

        % Ensure the window is full by zero-padding if necessary
        if length(winData) < winSize_sp
            winData = [winData; zeros(winSize_sp - length(winData), 1)];  % Zero padding
        end
        
        % Apply the Hann window
        hannWindow = hann(winSize_sp);  % Create Hann window
        winData = winData .* hannWindow;  % Apply Hann window

        % FFT and frequency extraction
        Y = fft(winData, winSize_sp);
        P2 = abs(Y / winSize_sp);
        P1 = P2(1:floor(winSize_sp/2) + 1);
        P1(2:end-1) = 2 * P1(2:end-1);

        specMat(:, i) = P1(notes_Hz_idxs);
    end

    % Process the spectrogram further (dB conversion, normalization, smoothing)
    specMat(specMat <= 0) = eps;
    specMat = 10 * log10(specMat);
    specMat = specMat - max(specMat(:)) + 10;
    
    % % Simple Moving Average as a low-pass filter
    % smoothSpan = 3; % Example smoothing span
    % for i = 1:length(notes_Hz)
    %     specMat(i, :) = smooth(specMat(i, :), smoothSpan);
    % end

    specMat(specMat < 0) = 0;
    
    % Hand Constriction
    for i=1:numWin
        specMat(:,i) = handConstriction(specMat(:,i), 7, 12);
    end

    % Eliminate short spikes
    for i=1:length(notes_Hz)
        specMat(i,:)= eliminateSpikes(specMat(i,:), 150);
    end

    
    noteMat = specMat;  % Return the result
end





% % Display information about the file
% disp(['Audio data read from file: ', fullFileName]);
% disp(['Sample rate: ', num2str(Fs), ' Hz']);
% disp(['Number of samples: ', num2str(size(audioData, 1))]);
% disp(['Number of channels after conversion: ', num2str(size(audioData, 2))]);
% 
% % Optionally, plot the waveform of the audio file
% figure;
% plot(audioData);
% title('Waveform of the selected MP3 file (Mono)');
% xlabel('Sample number');
% ylabel('Amplitude');