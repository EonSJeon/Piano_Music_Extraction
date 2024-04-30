function cleanData = eliminateSpikes(data, N)
    % Input:
    % data - The 1D array of spectral data for a single frequency channel.
    % N - Minimum number of consecutive non-zero entries to retain.

    % Output:
    % cleanData - The cleaned data with short non-zero spikes removed.

    % Initialize the cleanData with zeros of the same size as input data
    cleanData = zeros(size(data));

    % Find indices where data is not zero
    nonZeroIndices = find(data ~= 0);

    % We need to find groups of consecutive indices
    if isempty(nonZeroIndices)
        return;  % If there are no non-zero entries, just return the zero array
    end

    % Calculate the gaps between consecutive non-zero indices
    gaps = diff(nonZeroIndices);

    % Find where gaps are greater than 1 (indicating a new segment of consecutive non-zeros)
    segmentStarts = [nonZeroIndices(1), nonZeroIndices(find(gaps > 1) + 1)];
    segmentEnds = [nonZeroIndices(find(gaps > 1)), nonZeroIndices(end)];

    % Process each segment
    for i = 1:length(segmentStarts)
        segmentLength = segmentEnds(i) - segmentStarts(i) + 1;
        if segmentLength >= N
            % If the segment length is greater than or equal to N, keep it
            cleanData(segmentStarts(i):segmentEnds(i)) = data(segmentStarts(i):segmentEnds(i));
        end
    end
end
