function [y, IsBlip] = SOMolle(x)
% =========================================================================
% FUNCTION: SOMolle - Slow Oscillation (SO) Detection
% BASED ON: Mölle et al., 2011 (Sleep)
% =========================================================================
% DESCRIPTION:
% Detects Slow Oscillations in LFP data based on amplitude and duration 
% criteria. Identifies the Up state (positive peak) and Down state 
% (negative trough), ensures the voltage difference meets a threshold, 
% and validates that the total cycle duration is between 0.5 and 2 seconds.
%
% INPUTS:
%   - x: Pre-filtered (0.5 - 4 Hz) LFP signal (1D row vector or 2D matrix).
%
% OUTPUTS:
%   - y: Binary mask where 1 indicates the duration of a detected SO.
%   - IsBlip: Marker array indicating SO landmarks. 
%             (+1 = Up state peak, -1 = Down state trough).
%
% DEPENDENCIES:
%   - MATLAB Signal Processing Toolbox: findpeaks
%   - Note: Input data MUST be bandpass filtered (0.5-4 Hz) prior to 
%     calling this function, as internal filtering is disabled.
% =========================================================================

function  [y,IsBlip] = SOMolle(x)
%% This function is a Slow Oscillation detection method based on Molle et.al. 2011 paper in Sleep
% 'y' asserts when SO is detected
% 'IsBlip': +1:down blip position,   -1:up state peak position
x=x*-1;
%% Definitions
fs=1250;
minSO=0.5;             %minimum SO duration
maxSO=2;                %maximum SO duration
% C=1.25;
% Th_blip=C.*(Th_down);
% Th_dis=C.*(Th_dis);              %diffrence between down blip and up state peak voltages
Th_blip=-1.5;
Th_dis=2.5;     
%%outputs
y=zeros(size(x));
IsBlip=y;
%% filtering
[row,col]=size(x);
xfil=zeros(size(x));
% x(isnan(x))=0;
% f3db1=0.5;f3db2=4;
% for ch=1:row  
%     xfil(ch,:)=eegfilt(x(ch,:),fs,f3db1,f3db2,0,floor((fs/f3db1)*3),0,'fir1');
% %     xfil(ch,:)=eegfilt(xfil(ch,:),fs,0,f3db2,0,floor((fs/f3db2)*3),0,'fir1');
% end
xfil=x;
%% ALGO
%positive to negative zero-crossing detection
xp= xfil>0; %each '10' in 'xp' is a +to- 0-crossing
xp(:,end)=0;

for ch=1:row
    tmp= [xp(ch,:) 0]-[0 xp(ch,:)];%1:-to+  & -1:+to-
    ptn=find(tmp==-1);  %positive to negative
    xfil0=[xfil(ch,:), eps*ones(1,2*fs*maxSO)];   %xfil0 is zero! padded
    [~,blip]=findpeaks(-xfil0,'MinPeakHeight',-Th_blip(ch), 'MinPeakDistance',ceil(fs/5));
    for i=1:length(blip)-1
        vb=xfil0(blip(i));
        Th_v=(vb+Th_dis(ch))*heaviside(vb+Th_dis(ch))+eps;   %voltage threshold must be positive.
        d=xfil0(blip(i):blip(i)+fs*maxSO);
        [~,tp]=findpeaks(d,'MinPeakHeight',Th_v);
        if ~isempty(tp)   %peak exists
            peakindex=blip(i)+tp(1);  %peak index
            SOstart=find(ptn<blip(i),1,'last');     %first ptn before blip
            SOend=find(ptn>peakindex,1,'first');
            if ~isempty(SOend & SOstart) 
            for j=1
                SOlength=ptn(SOend(j))-ptn(SOstart);
                temp1=xfil0(ptn(SOstart)+2:ptn(SOend(j))-2);
                temp2=temp1<0;
                ntp=find(diff(temp2)==1,1,'first');
                if SOlength<maxSO*fs & SOlength>minSO*fs & peakindex<blip(i+1)& (ptn(SOend(j)))<blip(i+1) & isempty(ntp)                    
                   y(ch,ptn(SOstart)+2:ptn(SOend(j))-2)=1;
                   IsBlip(ch,blip(i))=1;
                   IsBlip(ch,peakindex)=-1;                   
                end
            end
            end
        end
    end
end
end
