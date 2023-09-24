clc
clear
cd 'C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\3ModelEstimation\code'

load('../output/g4_counterfactual_results.mat','BasicCn','Cn0');
load('../output/g4_counterfactual_results_no_migration.mat','NMBasicCn');

%% Main

CnArray=[Cn0 BasicCn.Cn4 NMBasicCn.Cn4 BasicCn.Cn3 NMBasicCn.Cn3];

PopFertility=zeros(3,length(CnArray));
for i=1:length(CnArray)
    PopFertility(:,i)=[sum(CnArray(i).Solution.FL1)/sum(CnArray(i).Solution.NL1); sum(CnArray(i).Solution.FH1)/sum(CnArray(i).Solution.NH1); sum(CnArray(i).Solution.FH1+CnArray(i).Solution.FL1)/sum(CnArray(i).Solution.NH1+CnArray(i).Solution.NL1)];
end
PopFertility=PopFertility-PopFertility(:,1);


%% GE Eliminate Support
ax1=g5a_pop_diff_graph(BasicCn.Cn4,Cn0,1);
exportgraphics(ax1,'../object/g5A_cn4_pop_diff.png')

ax2=g5b_fert_diff_graph(BasicCn.Cn4,Cn0,2);
exportgraphics(ax2,'../object/g5A_cn4_frat_diff.png')

ax1=g5c_pop_comp_diff_graph(BasicCn.Cn4,Cn0,3);
exportgraphics(ax1,'../object/g5A_cn4_comp_diff.png')

%% GE Maximize Support

ax1=g5a_pop_diff_graph(BasicCn.Cn3,Cn0,4);
exportgraphics(ax1,'../object/g5A_cn3_pop_diff.png')

ax2=g5b_fert_diff_graph(BasicCn.Cn3,Cn0,5);
exportgraphics(ax2,'../object/g5A_cn3_frat_diff.png')

ax1=g5c_pop_comp_diff_graph(BasicCn.Cn3,Cn0,6);
exportgraphics(ax1,'../object/g5A_cn3_comp_diff.png')

%{
%% Partial
load('../output/g4A_counterfactual_results.mat','BasicCn','Cn0');

ax1=g5a_pop_diff_graph(BasicCn.Cn4,Cn0,7);
exportgraphics(ax1,'../object/g5A_cn4_pop_diff_partial.png')

ax2=g5b_fert_diff_graph(BasicCn.Cn4,Cn0,8);
exportgraphics(ax2,'../object/g5A_cn4_frat_diff_partial.png')

ax1=g5c_pop_comp_diff_graph(BasicCn.Cn4,Cn0,9);
exportgraphics(ax1,'../object/g5A_cn4_comp_diff_partial.png')

ax1=g5a_pop_diff_graph(BasicCn.Cn3,Cn0,10);
exportgraphics(ax1,'../object/g5A_cn3_pop_diff_partial.png')

ax2=g5b_fert_diff_graph(BasicCn.Cn3,Cn0,11);
exportgraphics(ax2,'../object/g5A_cn3_frat_diff_partial.png')

ax1=g5c_pop_comp_diff_graph(BasicCn.Cn3,Cn0,12);
exportgraphics(ax1,'../object/g5A_cn3_comp_diff_partial.png')
%}

%% Function
function ax1=g5a_pop_diff_graph(Cn,Cn0,i)
    logPL=log(Cn0.Solution.r.^(Cn0.Cfund.rho).*Cn0.Cfund.RL.^(-1));
    logPL=logPL-mean(logPL);
    logPH=log(Cn0.Solution.r.^(Cn0.Cfund.rho).*Cn0.Cfund.RH.^(-1));
    logPH=logPH-mean(logPH);


    PopDiffL=Cn.Solution.NL./Cn0.Solution.NL-1;
    PopDiffH=Cn.Solution.NH./Cn0.Solution.NH-1;
    
    ax1 = figure(i);
    
    hold on
    
    scatter(logPL,PopDiffL,[],"red","o")
    lsline
    
    scatter(logPH,PopDiffH,[],"blue","x")
    lsline
    h = lsline;
    set(h(1),'color','b')
    set(h(2),'color','red')
        
    legend('low skill','','high skill')
    xlabel('Log baseline p^e_d')
    ylabel('Percentage change in pop by skill')
    hold off
end

function ax2=g5b_fert_diff_graph(Cn,Cn0,i)
    logPL=log(Cn0.Solution.r.^(Cn0.Cfund.rho).*Cn0.Cfund.RL.^(-1));
    logPL=logPL-mean(logPL);
    logPH=log(Cn0.Solution.r.^(Cn0.Cfund.rho).*Cn0.Cfund.RH.^(-1));
    logPH=logPH-mean(logPH);
    ax2 = figure(i);
    
    FrateDiffL=(Cn.Solution.FL./Cn.Solution.NL)-(Cn0.Solution.FL./Cn0.Solution.NL);
    FrateDiffH=(Cn.Solution.FH./Cn.Solution.NH)-(Cn0.Solution.FH./Cn0.Solution.NH);
    
    hold on
    scatter(logPL,FrateDiffL,[],"red","o")
    lsline
    scatter(logPH,FrateDiffH,[],"blue","x")
    lsline
    h = lsline;
    set(h(1),'color','b')
    set(h(2),'color','red')
        
    legend('low skill','','high skill')
    xlabel('Log baseline p^e_d')
    ylabel('Change in share of HHs with children')
    hold off
end

function ax1=g5c_pop_comp_diff_graph(Cn,Cn0,i)
    logPL=log(Cn0.Solution.r.^(Cn0.Cfund.rho).*Cn0.Cfund.RL.^(-1));
    logPL=logPL-mean(logPL);
    logPH=log(Cn0.Solution.r.^(Cn0.Cfund.rho).*Cn0.Cfund.RH.^(-1));
    logPH=logPH-mean(logPH);

    long_distance_ind=[Cn0.Counter.kappa_etaL==1];
    Ori_compL=sum((Cn0.Solution.PiL.*long_distance_ind).*Cn0.Cfund.LL',2)./sum(Cn0.Solution.PiL.*Cn0.Cfund.LL',2);
    Ori_compH=sum((Cn0.Solution.PiH.*long_distance_ind).*Cn0.Cfund.LH',2)./sum(Cn0.Solution.PiH.*Cn0.Cfund.LH',2);
    Cn_compL=sum((Cn.Solution.PiL.*long_distance_ind).*Cn0.Cfund.LL',2)./sum(Cn.Solution.PiL.*Cn0.Cfund.LL',2);
    Cn_compH=sum((Cn.Solution.PiH.*long_distance_ind).*Cn0.Cfund.LH',2)./sum(Cn.Solution.PiH.*Cn0.Cfund.LH',2);

    CompDiffL=Cn_compL-Ori_compL;
    CompDiffH=Cn_compH-Ori_compH;
    
    ax1 = figure(i);
    
    hold on
    
    scatter(logPL,CompDiffL,[],"red","o")
    lsline
    
    scatter(logPH,CompDiffH,[],"blue","x")
    lsline
    h = lsline;
    set(h(1),'color','b')
    set(h(2),'color','red')
        
    legend('low skill','','high skill')
    xlabel('Log baseline p^e_d')
    ylabel('Change in share of long-distance migrants')
    hold off
end
