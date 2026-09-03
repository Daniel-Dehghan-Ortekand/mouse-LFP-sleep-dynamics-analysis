% =========================================================================
% SCRIPT: Statistical Comparison of Global vs. Local Sleep Spindle Properties
% SUBJECT: Mouse12-120806
% =========================================================================
% DESCRIPTION:
% Performs a comprehensive statistical comparison between "Global" and 
% "Local" sleep spindles during Slow-Wave Sleep (SWS). Extracts key 
% spindle properties—including peak amplitude, duration, population 
% firing rate, and single-cell Modulation Index (MI). Conducts t-tests 
% to evaluate significant differences between the two groups and 
% visualizes the distributions using overlaid histograms and box plots.
%
% INPUTS:
%   - sepratedSpindles120806.mat: Classified Global and Local spindle 
%     events and their corresponding peak amplitudes.
%   - real_peaks[X].mat: Peak amplitude data for the reference channel.
%   - FiringrateSpindles.mat: Population firing rates time-locked to 
%     Global and Local spindles.
%   - ModuIndex.mat: Single-cell Modulation Indices for Global and Local 
%     spindles.
%
% OUTPUTS:
%   - Visualizations: Overlaid histograms and a box plot comparing the 
%     distributions of amplitude, duration, firing rate, and Modulation 
%     Index between Global and Local spindles.
%   - Statistical Results: Command window output displaying mean values 
%     and p-values from t-tests for each compared property.
% =========================================================================

clc 
clear
% close all
changeCurrentFolder('D:\daniel\Mouse12-120806')
%%
load sepratedSpindles120806 sepratedSpindles120806
load thal_ch_norm_filtered.mat
load (['real_peaks' num2str(sepratedSpindles120806.referencChannel) '.mat'])
%% amplitude compare
fs=1250;

% globampTime = transpose(sepratedSpindles120806.globalSPindles(:,2));
% locampTime = transpose(sepratedSpindles120806.localSPindles(:,2));

% globamp = zeros(1,size(globampTime,2));
% globamp = thal_ch_norm_filtered(sepratedSpindles120806.referencChannel,(round(globampTime*fs)));
% locamp = zeros(1,size(locampTime,2));
% locamp = thal_ch_norm_filtered(sepratedSpindles120806.referencChannel,(round(locampTime*fs)));

globamp = sepratedSpindles120806.globalPeaks(1,:);
locamp = sepratedSpindles120806.LocalPeaks(1,:);


% for i=1:length(globampTime)
% globamp(1,i) = thal_ch_norm_filtered(sepratedSpindles120806.referencChannel,(globampTime(1,i)*fs));
% end
% compute means

meanglobamp = mean(globamp);
meanlocamp = mean(locamp);

% Perform t-test
[h, p] = ttest2(globamp, locamp);

% Display results
if h
    disp(['mean amplitude for global is ' num2str(meanglobamp)]);
    disp(['mean amplitude for local is ' num2str(meanlocamp)]);
    fprintf('There is a significant difference between the means.\n');
else
    disp(['mean amplitude for global is ' num2str(meanglobamp)]);
    disp(['mean amplitude for local is ' num2str(meanlocamp)]);
    fprintf('There is no significant difference between the means.\n');
end
fprintf('p-value: %.4f\n', p);

%plot 
figure
nbin=50;
histogram(globamp,nbin,'FaceColor','g')
xline (meanglobamp,'Color','g','LineWidth',2,'LineStyle','--')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold on
histogram (locamp,nbin,'FaceColor','m')
xline(meanlocamp,'color','m','LineWidth',2,'LineStyle','--')
% if p < 0.05
%     if meanglobamp > meanlocamp
%         plot (meanlocamp:meanglobamp,9*ones(meanlocamp:meanglobamp))
%         hold on 
%         plot ((meanglobamp-meanlocamp)/2,9,'MarkerIndices','*')
%         hold off
%     end
% else 
%     plot (meanglobamp:meanlocamp,9*ones(meanglobamp:meanlocamp))
%         hold on 
%         plot ((abs(meanglobamp-meanlocamp))/2,9,'MarkerIndices','*')
%         hold off
% end
title('amplitude compare ','Color','white')
xlabel('amplitude','Color','white')

% Get the handle to the legend object
% legend_handle = legend ('Global',['Mean Global = ' num2str(meanglobamp)],'Local',['Mean Local = 'num2str(meanlocamp)]);
legend_handle = legend('Global',['Mean Global = ' num2str(meanglobamp)],'Local',['Mean Local = ' num2str(meanlocamp)]); % Fix the closing parenthesis

