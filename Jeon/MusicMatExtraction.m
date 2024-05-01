function noteMat = MusicMatExtraction(audioData, winSize_ms, overlap_portion, notes_Hz, Fs)
    duration_sp = length(audioData);
    winSize_sp = round(winSize_ms / 1000 * Fs);
    stride_sp = round(winSize_sp * (1 - overlap_portion));
    numWin = 1 + ceil((duration_sp - winSize_sp) / stride_sp);
    specMat = zeros(length(notes_Hz), numWin);  % Preallocate for efficiency
    numNotes = length(notes_Hz);

    
    
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
    specMat = specMat - max(specMat,[],"all");
    
    tempMaxRange_ms = 2500;
    tempMaxRange_sp = tempMaxRange_ms / 1000 * Fs;
    tempMaxRange_numWin = round(tempMaxRange_sp / stride_sp);
    
    % Local Threshold
    specMat = localThreshold(tempMaxRange_numWin, specMat, 18);
    
    % Hand Constriction
    for i=1:numWin
        specMat(:,i) = handConstriction(specMat(:,i), 8, 11);
    end

    % Eliminate short spikes
    for i=1:numNotes
        specMat(i,:)= eliminateSpikes(specMat(i,:), 55);
    end

    % Simple Moving Average as a low-pass filter
    smoothSpan =5; % Example smoothing span
    for i = 1:numNotes
        specMat(i, :) = smooth(specMat(i, :), smoothSpan);
    end
    specMat = specMat*10;
    
    invalidIdx=find(specMat<=0);
    specMat(invalidIdx)=-1000;
    
    tempMaxRange_ms = 5000;
    tempMaxRange_sp = tempMaxRange_ms / 1000 * Fs;
    tempMaxRange_numWin = round(tempMaxRange_sp / stride_sp);
    specMat = localThreshold(tempMaxRange_numWin, specMat, 100);

    % Eliminate short spikes
    for i=1:numNotes
        specMat(i,:)= eliminateSpikes(specMat(i,:), 40);
    end
    
    % figure(2);
    % bar3(specMat);
    % daspect([numNotes numWin  20]);

    noteMat = specMat;
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

  % minPeakDistance = 300;
    % minNegPeakDistance = 1000;
    % minPeakHeight = -12;
    % minNegPeakHeight = -120;
    % 
    % for i = 1:numNotes
    %     noteMat = specMat(i,:);
    %     [~, note_start_indices] = findpeaks(noteMat, 'MinPeakDistance', minPeakDistance, 'MinPeakHeight', minPeakHeight);
    %     [~, note_end_indices] = findpeaks(-noteMat, 'MinPeakDistance', minNegPeakDistance, 'MinPeakHeight', minNegPeakHeight);
    % 
    %     if isempty(note_start_indices) || isempty(note_end_indices)
    %         continue;  % Skip this iteration if no valid peaks are found
    %     end
    % 
    %     note_start_indices = note_start_indices(1:end-1);
    %     note_end_indices = note_end_indices(2:end);
    % 
    %     if isempty(note_start_indices) || isempty(note_end_indices)
    %         continue;  % Skip this iteration if trimming results in empty arrays
    %     end
    % 
    %     num_music_segments = length(note_start_indices);
    %     mask = zeros(1, length(noteMat));  % Ensure mask is the same length as noteMat
    %     for j = 1:num_music_segments
    %         start_idx = note_start_indices(j);
    %         differences = note_end_indices - start_idx;
    %         differences(differences <= 0) = inf;  % Prevent choosing an invalid end index
    %         [~, end_idx_idx] = min(differences);
    % 
    %         end_idx = note_end_indices(end_idx_idx);
    %         mask(start_idx:end_idx) = 1;
    %     end
    %     specMat(i,:) = mask;
    % end