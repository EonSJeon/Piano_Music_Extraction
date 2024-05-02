function noteMat = MusicMatExtraction(audioData, winSize_ms, overlap_portion, notes_Hz, Fs)
    duration_sp = length(audioData);
    winSize_sp = round(winSize_ms / 1000 * Fs);
    dft_N = winSize_sp*10;
    stride_sp = round(winSize_sp * (1 - overlap_portion));
    numWin = 1 + ceil((duration_sp - winSize_sp) / stride_sp);
    specData = zeros(length(notes_Hz), numWin);  % Preallocate for efficiency
    numNotes = length(notes_Hz);
    

    % Calculate frequency indices
    freqs = Fs * (0:(dft_N/2)) / dft_N;
    notes_Hz_idxs = zeros(1, length(notes_Hz));
    for i = 1:length(notes_Hz)
        [~, j] = min(abs(freqs - notes_Hz(i)));
        notes_Hz_idxs(i) = j;
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
        Y = fft(winData, dft_N);
        P2 = abs(Y / dft_N);
        P1 = P2(1:floor(dft_N/2) + 1);
        P1(2:end-1) = 2 * P1(2:end-1);

        specData(:, i) = P1(notes_Hz_idxs);
    end
    
    
    figure(1);
    heatmap(specData);
    grid off;

    specData(specData <= 0) = eps;
    specData = 10 * log(specData);
    specData = specData - max(specData,[],"all");

    specData = localThreshold(-1, specData, 12);

    % Visualize the approximated data as a heatmap
    figure(2);
    heatmap(specData);
    grid off;
    
    
    
    % tempMaxRange_ms = 5000;
    % tempMaxRange_sp = tempMaxRange_ms / 1000 * Fs;
    % tempMaxRange_numWin = round(tempMaxRange_sp / stride_sp);
    % 
    % % Local Threshold
    % specData = localThreshold(tempMaxRange_numWin, specData, 25);
    % 
    % % Eliminate short spikes
    % for i=1:numNotes
    %     specData(i,:)= eliminateSpikes(specData(i,:), 30);
    % end
    % 
    % % Hand Constriction
    % for i=1:numWin
    %     specData(:,i) = handConstriction(specData(:,i), 8, 9);
    % end
    % 
    % figure(2);
    % heatmap(specData);
    % grid off;
    % 
    % % Simple Moving Average as a low-pass filter
    % smoothSpan =3; % Example smoothing span
    % for i = 1:numNotes
    %     specData(i, :) = smooth(specData(i, :), smoothSpan);
    % end
    % specData = specData*10;
    % 
    % invalidIdx=find(specData<=0);
    % specData(invalidIdx)=-1000;
    % 
    % tempMaxRange_ms = 5000;
    % tempMaxRange_sp = tempMaxRange_ms / 1000 * Fs;
    % tempMaxRange_numWin = round(tempMaxRange_sp / stride_sp);
    % specData = localThreshold(tempMaxRange_numWin, specData, 300);
    % 
    % % Eliminate short spikes
    % for i=1:numNotes
    %     specData(i,:)= eliminateSpikes(specData(i,:), 33);
    % end
    % 
    % figure(3);
    % heatmap(specData);
    % grid off;

    noteMat = specData;
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

    % tempMaxRange_ms = 2000;
    % tempMaxRange_sp = tempMaxRange_ms / 1000 * Fs; 
    % tempMaxRange_numWin = round(tempMaxRange_sp / stride_sp); 
    % 
    % pcaOverlap = 0.99;
    % pcaStride = tempMaxRange_numWin * (1 - pcaOverlap);
    % 
    % L = 1 + ceil((numWin - tempMaxRange_numWin) / pcaStride);  
    
    % for i = 1:L
    %     % Calculate starting and ending indices for the window
    %     srtIdx = 1 + pcaStride * (i - 1);
    %     endIdx = min(numWin, srtIdx + tempMaxRange_numWin - 1);  
    

    % meanTempSpecMat = mean(specData, 1);
    % centeredTempSpecMat = specData - meanTempSpecMat;
    % 
    % % Perform PCA
    % [coeff, score, ~, ~, explained] = pca(centeredTempSpecMat);
    % 
    % % Filter based on explained variance (get indices of significant components)
    % significantComponents = explained >= 10;
    % significantIdxs = find(significantComponents);
    % 
    % % Filter coeff and score matrices to retain only significant components
    % score = score(:, significantComponents);
    % 
    % % Sparsify the score vectors
    % for idx = 1:length(significantIdxs)
    %     % Get the index for the current column in the filtered score matrix
    %     componentIdx = significantIdxs(idx);
    % 
    %     % Find the index of the maximum value in the score vector for this component
    %     [~, maxIdx] = max(abs(score(:, componentIdx)));  % Use abs() to consider magnitude
    % 
    %     % Set all scores to zero and the maximum to 1
    %     score(:, idx) = 0;  % Set all elements to zero
    %     score(maxIdx, idx) = 1;  % Set only the maximum score to 1
    % end
    % 
    % 
    % coeff = coeff(:, significantComponents);

    % Approximate original data using the principal component scores of significant components only
    % approxData = score * coeff'+meanTempSpecMat;
    
    %     % Conditional assignment based on loop iteration
    %     if i ~= L
    %         specData(:, srtIdx:srtIdx + pcaStride - 1) = approxData(:, 1:pcaStride);
    %     else
    %         specData(:, srtIdx:endIdx) = approxData(:, 1:size(approxData, 2));
    %     end
    % end