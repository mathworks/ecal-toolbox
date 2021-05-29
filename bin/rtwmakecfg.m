function makeInfo = rtwmakecfg

proj = currentProject;
rootPath = proj.RootFolder;

sysTarget = get_param(bdroot, 'RTWSystemTargetFile');

ecalLibraryFiles = {'ecal_core.','ecal_core_c.','protobuf.','protobuf-lite.'};

makeInfo.sourcePath	= fullfile(rootPath,'src');
makeInfo.sources = {'s_ecal_common.cpp'};

switch sysTarget
    case 'slrealtime.tlc'
        makeInfo.includePath = fullfile(rootPath,'_install_qnx/include');
        makeInfo.linkLibsObjs = findFilesInDir(fullfile(rootPath,'_install_qnx','lib'),ecalLibraryFiles);
    otherwise
        ECAL_HOME = getenv('ECAL_HOME');
        if ~isempty(ECAL_HOME)
            disp('Building application with standard eCAL libs for this system.');
            
            makeInfo.includePath = fullfile(ECAL_HOME,'include');
            makeInfo.linkLibsObjs = findFilesInDir(fullfile(ECAL_HOME,'lib'),ecalLibraryFiles);
        else
            error('No eCAL libraries defined or found for %s.',sysTarget);
        end
end

end

function filepaths = findFilesInDir(path, filenames)

allFiles = dir(path);
filepaths = allFiles(contains({allFiles.name},filenames));
filepaths = fullfile({filepaths.folder},{filepaths.name});

end