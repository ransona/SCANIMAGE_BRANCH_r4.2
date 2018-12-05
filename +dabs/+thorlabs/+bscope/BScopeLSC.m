classdef BScopeLSC < dabs.interfaces.LinearStageController
    
    %% ABSTRACT PROPERTY REALIZATION (dabs.interfaces.LinearStageController)
    properties (Constant,Hidden)
        nonblockingMoveCompletedDetectionStrategy = 'poll'; % Either 'callback' or 'poll'
        %UnitCoef = {256,256,256,-237281}; %steps to um conversion factors
        %UnitCoefQei = {20,20,100,-8730};  %encoder to um conversion factors
        %UnitCoefVel = 2.5*10^-7/2^-18;
        %UnitCoefAccel = 6.25*10^-14/2^-40;
        UNIT_UM2MM = 0.001;
        UNIT_MM2UM = 1000;        
    end 
 
    properties (SetAccess=protected,Dependent)
        isMoving;
        isError;
    end
    
    properties (SetAccess=protected,Dependent,Hidden)
        invertCoordinatesRaw;       %not defined
        positionAbsoluteRaw; 
        velocityRaw;
        accelerationRaw;
		maxVelocityRaw;            
    end
    
    properties (SetAccess=protected,Hidden)
        resolutionRaw = 1;
    end

    properties (SetAccess=protected)
        infoHardware = 'Thorlabs BScope v0.0'; %String providing information about the hardware, e.g. firmware version, manufacture date, etc. Information provided is specific to each device type.
    end
    
    properties (SetAccess=protected,Hidden)
        positionDeviceUnits = 1e-6; %Units, in meters, in which the device's position values (as reported by positionAbsoluteRaw) are given
        velocityDeviceUnits = 1e-6; %Units, in meters/sec, in which the device's velocity values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.
        accelerationDeviceUnits = 1e-6; %Units, in meters/sec^2, in which the device's acceleration values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.         
    end
      
    %% DEVELOPER PROPERTIES
    properties (Hidden,SetAccess=protected)
        LocalPos;           %unit: mm, (ThorBScope.dll required)
        LocalPosCurrent;    %unit: mm, (ThorBScope.dll required)
        LocalPosHome;
        LocalVel;
        LocalAccel;
        LocalStop;
        LocalVelCurrent;
        DllPathName;        
    end
    
    %%  DEVELOPER PROPERTIES, CPP interface dataset:
    properties (Hidden,SetAccess=protected)
        BScopeData;
        CppClass;
        numDevice;
    end
    
    %%  Static method: locate .dll library.
    methods (Static = true)
        function DllPathName = SetDllPathName(fileName,suprPkg,sysID)
            if sysID == 1       % windows x86
                apndStr = '\x86';
            elseif sysID == 2   % windows x64
                apndStr = '\x64';
            else
                error('Please specify (1)x86 or (2)x64');
            end
            % locate and return the path of the filename 
            % eg.> DllPathName = SetDllPathName('ThorBScope.dll','+dabs\+thorlabs\+BScope',1);
            % Check if local sub-directory has the dll:
            subD = dabs.thorlabs.bscope.subdir(fileName);
            if isempty(subD)
                % If not finding the file, start from its super package:
                supr = what(suprPkg);
                if isempty(supr)
                    error('Your super package is not available...');
                else        
                    for idx = 1:length(supr)
                        tmp = [supr(idx).path apndStr '\' fileName];
                        %subD = dabs.thorlabs.BScope.subdir(fileName);
                        tmpFlg = exist(tmp,'file');
                        if (tmpFlg~=0)
                            DllPathName=tmp(1:find(tmp=='\', 1, 'last' ));
                            break;
                        else
                            continue;
                        end
                    end
                end
            else
                tmp2=subD.name;
                DllPathName=tmp2(1:find(tmp2=='\', 1, 'last' ));
            end
        end
    end
    
    %% CTOR/DTOR
    methods
        function obj = BScopeLSC(varargin)
            %import dabs.thorlabs.BScope.*
            
            pvArgs = most.util.filterPVArgs(varargin,{'numDeviceDimensions'});
            if isempty(pvArgs)
                pvArgs = {'stageType','bscope','comport',3,'availableBaudRates',9600, 'standardBaudRate',9600,'numDeviceDimensions',3};
            end

            obj = obj@dabs.interfaces.LinearStageController(pvArgs{:}); 
            %obj.numDeviceDimensions=4; % X, Y, Z, R
            % Load dll:
            CurrentPath=pwd;
            %obj.DllPathName = uigetdir('Select directory for ThorBScope.dll');
            str=computer;
            if (strcmp(str,'PCWIN'))
                obj.DllPathName = dabs.thorlabs.bscope.BScopeLSC.SetDllPathName('ThorBScope.dll','+dabs\+thorlabs\+bscope',1);   
            elseif (strcmp(str,'PCWIN64'))
                obj.DllPathName = dabs.thorlabs.bscope.BScopeLSC.SetDllPathName('ThorBScope.dll','+dabs\+thorlabs\+bscope',2);
            end
            cd(obj.DllPathName);
            %obj.BScopeData = BScope();   %obj.CppClass = Cpp_interface();
            obj.BScopeData = dabs.thorlabs.bscope.BScope();
            obj.CppClass = dabs.thorlabs.bscope.Cpp_interface();            
            assert(loadlib(obj.CppClass,'ThorBScope')==1,'DLL library is not loaded!\n')
            % Verify device found:
            assert(loadfunc(obj.CppClass,'FindDevices')==1,'Devices are not found!\n')
            obj.numDevice = get(obj.CppClass,'DeviceCount');
            %assert(obj.numDevice==1,'Number of devices not 1.\n')
            assert(loadfunc(obj.CppClass,'SelectDevice',0)==1,'Devices are not selected!\n')             
            obj.LocalPos = {obj.BScopeData.Params.PARAM_X_POS,obj.BScopeData.Params.PARAM_Y_POS,obj.BScopeData.Params.PARAM_Z_POS};%,obj.BScopeData.Params.PARAM_R_POS};
            obj.LocalPosHome = {obj.BScopeData.Params.PARAM_X_HOME,obj.BScopeData.Params.PARAM_Y_HOME,obj.BScopeData.Params.PARAM_Z_HOME};%,obj.BScopeData.Params.PARAM_R_HOME};
            obj.LocalPosCurrent = {obj.BScopeData.Params.PARAM_X_POS_CURRENT,obj.BScopeData.Params.PARAM_Y_POS_CURRENT,obj.BScopeData.Params.PARAM_Z_POS_CURRENT};%,obj.BScopeData.Params.PARAM_R_POS_CURRENT};
            obj.LocalVel = {obj.BScopeData.Params.PARAM_X_VELOCITY,obj.BScopeData.Params.PARAM_Y_VELOCITY,obj.BScopeData.Params.PARAM_Z_VELOCITY};%,obj.BScopeData.Params.PARAM_R_VELOCITY};
            obj.LocalVelCurrent = {obj.BScopeData.Params.PARAM_X_VELOCITY_CURRENT,obj.BScopeData.Params.PARAM_Y_VELOCITY_CURRENT,obj.BScopeData.Params.PARAM_Z_VELOCITY_CURRENT};%,obj.BScopeData.Params.PARAM_R_VELOCITY_CURRENT};
            obj.LocalAccel = {obj.BScopeData.Params.PARAM_X_ACCEL,obj.BScopeData.Params.PARAM_Y_ACCEL,obj.BScopeData.Params.PARAM_Z_ACCEL};%,obj.BScopeData.Params.PARAM_R_ACCEL};
            obj.LocalStop = {obj.BScopeData.Params.PARAM_X_STOP,obj.BScopeData.Params.PARAM_Y_STOP,obj.BScopeData.Params.PARAM_Z_STOP};%,obj.BScopeData.Params.PARAM_R_STOP};
            cd(CurrentPath);
        end
        
        function delete(obj)
            %assert(get(obj.CppClass,'loadlib')==1,'DLL library is not loaded!\n')
            CurrentPath=pwd;
            cd(obj.DllPathName);
            assert(loadfunc(obj.CppClass,'TeardownDevice')==1,'Unable to tear down device.\n')
            freelib(obj.CppClass);
            delete(obj.CppClass);
            obj.BScopeData=[];% obj.CppClass 
            obj.numDevice=0; 
            cd(CurrentPath);
        end    
    end    
    
    %% PROPERTY ACCESS
    methods   
        %Position: get/set
        function pos = get.positionAbsoluteRaw(obj)
            for idx=1:(obj.numDimensions)
                RegetParam(obj,obj.LocalPosCurrent{idx});
                pos(idx) = obj.BScopeData.param*obj.UNIT_MM2UM;    %unit from dll: mm, display in um
            end            
        end 
        % Set Position to allow moveStartHook to execute:
        function setPositionAbsolute(obj,posn)  
            %error(nargchk(1,4,length(varagin)));   %when input with cell arrays
            %emptyCells = cellfun(@isnan,posn);
            emptyPos = isnan(posn);
            for idx=1:length(posn)
                if emptyPos(idx)==0
                    loadfunc(obj.CppClass,'SetParam',obj.LocalPos{idx},posn(idx));
                end
            end
        end
        %maxVelocity: get/set
        function V = get.maxVelocityRaw(obj)
            for idx=1:(obj.numDimensions)
                RegetParam(obj,obj.LocalVel{idx});
                V(idx) = obj.BScopeData.param;      %val units: steps/s
            end            
        end        
        function set.maxVelocityRaw(obj,vel)
            %error(nargchk(1,4,length(vel)));
            %emptyCells = cellfun(@isnan,vel);
            emptyVel = isnan(vel);
            for idx=1:length(vel)
                if emptyVel(idx)==0
                    %vel(idx)=vel(idx)*obj.UnitCoefVel;
                    loadfunc(obj.CppClass,'SetParam',obj.LocalVel{idx},vel(idx));
                end
            end   
        end  
        %Velocity: get
        function V = get.velocityRaw(obj)
            for idx=1:(obj.numDimensions)
                RegetParam(obj,obj.LocalVelCurrent{idx});
                V(idx) = obj.BScopeData.param;      %val units: steps/s
            end            
        end      
        %Acceleration: get/set  
        function A = get.accelerationRaw(obj)
            for idx=1:(obj.numDimensions)
                RegetParam(obj,obj.LocalAccel{idx});
                A(idx) = obj.BScopeData.param;     %val units: steps/s
            end       
        end
        function set.accelerationRaw(obj,accel)
           %error(nargchk(1,4,length(varagin)));
           %emptyCells = cellfun(@isnan,varagin);
           emptyAccel = isnan(accel);
           for idx=1:length(accel)
               if emptyAccel(idx)==0
                   loadfunc(obj.CppClass,'SetParam',obj.LocalAccel{idx},accel(idx));
               end
           end
        end
        
        function val = get.resolutionRaw(obj)
            val = obj.resolutionRaw;
        end
        
        function val = get.isMoving(obj)
            statusNow = CheckStatus(obj);
            if (statusNow == obj.BScopeData.StatusType.STATUS_BUSY)
                val=1;
            else
                val=0;
            end
        end  
        
        function val = get.isError(obj)
            statusNow = CheckStatus(obj);
            if (statusNow == obj.BScopeData.StatusType.STATUS_ERROR)
                val=1;
            else
                val=0;
            end
        end
    end
    
    %% ABSTRACT METHOD IMPLEMENTATIONS
    methods (Access=protected,Hidden)
        
        function moveStartHook(obj,targetPosn)            % Scanimage unit: um, for targetPosn          
            loadfunc(obj.CppClass,'PreflightPosition');
            targetPosn = targetPosn*obj.UNIT_UM2MM;       % .dll takes unit: mm, convert um before send in
            setPositionAbsolute(obj,targetPosn);            
            ExecuteCmd(obj);
            loadfunc(obj.CppClass,'PostflightPosition');
        end    
        
        function interruptMoveHook(obj)
            if (obj.isMoving)
                for idx=1:(obj.numDimensions)
                    loadfunc(obj.CppClass,'SetParam',obj.LocalStop{idx},1);
                end  
                ExecuteCmd(obj);
            end
        end           
        
        function recoverHook(obj)
            numTries = 15;
            for i = 1:numTries
                try
                    obj.interruptMoveHook();                    
                catch    %#ok<CTCH>
                    if i < numTries
                        continue;
                    else
                        throwAsCaller(obj.DException('','RecoverFailed','Recover operation for device of type %s FAILED',class(obj)));
                    end
                end
                break;
            end
        end
        
        function resetHook(obj)
            return;
        end
        
        function zeroHardHook(obj,coords)
            assert(all(coords),'Cannot hard-zero individual coordinates.');
            loadfunc(obj.CppClass,'PreflightPosition');
            setPositionAbsolute(obj,[0 0 0]); 
            ExecuteCmd(obj);
            loadfunc(obj.CppClass,'PostflightPosition');
        end    
    
    end    
    
    %% DEVELOPER METHODS

    %% CPP interface & other private METHODS

    methods (Access=private)
        function RegetParamInfo(obj,paramID)
            % Reset BScopeData's 6x params based on paramID
            loadfunc(obj.CppClass,'GetParamInfo',paramID);
            [obj.BScopeData.paramType obj.BScopeData.paramAvailable obj.BScopeData.paramReadOnly obj.BScopeData.paramMin obj.BScopeData.paramMax obj.BScopeData.paramDefault]=get(obj.CppClass,'paramType','paramAvailable','paramReadOnly','paramMin','paramMax','paramDefault');
        end      
        function RegetParam(obj,paramID)
            % Reset BScopeData's param based on paramID
            loadfunc(obj.CppClass,'GetParam',paramID);
            [obj.BScopeData.param]=get(obj.CppClass,'param');
        end 
        function ExecuteCmd(obj)
            loadfunc(obj.CppClass,'SetupPosition');            
            loadfunc(obj.CppClass,'StartPosition');            
        end
        function statusNow = CheckStatus(obj)
            loadfunc(obj.CppClass,'StatusPosition');
            statusNow = get(obj.CppClass,'status');
        end
    end
end 