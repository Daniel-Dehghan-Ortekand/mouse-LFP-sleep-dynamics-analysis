% =========================================================================
% SCRIPT: Statistical Comparison of "Big" vs. "Short" Slow Oscillation Properties
% SUBJECT: Mouse12-120806
% =========================================================================
% DESCRIPTION:
% Performs a comprehensive statistical comparison between two classes of 
% Slow Oscillations ("Big" and "Short", separated by a population amplitude 
% threshold). Evaluates key neurophysiological metrics including peak 
% amplitude, propagation delay, peak-to-peak ratio, duration, population 
% firing rate, and Phase-Amplitude Coupling (PAC) features (SI angle and 
% strength). Additionally, it compares the Modulation Index (MI) between 
% Global and Local events. Uses appropriate statistical tests (independent 
% t-tests and Watson-Williams test for circular data) and visualizes the 
% distributions via overlaid histograms and box plots.
%
% INPUTS:
%   - SOdetectedForChooseOneChannelFromEachShank.mat: Detected SO events.
%   - SOreferenceChannelDelayAndRatio.mat: Delay and ratio metrics.
%   - SepratedMeanSignals.mat: Separated mean signals and event indices.
%   - firingRateBig.mat & firingRateshort.mat: Population firing rates.
%   - PAC_features120806.mat: Phase-Amplitude Coupling angles and strengths.
%   - ModuIndexSo120806.mat: Single-cell Modulation Indices.
%
% OUTPUTS:
%   - Visualizations: Overlaid histograms and a box plot comparing the 
%     distributions of amplitude, delay, ratio, duration, firing rate, 
%     PAC features, and Modulation Index.
%   - Statistical Results: Command window output displaying mean values 
%     and p-values for each compared property.
%   - Batch-saved figures (.png, .fig) in the specified directory.
%
% DEPENDENCIES:
%   - Custom function: SOMolle (for duration detection).
%   - Circular Statistics Toolbox: circ_wwtest.
% =========================================================================

clc 
clear
close all
changeCurrentFolder('D:\daniel\Mouse12-120806')
%%
load SOdetectedForChooseOneChannelFromEachShank.mat
load SOreferenceChannelDelayAndRatio.mat 
load SepratedMeanSignals.mat
load firingRateBig.mat 
load firingRateshort.mat    
load PAC_features120806.mat 

%% amplitude compare
fs=1250;
refsamp= find(SOdetected.ISBLIPE(1,:)==1);
refTime = refsamp/fs;
refsampBig= refsamp(SepratedMeanSignals.EventsBiggerThanThreshold  );
refsampShort= refsamp(SepratedMeanSignals.EventsShorterThanThreshold  );
ampBig = SepratedMeanSignals.SignalsBiggerThanThreshold  (refsampBig);
ampshort = SepratedMeanSignals.SignalsShorterThanThreshold  (refsampShort);

% compute means

meanbig = mean(ampBig);
meanshort = mean(ampshort);

% Perform t-test
[h, p] = ttest2(ampBig, ampshort);

% Display results
if h
    disp(['mean amplitude for Big ratio is ' num2str(meanbig)]);
    disp(['mean amplitude for short ratio is ' num2str(meanshort)]);
    fprintf('There is a significant difference between the means.\n');
else
    disp(['mean amplitude for Big ratio is ' num2str(meanbig)]);
    disp(['mean amplitude for short ratio is ' num2str(meanshort)]);
    fprintf('There is no significant difference between the means.\n');
end
fprintf('p-value: %.4f\n', p);

%plot 
figure
nbin=50;
histogram(ampBig,nbin,'FaceColor','white')
xline (meanbig,'Color','r','LineWidth',2,'LineStyle','--')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold on
histogram (ampshort,nbin,'FaceColor','m')
xline(meanshort,'color','g','LineWidth',2,'LineStyle','--')
if p < 0.05
    if meanbig > meanshort
        plot (meanshort:meanbig,9*ones(meanshort:meanbig))
        hold on 
        plot ((meanbig-meanshort)/2,9,'MarkerIndices','*')
        hold off
    end
else 
    plot (meanbig:meanshort,9*ones(meanbig:meanshort))
        hold on 
        plot ((abs(meanbig-meanshort))/2,9,'MarkerIndices','*')
        hold off
