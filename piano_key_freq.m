function [closest_idx, key_freq] = piano_key_freq(freq)
%Converts frequencies detected by the FFT to a discrete piano key freq

% Define the reference frequency for A4 (440 Hz)
f0 = 440.0;

% Create an array to store the frequencies
key_frequencies = [];

% Calculate frequencies for all 88 keys (A0 to C8)
for n = -48:39
    % Calculate the frequency for each key
    key_frequencies = [key_frequencies f0 * (2 ^ (n / 12))];
end

differences = abs(freq-key_frequencies);

% Find the index of the minimum difference
[~, closest_idx] = min(differences);

key_freq = key_frequencies(closest_idx);
end