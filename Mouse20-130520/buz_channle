%% Extract channel data from specified time intervals
% This function extracts and concatenates data from a single channel across
% multiple time intervals. The input time intervals are converted from
% seconds to sample indices using the specified sampling frequency, and
% the corresponding channel data are concatenated into a single vector.
% The function returns the extracted channel data from all specified intervals.

function [ch] =buz_channle(T1,T2,fs,Ch)
s1=zeros(size(T1));
s1=floor(T1.*fs);
s2=zeros(size(T2));
s2=floor(T2.*fs);
for i=1:length(s1)
ll(i)=s2(i)-s1(i)+1;
end
sum_ll=sum(ll);
ch=zeros(1,sum_ll);
 ch(1,1:ll(1)) =Ch(s1(1):s2(1),1)';
for j=2:length(s1)
 ch(1,sum(ll(1:j-1))+1:ll(j)+sum(ll(1:j-1)))=Ch(s1(j):s2(j),1)';
end
end
