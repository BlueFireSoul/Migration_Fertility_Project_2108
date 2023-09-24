clc
clear
cd 'C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\3ModelEstimation\code'

[Para,Data,Norm]=g1a_import_data;
[Inc,Fund]=g1b_land_supply(Para,Data);
save('../output/g1_production_side.mat','Data','Fund','Inc','Norm','Para');

% Function
function [Inc,Fund]=g1b_land_supply(Para,Data)
[Inc]=g1b1_income(Para,Data,1000);
Hdmm=g1b2_housing(Para,Data,Inc);
for i=1:100
    Hdmm_past=Hdmm;
    [Inc]=g1b1_income(Para,Data,Hdmm);
    Hdmm=g1b2_housing(Para,Data,Inc);
end
if norm(Hdmm-Hdmm_past,Inf)~=0
   warning('Hdmm fails to converge') 
end
Fund.H_tilde=log(Data.r)-((1-Para.epsilon)./Para.epsilon).*log(Hdmm);
end

function Hdmm=g1b2_housing(Para,Data,Inc)
Hdmm=(Para.alpha*(Inc.ILN.*(Data.NL-Data.FL)+Inc.IHN.*(Data.NH-Data.FH))+ ...
    (Para.alpha+Para.beta_rho)*(Inc.ILW.*Data.FL+Inc.IHW.*Data.FH))./Data.r;
end

function [Inc]=g1b1_income(Para,Data,Hdmm)
    Inc.t=sum((1-Para.epsilon).*Data.r.*Hdmm)/sum(Data.LL+Data.LH);
    Inc.ILN=Data.WL+Inc.t;
    Inc.ILW=Data.WL+Inc.t;
    Inc.IHN=Data.WH+Inc.t;
    Inc.IHW=Data.WH+Inc.t;
end


function [Para,Data,Norm]=g1a_import_data
% Assigned parameters
Para.alpha=0.24;
Para.beta=0.39;
Para.rho=0.29;
Para.beta_rho=Para.beta*Para.rho;
Para.etaL=3.029;
Para.etaH=4.128;
Para.thetaL=3.261;
Para.thetaH=4.976;

% Read data
MSA_data= readtable('../output/f2b_msa_level_input.csv');
State_data= readtable('../output/f2a_state_level_input.csv');
Network_support_eta=readtable('../output/f1c_network_support_eta.csv');
Migration_cost_theta=readtable('../output/f1a_migration_cost_theta.csv');
Dist_index=table2array(readtable('../output/e1_f2a_dist_index.csv'));
Kappa_index=table2array(readtable('../output/e1_f2a_kappa_index.csv'));

dL=table2array(Migration_cost_theta(:,2))./Para.thetaL;
dL=-[0;dL(1);dL(2:end)+dL(1)];
dH=table2array(Migration_cost_theta(:,3))./Para.thetaH;
dH=-[0;dH(1);dH(2:end)+dH(1)];
kappa_etaL=exp([0;table2array(Network_support_eta(:,2))]);
kappa_etaH=exp([0;table2array(Network_support_eta(:,3))]);
Para.dL=dL(Dist_index);
Para.dH=dH(Dist_index);
Para.kappa_etaL=kappa_etaL(Kappa_index);
Para.kappa_etaH=kappa_etaH(Kappa_index);

Norm.labor=mean(table2array(MSA_data(:,5)));
Data.NL=table2array(MSA_data(:,2))/Norm.labor;
Data.FL=table2array(MSA_data(:,3))/Norm.labor;
Data.NH=table2array(MSA_data(:,4))/Norm.labor;
Data.FH=table2array(MSA_data(:,5))/Norm.labor;
Data.LL=table2array(State_data(:,2))/Norm.labor;
Data.LH=table2array(State_data(:,3))/Norm.labor;

%Norm.wage=mean(table2array(MSA_data(:,6)));
%Data.WL=table2array(MSA_data(:,6))/Norm.wage;
%Data.WH=table2array(MSA_data(:,7))/Norm.wage;
Data.WL=table2array(MSA_data(:,6));
Data.WH=table2array(MSA_data(:,7));
Para.KH=Data.WH;
Para.KL=Data.WL;

%Norm.rent=mean(table2array(MSA_data(:,8)));
%Data.r=table2array(MSA_data(:,8))/Norm.rent;
Data.r=table2array(MSA_data(:,8));

Para.epsilon=table2array(MSA_data(:,9));

Para.ec1=(1-Para.alpha)^((1-Para.alpha))*Para.alpha^Para.alpha;
Para.ec2=(1-Para.alpha-Para.beta)^(1-Para.alpha-Para.beta)*Para.alpha^Para.alpha*Para.beta^Para.beta;
end
