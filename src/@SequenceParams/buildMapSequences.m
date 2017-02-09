function sequences = buildMapSequences(obj)
%buildMapSequences: Build sequences in the MotionSequencer format
%   - build homing sequences
%   - build the calibrating sequences 'seqParamsMap'
%   - merge all 'seqParamsMap' maps into macro maps (1 macro map per sequence)
%   - fuse homing and calibrating Map sequences
%

% Build homing sequences
seqHomeParamsMap = cellfun(...
    @(seqParams) SequenceParams.seqParams2map({},{},seqParams),...
    obj.seqHomeParams,...
    'UniformOutput',false);

seqEndParamsMap = SequenceParams.seqParams2map({},{},obj.seqEndParams);

% We index parameters by pos/part,vel/part and sensor/part keys, actually
% required for feeding the control board driver and opening the right yarp
% ports for dumping the sensor data (joints, accelerometers, gyros,
% etc...).

% ==== build the calibrating sequences 'seqParamsMap':
% Go through seqParams structures in the selector and convert each structure
% into a map (filteredSelector.seqParamsMap)
obj.filteredSelector.seqParamsMap = cellfun(...
    @(calibedPart,calibedSensors,seqParams) ...
    SequenceParams.seqParams2map(calibedPart,calibedSensors,seqParams),...
    obj.filteredSelector.calibedParts,...
    obj.filteredSelector.calibedSensors,...
    obj.filteredSelector.seqParams,...
    'UniformOutput',false);

% ==== Merge all maps into macro maps (1 macro map per sequence):
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


%% Fuse homing and calibrating Map sequences
%
%  (each homing sequence matches a calibrating sequence)

% Concatenate pairs of homing/calibrating sequences, dropping empty ones
remEmpty=@(aListOf2)...
    aListOf2([(~isempty(aListOf2{1}) && ~isempty(aListOf2{2})),~isempty(aListOf2{2})]);

sequences = cellfun(...
    @(seqParamsMap1,seqParamsMap2) remEmpty({seqParamsMap1,seqParamsMap2}),...
    seqHomeParamsMap(1:numel(seqParamsMapMerged)),seqParamsMapMerged,...
    'UniformOutput',false);
% remove encapsulation and add final Goto-end position
sequences = [sequences{:},{seqEndParamsMap}];

end
