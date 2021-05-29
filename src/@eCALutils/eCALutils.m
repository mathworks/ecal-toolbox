classdef eCALutils < handle
    %eCALutils eCAL Utilities for Simulink Real-Time
    %
    %   eCALutils(eCAL_QNX_libs_path, SLRT_target_object)
    %
    %   Example:
    %       ecalObj = eCALutils;
    %       ecalObj = eCALutils('C:\eCAL_libs');
    %       ecalObj = eCALutils('C:\eCAL_libs',tg);
    
    properties
        % Path where eCAL libraries for QNX are located
        eCALLibsPath
        
        % Target object where libraries shall be installed
        TgObject
    end
    
    properties (Constant)
        % Path in target where libraries will be installed
        DestLibs = '/usr/lib/'
        
        % Multicast IP on target
        MulticastIP = '239.0.0.0';
    end
    
    properties (Constant, Access = private)
        LibFilenames = {'libecal_core.so','libecal_core_c.so','libprotobuf.so','libprotobuf-lite.so',...
            'libecaltime-localtime.so','libecaltime-simtime.so'}
    end
    
    properties (Dependent, SetAccess = protected)
        % Detailed list of library files on the host that will be installed on the target
        ListECALLibFiles
        
        % Status of multicast interface for QNX
        MulticastStatus
        
        % Is eCAL installed on the target
        iseCALinstalled
        
        % Status of running state of PTP Daemon on the target
        isPTPDrunning
        
        % State PTP Daemon AutoStart on the target
        isPTPDAutoStart
    end
    
    properties (Hidden, Dependent, SetAccess = protected)
        % List of patched Fast-RTPS library files
        listPatchFastRTPSLibs
    end
    
    properties (SetAccess = immutable)
        % Project root folder
        rootFolder
    end
    
    properties (Hidden, Access = protected)
        % Root SSH Object
        rootssh
    end
    
    methods
        
        % Constructor
        function obj = eCALutils(path, tgObj)
            
            % Initialize target object
            if ~isempty(ver('slrealtime'))
                obj.TgObject = slrealtime();
            else
                error('This class is to manage eCAL operation with Simulink Real-Time, which is not present in this MATLAB installation.');
            end
            
            % Get project root folder
            projObj = currentProject;
            obj.rootFolder = projObj.RootFolder;
            
            % Validate function inputs
            if nargin>0
                obj.eCALLibsPath = path;
            elseif isfolder(fullfile(obj.rootFolder,'_install_qnx'))
                obj.eCALLibsPath = fullfile(obj.rootFolder,'_install_qnx');
            else
                warning('Default location for eCAL Libraries for QNX was not found. Please consider running buildeCALlibs4QNX.');
            end
            if nargin>1
                obj.TgObject = tgObj;
            end
            
            % Initialize SSH root object
            if obj.TgObject.isConnected
                obj.rootssh = getSSHObjRoot(obj);
            else
                disp('No target is connected. After switching it on, please create this object again.');
            end
            
        end
        
        % Set and get methods
        function set.eCALLibsPath(obj, path)
            if ~isfolder(path)
                path = uigetdir(pwd,'Select the folder where the eCAL libs for the Speedgoat are located');
                if path == 0
                    error('User selected cancel.');
                end
            end
            
            obj.eCALLibsPath = path;
        end
        
        function set.TgObject(obj, tgObj)
            validateattributes(tgObj,'slrealtime.Target',{'scalar'});
            obj.TgObject = tgObj;
        end
        
        function listLibFiles = get.ListECALLibFiles(obj)
            listLibFiles = [];
            if ~isempty(obj.eCALLibsPath)
                allFiles = dir(fullfile(obj.eCALLibsPath,'**/*.so*'));
                
                listLibFiles = allFiles(contains({allFiles.name},obj.LibFilenames));
                
                if isempty(listLibFiles)
                    warning('No eCAL libraries were found in %s.',obj.eCALLibsPath);
                end
            end
        end
        
        function multicastStatus = get.MulticastStatus(obj)
            if obj.TgObject.isConnected
                res = obj.TgObject.executeCommand('route show');
                multicastStatus = contains(res.Output,obj.MulticastIP);
            end
        end
        
        function iseCALinstalled = get.iseCALinstalled(obj)
            if obj.TgObject.isConnected
                listLibs = obj.TgObject.executeCommand(['ls ',obj.DestLibs]);
                iseCALinstalled = all(cellfun(@(lib) contains(listLibs.Output, lib), obj.LibFilenames));
                
                if ~iseCALinstalled
                    warning('eCAL Libraries were not found on the target. Please run installLibsOnSpeedgoat.');
                end
            end
        end
        
        function isPTPDrunning = get.isPTPDrunning(obj)
            if obj.TgObject.isConnected
                statusPtpd = obj.TgObject.ptpd.status;
                isPTPDrunning = statusPtpd.Running;
            end
        end
        
        function isPTPDAutoStart = get.isPTPDAutoStart(obj)
            if obj.TgObject.isConnected
                isPTPDAutoStart = obj.TgObject.ptpd.AutoStart;
            end
        end
                
        function listPatchFastRTPSLibs = get.listPatchFastRTPSLibs(obj)
            if verLessThan('slrealtime','7.1')
                patchVersion = 'v1';
            elseif verLessThan('slrealtime','7.3')
                patchVersion = 'v2';
            else
                patchVersion = '';
            end
            
            if ~isempty(patchVersion)
                listPatchFastRTPSLibs = dir(fullfile(obj.rootFolder,'libs',patchVersion,'**/*.so*'));
            else
                listPatchFastRTPSLibs = {};
            end
        end
        
        % Main methods
        function selectECALLibsPath(obj)
            obj.eCALLibsPath = '';
        end
        
        function installLibsOnSpeedgoat(obj, options)
            arguments
                obj
                options.force (1,1) logical = false
            end
            if ~obj.iseCALinstalled || options.force
                if isempty(obj.eCALLibsPath)
                    obj.eCALLibsPath = '';
                end
                if ~isempty(obj.ListECALLibFiles)
                    disp('Installing eCAL libraries on the target. Please wait...');
                    numLibFiles = numel(obj.ListECALLibFiles);
                    for i = 1:numLibFiles
                        fprintf('Copying file %s (%i of %i)...\n',obj.ListECALLibFiles(i).name,i,numLibFiles);
                        obj.copyFileToTarget(fullfile(obj.ListECALLibFiles(i).folder,obj.ListECALLibFiles(i).name),...
                            [obj.DestLibs,obj.ListECALLibFiles(i).name]);                        
                    end
                    fprintf('eCAL libraries successfully installed on the target.\n');
                else
                    error('eCAL Library files could not be found in %s.',obj.eCALLibsPath);
                end
            else
                disp('eCAL is already installed on the target. Run this command with "''force'',true" argument to reinstall the libraries.');
            end
        end
        
        function setMulticast4ECAL(obj)
            if ~obj.MulticastStatus                
                obj.TgObject.executeCommand(sprintf('route add -net %s -netmask 255.255.255.0 -iface %s -mtu 1000',...
                    obj.MulticastIP,obj.TgObject.TargetSettings.address), obj.rootssh);
            end
        end
        
        function startPTPDOnSpeedgoat(obj)
            obj.TgObject.ptpd.start;
        end
        
        function stopPTPDOnSpeedgoat(obj)
            obj.TgObject.ptpd.stop;
        end
        
        function togglePTPDAutoStart(obj)
            if obj.isPTPDAutoStart
                obj.TgObject.ptpd.AutoStart = false();
            elseif ~obj.isPTPDAutoStart
                obj.TgObject.ptpd.AutoStart = true();
            else
                error('Error reading isPTPDAutoStart.');
            end
        end
        
        function patchFastRTPSLibs(obj)
            if ~isempty(obj.ListECALLibFiles)
                obj.TgObject.executeCommand('rm /usr/local/lib/libfast*', obj.rootssh);
                for i = 1:numel(obj.ListECALLibFiles)
                    obj.copyFileToTarget(fullfile(obj.ListECALLibFiles(i).folder,obj.ListECALLibFiles(i).name),...
                        ['/usr/local/lib/',obj.ListECALLibFiles(i).name]);
                end
            else
                disp('Patch Fast-RTPS libraries is not required for this SLRT version.');
            end
        end
        
        function buildeCALlibs4QNX(obj, options)
            arguments
                obj
                options.force (1,1) logical = false
            end
            
            buildFolder = fullfile(obj.rootFolder,'_build_qnx');
            if isfolder(buildFolder)
                if options.force
                    rmdir(buildFolder,'s');
                else
                    fprintf('Build folder exists at %s. Please run buildeCALlibs4QNX(true) if you want to force a clean build.\n',buildFolder);
                    return;
                end
            end
            
            cd(fullfile(obj.rootFolder,'buildtools'));
            status = system('buildeCALlibs4QNX.cmd','-echo');
            if status ~= 0
                error('Error building eCAL libraries for QNX.');
            end
            cd('..');
        end
        
    end
    
    methods (Access = private)
        
        rootssh = getSSHObjRoot(obj)
        
        function copyFileToTarget(obj, hostFullfileName, destFullFileName)

            obj.rootssh.scpSend(hostFullfileName, destFullFileName);
            try
                res = obj.rootssh.waitForResult( );
            catch ME
                throw(ME);
            end
            
            if ~isfield(res,'ExitCode') || res.ExitCode ~= 0
                error('Failed to send file! %s',res.ErrorMessage);
            end
        end
        
        
    end
end

