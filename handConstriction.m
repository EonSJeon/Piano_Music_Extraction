

function correctedNotes = handConstriction(notesAtTheMoment, N, handSize)
    % Number of active notes
    numActiveNotes = sum(notesAtTheMoment > 0);
    
    if numActiveNotes > N
        % Find the indices of the top N highest values
        [~, indices] = maxk(notesAtTheMoment, N);
        
        % Create a new array with zeros
        correctedNotes = zeros(size(notesAtTheMoment));
        
        % Set the top N highest notes in the new array
        correctedNotes(indices) = notesAtTheMoment(indices);
    else
        correctedNotes = notesAtTheMoment;
    end

    % Identify active indices
    activeIndices = find(correctedNotes > 0);
    if ~isempty(activeIndices)
        % Check spread and hand constraints
        if max(activeIndices) - min(activeIndices) + 1 > handSize * 2
            % If the span of notes is too wide, further constrain
            while max(activeIndices) - min(activeIndices) + 1 > handSize * 2 && length(activeIndices) > 1
                % Reduce notes from the ends based on which end is higher
                if correctedNotes(activeIndices(1)) < correctedNotes(activeIndices(end))
                    correctedNotes(activeIndices(1)) = 0;
                else
                    correctedNotes(activeIndices(end)) = 0;
                end
                activeIndices = find(correctedNotes > 0);  % Update active indices
            end
        end
    end
end


% % Sort the indices of the active notes
%     sortedIdx = sort(find(correctedNotes > 0));
% 
%     % If there are no active notes, return empty correctedNotes
%     if isempty(sortedIdx)
%         return;
%     end
% 
%     sortedIdx=sort(find(correctedNotes>0));
%     maxIdx=sortedIdx(end);
%     minIdx=sortedIdx(1);
%     valid =true;
% 
%     for idx = sortedIdx
%         if ~(idx>maxIdx-handSize || idx<minIdx+handSize)
%             valid=false;
%             break;
%         end
%     end
% 
%     if ~valid
% 
%         % Identify active indices
%         activeIndices = find(correctedNotes > 0);
%         if ~isempty(activeIndices)
%            % all index should be covered with two hands.
%             % the indexes should be able to split into two chunks but with each chunk max-min <handSize 
%             % select the indexs so that minimum indexes are discarded.
%             adjustActiveIndices = activeIndices - min(activeIndices)+1;
%             count= zeros(length(adjustActiveIndices), max(adjustActiveIndices)+handSize);
%             for i = 1:length(adjustActiveIndices)
%                 count(i,adjustActiveIndices(i):adjustActiveIndices(i)+handSize-1) = 1;
%             end
%             resCount = sum(count,1)
%             maxLocs = find(resCount==max(resCount));
%             firstHandIdx=find(count(:,maxLocs(1))>0)+min(activeIndices);
%             resCount(maxLocs(1):maxLocs(end)+handSize)=0;
%             maxLocs = find(resCount==max(resCount));
%             secondHandIdx=find(count(:,maxLocs(1))>0)+min(activeIndices);
% 
%             correctedNotes = zeros(size(notesAtTheMoment));
%             correctedNotes(firstHandIdx)=1;
%             correctedNotes(secondHandIdx)=1;
%         end
%     end