end
title('histogram of amplitude for bigger and shorter than threshold ','Color','white')
legend (['P-value = ' num2str(p)],'big','short','mean big','mean short ','Color','white')
hold off

%% campare delays 

delayBig = SOreferenceChannelDelayAndRatio.delay (SepratedMeanSignals.EventsBiggerThanThreshold );
delayShort = SOreferenceChannelDelayAndRatio.delay (SepratedMeanSignals.EventsShorterThanThreshold );

meandelaybig = mean(delayBig);
meandelayshort = mean(delayShort);



% Perform t-test
[h, p] = ttest2(delayBig, delayShort);

% Display results
if isnan(h)
    disp('Error in performing t-test.');
elseif h
    disp(['mean delay for Big ratio is ' num2str(meandelaybig)]);
    disp(['mean delay for short ratio is ' num2str(meandelayshort)]);
    fprintf('There is a significant difference between the means.\n');
else
    disp(['mean delay for Big ratio is ' num2str(meandelaybig)]);
    disp(['mean delay for short ratio is ' num2str(meandelayshort)]);
    fprintf('There is no significant difference between the means.\n');
end
fprintf('p-value: %.4f\n', p);

% plot 

%plot 
figure
nbin=50;
histogram(delayBig,nbin,'FaceColor','white')
xline (meandelaybig,'Color','r','LineWidth',2,'LineStyle','--')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold on
histogram (delayShort,nbin,'FaceColor','m')
xline(meandelayshort,'color','g','LineWidth',2,'LineStyle','--')
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
title('histogram of delay for bigger and shorter than threshold ','Color','white')
legend (['P-value = ' num2str(p)],'Color','white')
hold off


%% compare ratios 
ratioBig = SOreferenceChannelDelayAndRatio.ratio (SepratedMeanSignals.EventsBiggerThanThreshold );
ratioShort = SOreferenceChannelDelayAndRatio.ratio (SepratedMeanSignals.EventsShorterThanThreshold );

meanratiobig = mean(ratioBig);
meanratioshort = mean(ratioShort);



% Perform t-test
[h, p] = ttest2(ratioBig, ratioShort);

% Display results
if isnan(h)
    disp('Error in performing t-test.');
elseif h
    disp(['mean ratio for Big ratio is ' num2str(meanratiobig)]);
    disp(['mean ratio for short ratio is ' num2str(meanratioshort)]);
    fprintf('There is a significant difference between the means.\n');
else
    disp(['mean ratio for Big ratio is ' num2str(meanratiobig)]);
    disp(['mean ratio for short ratio is ' num2str(meanratioshort)]);
    fprintf('There is no significant difference between the means.\n');
end
fprintf('p-value: %.4f\n', p);

%plot
figure
nbin=50;
histogram(ratioBig,nbin,'FaceColor','white')
xline (meanratiobig,'Color','r','LineWidth',2,'LineStyle','--')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold on
histogram (ratioShort,nbin,'FaceColor','m')
xline(meanratioshort,'color','g','LineWidth',2,'LineStyle','--')
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
title('histogram of ratio for bigger and shorter than threshold ','Color','white')
legend (['P-value = ' num2str(p)],'Color','white')

hold off

%% duration compare 
% detection for bigger 

[y,IsBlip]  = SOMolle(SepratedMeanSignals.SignalsBiggerThanThreshold (1,:));
YBig = y;
ISBLIPEBig = IsBlip;


diffBig = diff(YBig);
start_indicesBig = find(diffBig==1);
end_indicesBig = find(diffBig==-1);
durationBig = end_indicesBig - start_indicesBig;
% detection for shorter 

[y,IsBlip]  = SOMolle(SepratedMeanSignals.SignalsShorterThanThreshold   (1,:));
Yshort = y;
ISBLIPEShort = IsBlip;

diffShort = diff(Yshort);
start_indicesShort = find(diffShort == 1);
end_indicesShort = find(diffShort == -1);
durationShort = end_indicesShort - start_indicesShort ;

% compute means

meanDurationbig = mean(durationBig);
meanDurationshort = mean(durationShort);


% Perform t-test
[h, p] = ttest2(durationBig, durationShort);

