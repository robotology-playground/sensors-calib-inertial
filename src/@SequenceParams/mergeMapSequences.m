function seqParamsMapMerged = mergeMapSequences( obj )
%mergeMapSequences Merges all maps into macro maps (1 macro map per sequence)

% - first, init seqParamsMapMerged (empty macro maps)
seqParamsMapMerged(1,1:max(cell2mat(obj.filteredSelector.setIdx)))={containers.Map()};
% - merge sequence with next map in the list
for idx = 1:numel(obj.filteredSelector.seqParamsMap)
    % select both current sequence and next map to be merged
    sequence = seqParamsMapMerged{obj.filteredSelector.setIdx{idx}};
    seqParamsMap = obj.filteredSelector.seqParamsMap{idx};
    
    % merge in both orders:
    mergedSeqA = [sequence;seqParamsMap]; % 'seqParamsMap' elements overwrites common ones in 'sequence'
    mergedSeqB = [seqParamsMap;sequence]; % 'sequence' elements overwrites common ones in 'seqParamsMap'
    
    % list elements holding 'meas' label (potencially conflicting)
    ctrlOrMeasLabels = cellfun(@(aStruct) aStruct.labels{1},mergedSeqA.values,'UniformOutput',false);
    keys = mergedSeqA.keys;
    measElemsKeys = keys(ismember(ctrlOrMeasLabels,'meas'));
    
    % fine merge those conflicting elements
    orLogicLists = @(a,b) num2cell(cell2mat(a) | cell2mat(b),2);
    mergedValue = @(a,b) struct('labels',{a.labels},'val',{orLogicLists(a.val,b.val)});
    measElemsValues = cellfun(...
        @(key) mergedValue(mergedSeqA(key),mergedSeqB(key)),...
        measElemsKeys,...
        'UniformOutput',false);
    
    % update sequence
    seqParamsMapMerged{obj.filteredSelector.setIdx{idx}} = ...
        [mergedSeqA;containers.Map(measElemsKeys,measElemsValues)];
end

end
