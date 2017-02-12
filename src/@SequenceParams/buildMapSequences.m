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
seqParamsMapMerged = obj.mergeMapSequences();

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
