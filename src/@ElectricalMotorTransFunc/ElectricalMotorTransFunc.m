classdef ElectricalMotorTransFunc < handle
    %This class groups all the electrical motor transfer function parameters
    %   The transfer function parameters are:
    %   - name: motor name
    %   - k_pwm2i: k_{pwm,i}
    %   - k_bemf : k_{bemf}
    %   - i_offset: i_{offset}
    %   The motor current equation is:
    %   i_m = k_pwm2i * PWM + k_bemf * dq_m + i_offset
    
    properties(Constant,Access=public)
        motorName2motorID = containers.Map(...
            {'l_hip_pitch_m','l_hip_roll_m','l_hip_yaw_m','l_knee_m','l_ankle_pitch_m','l_ankle_roll_m',...
            'r_hip_pitch_m','r_hip_roll_m','r_hip_yaw_m','r_knee_m','r_ankle_pitch_m','r_ankle_roll_m',...
            'torso_yaw_m','torso_roll_m','torso_pitch_m',...
            'l_shoulder_pitch','l_shoulder_roll','l_shoulder_yaw','l_elbow',...
            'r_shoulder_pitch','r_shoulder_roll','r_shoulder_yaw','r_elbow'},...
            {'3B6M0','3B6M1','3B5M0','3B5M1','3B7M0','3B7M1',...
            '3B9M0','3B9M1','3B8M0','3B8M1','3B10M0','3B10M1',...
            '0B4M0','0B3M0','0B3M1',...
            '1B0M0','1B0M1','1B1M0','1B1M1',...
            '2B0M0','2B0M1','2B1M0','2B1M1'});
    end
    
    properties(GetAccess=public, SetAccess=protected)
        name@char;
        k_pwm2i = 0;
        k_bemf = 0;
        i_offset = 0;
        KpwmUnits@char;
        KbemfUnits@char;
        offsetUnits@char;
    end
    
    methods(Access=protected)
        % Constructor
        function obj = ElectricalMotorTransFunc(motorName,KpwmUnits,KbemfUnits,offsetUnits)
            obj.name = motorName;
            if nargin == 4
                obj.KpwmUnits = KpwmUnits;
                obj.KbemfUnits = KbemfUnits;
                obj.offsetUnits = offsetUnits;
            else
                obj.KpwmUnits = '\frac{A}{dutycycle}';
                obj.KbemfUnits = '\frac{A}{rad \cdot s^{-1}}';
                obj.offsetUnits = 'A';
            end
        end
    end
    
    methods(Static=true, Access=public)
        function transFunc = GetMotorTransFunc(motorName,calibrationMap)
            if ~isKey(calibrationMap,motorName)
                calibrationMap(motorName) = ElectricalMotorTransFunc(motorName);
            end
            % Return the handle on the newly created or already existing
            % ElectricalMotorTransFunc object.
            transFunc = calibrationMap(motorName);
        end
        
        function isEq = eq(aTransFunc,anotherTransFunc)
            isEq = true;
            for field = fieldnames(aTransFunc)'
                if ischar(aTransFunc.(field{1}))
                    isEq = isEq && strcmp(aTransFunc.(field{1}),anotherTransFunc.(field{1}));
                elseif isnumeric(aTransFunc.(field{1}))
                    isEq = isEq && aTransFunc.(field{1}) == anotherTransFunc.(field{1});
                end
            end
        end
        
        function printFullCalibMap(calibrationMap,part)
            switch part
                case 'left_leg'
                    keyList = {'l_hip_pitch_m','l_hip_roll_m','l_hip_yaw_m','l_knee_m','l_ankle_pitch_m','l_ankle_roll_m'};
                case 'right_leg'
                    keyList = {'r_hip_pitch_m','r_hip_roll_m','r_hip_yaw_m','r_knee_m','r_ankle_pitch_m','r_ankle_roll_m'};
                case 'torso'
                    keyList = {'torso_yaw_m','torso_roll_m','torso_pitch_m'};
                case 'left_arm'
                    keyList = {'l_shoulder_pitch','l_shoulder_roll','l_shoulder_yaw','l_elbow'};
                case 'right_arm'
                    keyList = {'r_shoulder_pitch','r_shoulder_roll','r_shoulder_yaw','r_elbow'};
                otherwise
            end
            
            includeHeader = true;
            composedString = ''; composedValues = '';
            
            for calibElem = calibrationMap.values(keyList)
                [elemString,values] = calibElem{:}.print1(includeHeader);
                composedString = [composedString elemString];
                composedValues = [composedValues values];
                if includeHeader, includeHeader=false; end
            end
            
            sprintf(composedString,composedValues{:})
        end
        
        function  setUnits(calibrationMap)
            for elem = calibrationMap.values
                elem{:}.KpwmUnits = '\frac{A}{dutycycle}';
                elem{:}.KbemfUnits = '\frac{A}{rad \cdot s^{-1}}';
                elem{:}.offsetUnits = 'A';
            end
        end
    end
    
    methods(Access=public)
        function setKpwm2i(obj,k_pwm2i), obj.k_pwm2i = k_pwm2i; end
        
        function setKbemf(obj, k_bemf), obj.k_bemf = k_bemf; end
        
        function setIoffset(obj,i_offset), obj.i_offset = i_offset; end
        
        function convertFromOldFormat(obj)
            obj.k_pwm2i = obj.Kpwm;
            obj.k_bemf = obj.Kbemf;
            obj.i_offset = obj.offset;
        end
        function copyObj = copy(obj)
            copyObj = ElectricalMotorTransFunc(obj.name);
            copyObj.Kpwm = obj.Kpwm;
            copyObj.Kbemf = obj.Kbemf;
            copyObj.offset = obj.offset;
        end
        
        % Print the parameters of a single motor following the format 1:
        % | motor | $k_{PWM}\ [\frac{A}{dutycycle}] $ | $k_{bemf}\ [\frac{A}{rad \cdot s^{-1}}]$ |  $ i_{offset}\ [A] $ |
        % | <motor-name> | <x.xxxx> |  <x.xxxx> | <x.xxxx> |
        function [aString,values] = print1(obj,includeHeader)
            if includeHeader
                aString = [...
                    '| joint | motor | $k_{PWM}\\ [', strrep(obj.KpwmUnits,'\','\\'), ...
                    ']$ | $k_{bemf}\\ [', strrep(obj.KbemfUnits,'\','\\'), ...
                    ']$ |  $i_{offset}\\ [', strrep(obj.offsetUnits,'\','\\'), ']$ |\n',...
                    '| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |\n'];
            else
                aString = '';
            end
            aString = [aString ' | `' strrep(obj.name,'_m','') '` | `' ElectricalMotorTransFunc.motorName2motorID(obj.name) '` | %0.4f | %0.4f | %0.4f |\n'];
            values = {obj.Kpwm,obj.Kbemf,obj.offset};
        end
    end
    
end
