function correctedNotes = handConstriction(notesAtTheMoment, N, handSize)
    % Number of active notes
    numActiveNotes1 = sum(notesAtTheMoment > 0);
    numNotes = length(notesAtTheMoment);

    if numActiveNotes1 > N
        % Find the indices of the top N highest values
        [~, indices] = maxk(notesAtTheMoment, N);

        % Create a new array with zeros
        correctedNotes = zeros(size(notesAtTheMoment));

        % Set the top N highest notes in the new array
        correctedNotes(indices) = notesAtTheMoment(indices);
    else
        correctedNotes = notesAtTheMoment;
    end
    
    activeIndices = find(correctedNotes > 0);
    
    % Return original if no notes or spread is already within two hand spans
    if isempty(activeIndices) || (max(activeIndices) - min(activeIndices) + 1 <= handSize * 2)
        return;
    end

    % Initialize maximum effective note count and its corresponding indices
    maxEffNotesCount = 0;
    bestLHsrt = 0;
    bestRHend = 0;

    % Evaluate all pairs of start and end indices to simulate two hands playing
    for left = 1:length(activeIndices)
        leftHandSrtIdx = activeIndices(left);
        leftHandEndIdx = leftHandSrtIdx + handSize - 1;
        for right = left:length(activeIndices)
            rightHandEndIdx = activeIndices(right);
            rightHandSrtIdx = rightHandEndIdx - handSize + 1;
            if leftHandSrtIdx < rightHandSrtIdx && rightHandEndIdx > leftHandEndIdx
                effNotesCount = sum((activeIndices >= leftHandSrtIdx & activeIndices <= leftHandSrtIdx + handSize-1) | ...
                    (activeIndices >= rightHandEndIdx - handSize+1 & activeIndices <= rightHandEndIdx));
                
                if effNotesCount > maxEffNotesCount
                    maxEffNotesCount = effNotesCount;
                    bestLHsrt = leftHandSrtIdx;
                    bestRHend = rightHandEndIdx;
                end
            end
        end
    end

    % Apply the best indices to create mask
    mask = zeros(1, numNotes);
    mask(bestLHsrt:min(bestLHsrt + handSize - 1, numNotes)) = 1;
    mask(max(1, bestRHend - handSize + 1):bestRHend) = 1;

    correctedNotes = correctedNotes .* mask';
end
