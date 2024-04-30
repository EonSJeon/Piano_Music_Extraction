% Read in audio data
audio_file_path = 'Fur_Elise_Easy.mp3';
[audio_data, sample_rate] = audioread(audio_file_path);
[num_samples, num_channels] = size(audio_data);

% Convert audio to mono if it is stereo
if num_channels > 1
    audio_data = mean(audio_data,2);
end

% Normalize audio signal
audio_data = audio_data / max(abs(audio_data));

% Define window size / overlap
window_length = 2048;
overlap = 1024; % starting with 50% overlap of windows

num_windows = ceil((length(audio_data) - window_length) / overlap) + 1;

% Allocate array with length equal to number of windows
energy = zeros(num_windows, 1);

% Calculate short-term energy
for i=1:num_windows
    start_idx = (i-1)*overlap + 1;
    end_idx = min(start_idx+window_length - 1, length(audio_data));
    energy(i) = sum(audio_data(start_idx:end_idx).^2);
end

% Moving average of energy to smooth it out
moving_avg_energy = movmean(energy,3);
minPeakDistance = 7; % 7 for Fur Elise
minPeakHeight = 6; %1 for Fur Elise

[~, note_start_indices] = findpeaks(moving_avg_energy, 'MinPeakDistance', minPeakDistance, 'MinPeakHeight', minPeakHeight);
neg_moving_avg_energy = -moving_avg_energy;

minNegPeakHeight = -95; %-100 for Fur Elise
[~, note_end_indices] = findpeaks(-moving_avg_energy, 'MinPeakDistance', minPeakDistance, 'MinPeakHeight', minNegPeakHeight);

note_start_indices = note_start_indices(1:end-1); 
note_end_indices = note_end_indices(2:end);
%note_end_indices_2 = note_start_indices + 10;
%note_end_indices = note_end_indices-5;

if length(note_start_indices) == length(note_end_indices)
    step_length = window_length - overlap;
    data_note_start_indices = (note_start_indices - 1)*step_length;
    data_note_end_indices = (note_end_indices - 1)*step_length;

    num_music_segments = length(data_note_start_indices);
    peak_frequencies = [];
    num_samples = [];
    %amplitudes = [];
    decay_factors = [];
    
    for i=1:num_music_segments
        start_idx = data_note_start_indices(i);
        end_idx = data_note_end_indices(i);
        audio_data_segment = audio_data(start_idx:end_idx);

        N = length(audio_data_segment);
        hann_window = hann(N);
        windowed_segment = audio_data_segment.*hann_window;

        fft_data = fft(windowed_segment);
        freqs = (0:N-1) * sample_rate/N;
        
        fft_mag = abs(fft_data);
        fft_mag_normalized = fft_mag/max(fft_mag);
        %[~, peak_index] = max(fft_magnitude);
         
        %peak_frequency = freqs(peak_index);
        
        min_peak_height = 0.85;

        [~, freq_peak_indices] = findpeaks(fft_mag_normalized, "MinPeakHeight",min_peak_height);

        peak_freq = freqs(freq_peak_indices(1));

        peak_frequencies(i) = piano_key_freq(peak_freq);
        num_samples(i) = N;

        %amplitudes = [amplitude amplitudes];
        %decay_factors = [decay_factor decay_factors];

    end

else
    disp('Adjust peak detection parameters')
end

%%

% Initialize an empty array to store the audio data
reconstr_audio = [];

% Iterate through each frequency in the list

for i=1:length(peak_frequencies)
    t = 0:(1/sample_rate):(num_samples(i)/sample_rate);
    freq = peak_frequencies(i);

    duration = num_samples(i)/sample_rate;

    target_fraction = 0.75;
    alpha = log(target_fraction) / duration;

    sine_wave = 0.5*exp(alpha*t).*sin(2 * pi * freq * t);
    reconstr_audio = [reconstr_audio, sine_wave];
end

% Normalize the audio data to avoid clipping
reconstr_audio = reconstr_audio / max(abs(audio_data));

lower_cutoff_freq = 20;
upper_cutoff_freq = 5000;

[b, a] = butter(4, [lower_cutoff_freq, upper_cutoff_freq] / (sample_rate/2), 'bandpass');
reconstr_audio = filter(b,a,reconstr_audio);

% Play the audio data
sound(reconstr_audio, sample_rate);

audiowrite('Fur_Elise_Regenerated.mp3', reconstr_audio, sample_rate)
