function ShankID = getShankID(ref)
% =========================================================================
% FUNCTION: getShankID - Map Channel Index to Probe Shank ID
% =========================================================================
% DESCRIPTION:
% Determines the physical shank ID (1-8) for a given channel index (1-64) 
% on a multi-shank silicon probe. Assumes a configuration of 8 channels 
% per shank (e.g., channels 1-8 = Shank 1, channels 9-16 = Shank 2, etc.).
%
% INPUTS:
%   - ref : Channel index or array of channel indices (1 to 64).
%
% OUTPUTS:
%   - ShankID : Corresponding shank ID (1 to 8).
% =========================================================================


switch true
    case (1 <= ref) && (ref)<= 8
        ShankID = 1;
    case (8 < ref) && (ref)<= 16
        ShankID = 2;
    case (16 < ref) && (ref)<= 24
        ShankID = 3;
    case (24 < ref) && (ref)<= 32
        ShankID = 4;
    case (32 < ref) && (ref)<= 40
        ShankID = 5;
    case (40 < ref) && (ref)<= 48
        ShankID = 6;
    case (48 < ref) && (ref)<= 56
        ShankID = 7;
    case (56 < ref) && (ref)<= 64
        ShankID = 8;
    otherwise
        error('Invalid referencChannel value.')
end

end
