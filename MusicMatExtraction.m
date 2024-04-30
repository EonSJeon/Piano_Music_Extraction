function noteMat = MusicMatExtraction(audioData, winSize_ms, notes_Hz, Fs)
    duration_ms = length(audioData) / Fs * 1000;
    numWin = ceil(duration_ms / winSize_ms);
    winSize_sp = round(winSize_ms / 1000 * Fs);

    noteMat = zeros(length(notes_Hz), numWin);  % Preallocate for efficiency

    for i = 1:numWin
        st_idx = 1 + (i - 1) * winSize_sp;
        end_idx = min(i * winSize_sp, length(audioData));
        winData = audioData(st_idx:end_idx);

        % FFT and frequency extraction
        Y = fft(winData);
        P2 = abs(Y / length(winData));
        P1 = P2(1:floor(length(winData)/2)+1);
        P1(2:end-1) = 2*P1(2:end-1);
        freqs = Fs * (0:(length(winData)/2)) / length(winData);

        [~, idx] = max(P1);
        dominantFreq = freqs(idx);

        % Find the closest note frequency index
        [~, noteIdx] = min(abs(notes_Hz - dominantFreq));

        % Set the corresponding note index to 1
        winNote = zeros(length(notes_Hz), 1);
        winNote(noteIdx) = 1;

        noteMat(:, i) = winNote;
    end
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