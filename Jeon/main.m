% Define global variables and parameters
global winSize_ms notes_Hz
notes_Hz = 440 * 2 .^ ((-11:1:10) ./ 12);
winSize_ms =1000;
overlap = 0.99;

root_dir = './dataset';
[audioData, Fs] = readMp3GUI(root_dir);

endIdx=min(length(audioData), Fs*60);
segmentAudioData = audioData(1:endIdx);

% segmentAudioData = bpfProcessing(segmentAudioData, notes_Hz, Fs);
% segmentAudioData = segmentAudioData';

noteMat = MusicMatExtraction(segmentAudioData, winSize_ms, overlap ,notes_Hz, Fs);


% Replay the sound matrix from note matrix
soundMat = ReplaySoundMat(noteMat', round(winSize_ms*(1-overlap)), notes_Hz, Fs);

% sound(soundMat, Fs);
saveAudioAsWav(soundMat, Fs);