% Set the text color to white
set(legend_handle, 'TextColor', 'white')
text('FontSize', 20, 'Color', 'white', 'Position', [0.7, 35],'String',['p-value = ' num2str(p)]);
hold off

%% duration compare 
% duration for globals 

onsetGlob = transpose(sepratedSpindles120806.globalSPindles(:,1));
offsetGlob = transpose(sepratedSpindles120806.globalSPindles(:,3));
durationGlob = offsetGlob - onsetGlob ;

% duration for locals 

onsetLoc = transpose(sepratedSpindles120806.localSPindles(:,1));
offsetLoc = transpose(sepratedSpindles120806.localSPindles(:,3));
durationLoc = offsetLoc - onsetLoc ;

% compute means

meanDurationGlob = mean(durationGlob);
meanDurationLoc = mean(durationLoc);


% Perform t-test
[h, p] = ttest2(durationGlob, durationLoc);

% Display results
if isnan(h)
    disp('Error in performing t-test.');
elseif h
    disp(['mean duration for Big ratio is ' num2str(meanDurationGlob)]);
    disp(['mean duration for short ratio is ' num2str(meanDurationLoc)]);
    fprintf('There is a significant difference between the means.\n');
else
    disp(['mean duration for Big ratio is ' num2str(meanDurationGlob)]);
    disp(['mean duration for short ratio is ' num2str(meanDurationLoc)]);
    fprintf('There is no significant difference between the means.\n');
end
fprintf('p-value: %.4f\n', p);


%plot 

figure
nbin=50;
histogram(durationGlob,nbin,'FaceColor','g')
xline (meanDurationGlob,'Color','g','LineWidth',2,'LineStyle','--')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold on
histogram (durationLoc,nbin,'FaceColor','m')
xline(meanDurationLoc,'color','m','LineWidth',2,'LineStyle','--')
% if p < 0.05
%     if meandelaybig > meandelayshort
%         plot (meandelayshort:meandelaybig,9*ones(meandelayshort:meandelaybig))
%         hold on 
%         plot ((meandelaybig-meandelayshort)/2,9,'MarkerIndices','*')
%         hold off
%     end
% else 
%     plot (meandelaybig:meandelayshort,9*ones(meandelaybig:meandelayshort))
%         hold on 
%         plot ((abs(meandelaybig-meandelayshort))/2,9,'MarkerIndices','*')
%         hold off
% end
title('histogram of duration for global and Local ','Color','white')
% legend (['P-value = ' num2str(p)],'Color','white')
xlabel('duration','Color','white')
% Get the handle to the legend object
% legend_handle = legend ('Global',['Mean Global = ' num2str(meanglobamp)],'Local',['Mean Local = 'num2str(meanlocamp)]);
legend_handle = legend('Global',['Mean Global = ' num2str(meanDurationGlob)],'Local',['Mean Local = ' num2str(meanDurationLoc)]); 

% Set the text color to white
set(legend_handle, 'TextColor', 'white')
text('FontSize', 20, 'Color', 'white', 'Position', [0.7, 35],'String',['p-value = ' num2str(p)]);
hold off

%% firing rate 
load FiringrateSpindles.mat 

meanfiringRateGlob = mean(FiringrateSpindles.Global);
meanfiringRateLoc = mean(FiringrateSpindles.Local);


% Perform t-test
[h, p] = ttest(FiringrateSpindles.Global, FiringrateSpindles.Local);

% Display results
if isnan(h)
    disp('Error in performing t-test.');
elseif h
    disp(['mean firing rate for big is ' num2str(meanfiringRateGlob)]);
    disp(['mean firing rate for short is ' num2str(meanfiringRateLoc)]);
    fprintf('There is a significant difference between the means.\n');
else
    disp(['mean firing rate for big is ' num2str(meanfiringRateGlob)]);
    disp(['mean firing rate for short is ' num2str(meanfiringRateLoc)]);
    fprintf('There is no significant difference between the means.\n');
end
fprintf('p-value: %.4f\n', p);

%plot

%plot 

