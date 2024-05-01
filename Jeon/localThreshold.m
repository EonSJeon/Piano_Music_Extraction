function specMat = localThreshold(localRange_numWin, specMat, threshold)
    if localRange_numWin ==-1 % total
        totMax = max(specMat, [], 'all');
        specMat = specMat - totMax +threshold;

        inValidNotesIdx = find(specMat < 0);
        specMat(inValidNotesIdx) = 0;

        return
    end
    numWin = size(specMat,2);
    
    for i = 1:numWin
        % Calculate starting and ending indices for the window
        srtIdx = max(1, i - localRange_numWin);
        endIdx = min(numWin, i + round(localRange_numWin/2));

        % Extract the segment of the matrix and find local maximum
        locMax = max(specMat(:, srtIdx:endIdx), [], 'all');

        % Retrieve current notes vector
        currNotesVec = specMat(:, i);

        % Normalize the segment matrix
        currNotesVec = currNotesVec - locMax + threshold;

        % Find indices of notes with non-positive values and set them to zero
        inValidNotesIdx = find(currNotesVec < 0);
        currNotesVec(inValidNotesIdx) = 0;

        % Update the matrix with the processed column
        specMat(:, i) = currNotesVec;
    end
end

