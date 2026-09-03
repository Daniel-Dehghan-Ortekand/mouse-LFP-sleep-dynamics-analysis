%% Reference spindle channel identification
% This function identifies the spindle reference channel corresponding to a
% given thalamic recording channel. The 64 recording channels are divided
% into eight shanks, with eight channels assigned to each shank. The function
% returns the spindle reference channel associated with the shank containing
% the specified reference channel and generates an error for invalid channel
% indices.

function refSpindleCh = getRefSpindleChannel(ref)

if (1 <= ref) && (ref)<= 8
        refSpindleCh = 1;
elseif (8 < ref) && (ref)<= 16
        refSpindleCh = 2;
elseif (16 < ref) && (ref)<= 24
        refSpindleCh = 3;
elseif (24 < ref) && (ref)<= 32
        refSpindleCh = 4;
elseif (32 < ref) && (ref)<= 40
        refSpindleCh = 5;
elseif (40 < ref) && (ref)<= 48
        refSpindleCh =6;
elseif (48 < ref) && (ref)<= 56
        refSpindleCh = 7;
elseif (56 < ref) && (ref)<= 64 %size(thal_ch_norm_filteredTemp(:,1), 1)
        refSpindleCh =8;
else
        error('Invalid referencChannel value.')
end

end
