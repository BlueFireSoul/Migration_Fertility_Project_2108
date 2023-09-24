clc
clear
cd 'C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\3ModelEstimation\code'

load('../output/g2_completed_calibration.mat','Data','Fund','Inc','Norm','Para','Option','Comp');

%% Pop composition
long_distance_ind=[Para.kappa_etaL==1];
CompositionL=sum((Comp.PiL.*long_distance_ind).*Data.LL',2)./sum(Comp.PiL.*Data.LL',2);
CompositionH=sum((Comp.PiH.*long_distance_ind).*Data.LH',2)./sum(Comp.PiH.*Data.LH',2);


logPL=log(Data.r.^(Para.rho).*Fund.RL.^(-1));
logPL=logPL-mean(logPL);
logPH=log(Data.r.^(Para.rho).*Fund.RH.^(-1));
logPH=logPH-mean(logPH);

logr=log(Data.r);
logpop=log(Data.NL+Data.NH);

ax1 = figure(1);

hold on

scatter(logPL,CompositionL,[],"red","o")
lsline

scatter(logPH,CompositionH,[],"blue","x")
lsline
h = lsline;
set(h(1),'color','b')
set(h(2),'color','red')
    
legend('low skill','','high skill')
xlabel('Log baseline p^e_d')
ylabel('Share of long-distance migrants')
hold off

exportgraphics(ax1,'../object/g2A_comp_dist.png')

%% Pop composition data
Comp_array_data=table2array(readtable('../output/f3b_comp_share_figure_input_pass.csv'));
ax1 = figure(2);

hold on

scatter(logPL,Comp_array_data(:,2),[],"red","o")
lsline

scatter(logPH,Comp_array_data(:,3),[],"blue","x")
lsline
h = lsline;
set(h(1),'color','b')
set(h(2),'color','red')
    
legend('low skill','','high skill')
xlabel('Log baseline p^e_d')
ylabel('Share of long-distance migrants')
hold off

exportgraphics(ax1,'../object/g2A_comp_dist_data.png')

%% Comp model data diff
DiffL=CompositionL-Comp_array_data(:,2);
DiffH=CompositionH-Comp_array_data(:,3);

ax1 = figure(3);

hold on

scatter(logPL,DiffL,[],"red","o")
lsline

scatter(logPH,DiffH,[],"blue","x")
lsline
h = lsline;
set(h(1),'color','b')
set(h(2),'color','red')
    
legend('low skill','','high skill')
xlabel('Log baseline p^e_d')
ylabel('Difference in share of long-distance migrants')
hold off

exportgraphics(ax1,'../object/g2A_comp_dist_diff.png')

%%
%{

ax1 = figure(4);

hold on

scatter(logpop,CompositionL,[],"red","o")
lsline

scatter(logpop,CompositionH,[],"blue","x")
lsline
h = lsline;
set(h(1),'color','b')
set(h(2),'color','red')
    
legend('low skill','','high skill')
xlabel('Log pop')
ylabel('Share of long-distant migrants')
hold off
%}