figure
nbin=50;
histogram(FiringrateSpindles.Global,nbin,'FaceColor','g')
xline (meanfiringRateGlob,'Color','g','LineWidth',2,'LineStyle','--')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold on
histogram (FiringrateSpindles.Local,nbin,'FaceColor','m')
xline(meanfiringRateLoc,'color','m','LineWidth',2,'LineStyle','--')
% if p < 0.05
%     if meandelaybig > meandelayshort
%         plot (meandelayshort:meandelaybig,9*ones(meandelayshort:meandelaybig))
%         hold on 
%         plot ((meandelaybig-meandelayshort)/2,9,'MarkerIndices','*')
%         hold off
%     end
% else 
%     plot (meandelaybig:meandelayshort,9*ones(meandelaybig:meandelayshort))
%         hold on 
%         plot ((abs(meandelaybig-meandelayshort))/2,9,'MarkerIndices','*')
%         hold off
% end
title('histogram of Firingrate for global and Local ','Color','white')
% legend (['P-value = ' num2str(p)],'Color','white')
xlabel('Firing rate','Color','white')
% Get the handle to the legend object
% legend_handle = legend ('Global',['Mean Global = ' num2str(meanglobamp)],'Local',['Mean Local = 'num2str(meanlocamp)]);
legend_handle = legend('Global',['Mean Global = ' num2str(meanfiringRateGlob)],'Local',['Mean Local = ' num2str(meanfiringRateLoc)]); 

% Set the text color to white
set(legend_handle, 'TextColor', 'white')
text('FontSize', 20, 'Color', 'white', 'Position', [1.5, 50],'String',['p-value = ' num2str(p)]);
hold off
%% MI
load ModuIndex.mat 
meanModuIndexGlob = mean(ModuIndex.GLobal  );
meanModuIndexLoc = mean(ModuIndex.Local);


% Perform t-test
[h, p] = ttest(ModuIndex.GLobal , ModuIndex.Local);

% Display results
if isnan(h)
    disp('Error in performing t-test.');
elseif h
    disp(['mean firing rate for big is ' num2str(meanModuIndexGlob)]);
    disp(['mean firing rate for short is ' num2str(meanModuIndexLoc)]);
    fprintf('There is a significant difference between the means.\n');
else
    disp(['mean firing rate for big is ' num2str(meanModuIndexGlob)]);
    disp(['mean firing rate for short is ' num2str(meanModuIndexLoc)]);
    fprintf('There is no significant difference between the means.\n');
end
fprintf('p-value: %.4f\n', p);

%plot

%plot 

figure
nbin=50;
histogram(ModuIndex.GLobal,nbin,'FaceColor','g')
xline (meanModuIndexGlob,'Color','g','LineWidth',2,'LineStyle','--')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold on
histogram (ModuIndex.Local,nbin,'FaceColor','m')
xline(ModuIndexLoc,'color','m','LineWidth',2,'LineStyle','--')
% if p < 0.05
%     if meandelaybig > meandelayshort
%         plot (meandelayshort:meandelaybig,9*ones(meandelayshort:meandelaybig))
%         hold on 
%         plot ((meandelaybig-meandelayshort)/2,9,'MarkerIndices','*')
%         hold off
%     end
% else 
%     plot (meandelaybig:meandelayshort,9*ones(meandelaybig:meandelayshort))
%         hold on 
%         plot ((abs(meandelaybig-meandelayshort))/2,9,'MarkerIndices','*')
%         hold off
% end
title('histogram of Firingrate for global and Local ','Color','white')
% legend (['P-value = ' num2str(p)],'Color','white')
xlabel('Firing rate','Color','white')
% Get the handle to the legend object
% legend_handle = legend ('Global',['Mean Global = ' num2str(meanglobamp)],'Local',['Mean Local = 'num2str(meanlocamp)]);
legend_handle = legend('Global',['Mean Global = ' num2str(meanModuIndexGlob)],'Local',['Mean Local = ' num2str(meanModuIndexLoc)]); 

% Set the text color to white
set(legend_handle, 'TextColor', 'white')
text('FontSize', 20, 'Color', 'white', 'Position', [1.5, 50],'String',['p-value = ' num2str(p)]);
hold off
% box plot 

myData = transpose( [ModuIndex.GLobal ; ModuIndex.Local] );
figure
boxplot(myData,'PlotStyle','compact','Notch','on','Colors','m','BoxStyle','filled','Labels',{'Global','Local'})
set(gcf, 'Color', 'black')
title('histogram of Firingrate for global and Local ','Color','white')
% legend (['P-value = ' num2str(p)],'Color','white')
xlabel('Firing rate','Color','white')
% Get the handle to the legend object
% legend_handle = legend ('Global',['Mean Global = ' num2str(meanglobamp)],'Local',['Mean Local = 'num2str(meanlocamp)]);
% legend_handle = legend('Global',['Mean Global = ' num2str(meanModuIndexGlob)],'Local',['Mean Local = ' num2str(meanModuIndexLoc)]); 
set(legend_handle, 'TextColor', 'white')

text('FontSize', 20, 'Color', 'white', 'Position', [1.5, 50],'String',['p-value = ' num2str(p)]);
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