% Display results
if isnan(h)
    disp('Error in performing t-test.');
elseif h
    disp(['mean duration for Big ratio is ' num2str(meanDurationbig)]);
    disp(['mean duration for short ratio is ' num2str(meanDurationshort)]);
    fprintf('There is a significant difference between the means.\n');
else
    disp(['mean duration for Big ratio is ' num2str(meanDurationbig)]);
    disp(['mean duration for short ratio is ' num2str(meanDurationshort)]);
    fprintf('There is no significant difference between the means.\n');
end
fprintf('p-value: %.4f\n', p);


%plot 

figure
nbin=50;
histogram(durationBig,nbin,'FaceColor','white')
xline (meanDurationbig,'Color','r','LineWidth',2,'LineStyle','--')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold on
histogram (durationShort,nbin,'FaceColor','m')
xline(meanDurationshort,'color','g','LineWidth',2,'LineStyle','--')
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
title('histogram of duration for bigger and shorter than threshold ','Color','white')
legend (['P-value = ' num2str(p)],'Color','white')

hold off

%% firing rate 


meanfiringRateBig = mean(firingRateBig);
meanfiringRateshort = mean(firingRateshort);


% Perform t-test
[h, p] = ttest2(firingRateBig, firingRateshort);

% Display results
if isnan(h)
    disp('Error in performing t-test.');
elseif h
    disp(['mean firing rate for big is ' num2str(meanfiringRateBig)]);
    disp(['mean firing rate for short is ' num2str(meanfiringRateshort)]);
    fprintf('There is a significant difference between the means.\n');
else
    disp(['mean firing rate for big is ' num2str(meanfiringRateBig)]);
    disp(['mean firing rate for short is ' num2str(meanfiringRateshort)]);
    fprintf('There is no significant difference between the means.\n');
end
fprintf('p-value: %.4f\n', p);

%plot

%plot 

figure
nbin=50;
histogram(firingRateBig,nbin,'FaceColor','white')
xline (meanfiringRateBig,'Color','r','LineWidth',2,'LineStyle','--')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold on
histogram (firingRateshort,nbin,'FaceColor','m')
xline(meanfiringRateshort,'color','g','LineWidth',2,'LineStyle','--')
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
title('histogram of firing rate  for bigger and shorter than threshold ','Color','white')
legend (['P-value = ' num2str(p)],'Color','white')

hold off

%% PAC features 

meanSIangleShort = mean(PAC_features.angleShort);

meanSIangleBig = mean(PAC_features.angleBig);

% for angles 

% Perform t-test
% [h, p] = ttest2(PAC_features.angleBig, PAC_features.angleShort);
pval = circ_wwtest(PAC_features.angleBig,PAC_features.angleShort);
% Display results
if pval < 0.05
    disp(['mean SI angle for Big is ' num2str(meanSIangleBig)]);
    disp(['mean SI angle for short is ' num2str(meanSIangleShort)]);
    fprintf('There is significant difference between the means.\n');
end
fprintf('p-value: %.4f\n', pval);


%plot for angles 

figure
nbin=50;
histogram(PAC_features.angleBig,nbin,'FaceColor','white')
xline (meanSIangleBig,'Color','r','LineWidth',2,'LineStyle','--')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold on
histogram (PAC_features.angleShort,nbin,'FaceColor','m')
xline(meanSIangleShort,'color','g','LineWidth',2,'LineStyle','--')
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
title('histogram of SI angle for bigger and shorter than threshold ','Color','white')
legend (['P-value = ' num2str(p)],'Color','white')

hold off

% for strength 
meanSIabsShort = mean(PAC_features.strengthShort);
meanSIabsBig = mean(PAC_features.strengthBig);

% Perform t-test
[h, p] = ttest2(PAC_features.strengthBig, PAC_features.strengthShort);

% Display results
if isnan(h)
    disp('Error in performing t-test.');
elseif h
    disp(['mean SI strngth for Big is ' num2str(meanSIabsBig)]);
    disp(['mean SI strngth for short is ' num2str(meanSIabsShort)]);
    fprintf('There is a significant difference between the means.\n');
