proj = currentProject;
projFolder = proj.RootFolder;

incPath = {};
libPath = {};

cmexsfcnList = {'s_ecal_subscriber.cpp','s_ecal_publisher.cpp'};

% Search eCAL path for Windows
if isfolder(fullfile(projFolder,'_install_win'))
    ecalPath = fullfile(projFolder,'_install_win');
elseif ~isempty(getenv('ECAL_HOME'))
    ecalPath = getenv('ECAL_HOME');
else
    error('eCAL binaries for Windows not found.');
end

% Add include and libraries
incPath{end+1} = fullfile(ecalPath,'include');
libPath{end+1} = fullfile(ecalPath,'lib\ecal_core.lib');
libPath{end+1} = fullfile(ecalPath,'lib\ecal_proto.lib');

incPath = cellfun(@(path) sprintf('-I%s',path), incPath, 'UniformOutput', false);

numSfuns = length(cmexsfcnList);
for i=1:length(cmexsfcnList)
    fprintf('Builing mex file ''%s'' for S-Function %i of %i. Please wait...\n',cmexsfcnList{i},i,numSfuns);
    mex(incPath{:},libPath{:},fullfile(projFolder,'src',cmexsfcnList{i}),'-outdir',fullfile(projFolder,'bin'),'-R2018a');
end
fprintf('S-Function mex build complete.\n');