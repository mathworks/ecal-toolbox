function buildSFun(ecalPath)

arguments
    ecalPath {mustBeFolder} = {};
end

proj = currentProject;
projFolder = proj.RootFolder;

incPath = {};
libPath = {};

cmexsfcnList = {'s_ecal_subscriber.cpp','s_ecal_publisher.cpp'};

% Search eCAL path for Windows
if isfolder(ecalPath)
    if ~isfolder(fullfile(ecalPath,'include')) || ~isfolder(fullfile(ecalPath,'lib'))
        error('Required folders ''include'' and ''lib'' were not found in %s.',ecalPath);
    end
elseif ~isempty(getenv('ECAL_HOME'))
    ecalPath = getenv('ECAL_HOME');
else
    error('eCAL binaries were not found in the current system. Please install eCAL on this system and add it to the path or call buildSFun(<pathToEcal>).');
end

% Get file extension
if ismac
    libExt = '.a';
elseif isunix
    libExt = '.a';
elseif ispc
    libExt = '.lib';
else
    error('Platform not supported');
end

% Add include and libraries
incPath{end+1} = fullfile(ecalPath,'include');
libPath{end+1} = fullfile(ecalPath,['lib\ecal_core',libExt]);
libPath{end+1} = fullfile(ecalPath,['lib\ecal_proto',libExt]);

incPath = cellfun(@(path) sprintf('-I%s',path), incPath, 'UniformOutput', false);

numSfuns = length(cmexsfcnList);
for i=1:length(cmexsfcnList)
    fprintf('Builing mex file ''%s'' for S-Function %i of %i. Please wait...\n',cmexsfcnList{i},i,numSfuns);
    mex(incPath{:},libPath{:},fullfile(projFolder,'src',cmexsfcnList{i}),'-outdir',fullfile(projFolder,'bin'),'-R2018a');
end
fprintf('S-Function mex build complete.\n');

end