else
    disp(['mean SI strngth for Big is ' num2str(meanSIabsBig)]);
    disp(['mean SI strngth for short is ' num2str(meanSIabsShort)]);
    fprintf('There is no significant difference between the means.\n');
end
fprintf('p-value: %.4f\n', p);


%plot  

figure
nbin=50;
histogram(PAC_features.strengthBig,nbin,'FaceColor','white')
xline (meanSIabsBig,'Color','r','LineWidth',2,'LineStyle','--')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold on
histogram (PAC_features.strengthShort,nbin,'FaceColor','m')
xline(meanSIabsShort,'color','g','LineWidth',2,'LineStyle','--')
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
title('histogram of strength for bigger and shorter than threshold ','Color','white')
legend (['P-value = ' num2str(p)],'Color','white')

hold off

%% MI
load ModuIndexSo120806.mat 
meanModuIndexBig = mean(ModuIndex120810.Big  );
meanModuIndexLoc = mean(ModuIndex120810.Local);


% Perform t-test
[h, p] = ttest(ModuIndex120810.GLobal , ModuIndex120810.Local);

% Display results
if isnan(h)
    disp('Error in performing t-test.');
elseif h
    disp(['mean firing rate for big is ' num2str(meanModuIndexBig)]);
    disp(['mean firing rate for short is ' num2str(meanModuIndexLoc)]);
    fprintf('There is a significant difference between the means.\n');
else
    disp(['mean firing rate for big is ' num2str(meanModuIndexBig)]);
    disp(['mean firing rate for short is ' num2str(meanModuIndexLoc)]);
    fprintf('There is no significant difference between the means.\n');
end
fprintf('p-value: %.4f\n', p);

%plot

%plot 

figure
nbin=50;
histogram(ModuIndex120810.GLobal,nbin,'FaceColor','b')
xline (meanModuIndexLoc,'Color','b','LineWidth',2,'LineStyle','--')
hold on
histogram (ModuIndex120810.Local,nbin,'FaceColor','r')
xline(meanModuIndexLoc,'color','r','LineWidth',2,'LineStyle','--')

title('histogram of Firingrate for global and Local ','Color','k')
% legend (['P-value = ' num2str(p)],'Color','white')
xlabel('Firing rate','Color','k')
% Get the handle to the legend object
% legend_handle = legend ('Global',['Mean Global = ' num2str(meanglobamp)],'Local',['Mean Local = 'num2str(meanlocamp)]);
legend_handle = legend('Global',['Mean Global = ' num2str(meanModuIndexBig)],'Local',['Mean Local = ' num2str(meanModuIndexLoc)]); 

% Set the text color to white
set(legend_handle, 'TextColor', 'k')
text('FontSize', 20, 'Color', 'k', 'Position', [1.5, 50],'String',['p-value = ' num2str(p)]);
hold off
% box plot 

myData = transpose( [ModuIndex120810.GLobal ; ModuIndex120810.Local] );
figure
boxplot(myData,'PlotStyle','compact','Notch','on','Colors','r','BoxStyle','filled','Labels',{'Global','Local'})
% set(gcf, 'Color', 'black')
title('histogram of Firingrate for global and Local ','Color','k')
% legend (['P-value = ' num2str(p)],'Color','white')
xlabel('Firing rate','color','k')
% Get the handle to the legend object
% legend_handle = legend ('Global',['Mean Global = ' num2str(meanglobamp)],'Local',['Mean Local = 'num2str(meanlocamp)]);
% legend_handle = legend('Global',['Mean Global = ' num2str(meanModuIndexGlob)],'Local',['Mean Local = ' num2str(meanModuIndexLoc)]); 
% set(legend_handle, 'TextColor', 'white')

text('FontSize', 20, 'Color', 'k', 'Position', [1.5, 50],'String',['p-value = ' num2str(p)]);


%% save figures
% Get the path to the directory where you want to save the figures
save_path = 'D:/daniel/Mouse12-120810/compares figures';

% Get a list of all open figures
fig_list = findobj('Type', 'figure');

% Save each figure to the specified path
for i = 1:length(fig_list)
    fig = fig_list(i);
    saveas(fig, fullfile(save_path, sprintf('figure_%d.png', i)));
    saveas(fig, fullfile(save_path, sprintf('figure_%d.fig', i)));


end




