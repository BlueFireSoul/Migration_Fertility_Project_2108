clc
clear
cd 'C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\3ModelEstimation\code'

load('../output/g2_completed_calibration.mat','Data','Fund','Inc','Norm','Para','Option');

Ori.Data=Data;
Ori.Fund=Fund;
Ori.Inc=Inc;
Ori.Norm=Norm;
Ori.Para=Para;

Cn0.Counter.dL=Para.dL;
Cn0.Counter.dH=Para.dH;
Cn0.Counter.WL=Data.WL;
Cn0.Counter.WH=Data.WH;
Cn0.Counter.kappa_etaL=Para.kappa_etaL;
Cn0.Counter.kappa_etaH=Para.kappa_etaH;

Cn0.Cfund=Fund;
Cn0.Cfund.LL=Data.LL;
Cn0.Cfund.LH=Data.LH;
Cn0.Cfund.alpha=Para.alpha;
Cn0.Cfund.beta=Para.beta;
Cn0.Cfund.rho=Para.rho;
Cn0.Cfund.beta_rho=Para.beta_rho;
Cn0.Cfund.etaL=Para.etaL;
Cn0.Cfund.etaH=Para.etaH;
Cn0.Cfund.thetaL=Para.thetaL;
Cn0.Cfund.thetaH=Para.thetaH;
Cn0.Cfund.epsilon=Para.epsilon;
Cn0.Cfund.ec1=Para.ec1;
Cn0.Cfund.ec2=Para.ec2;

%%
BasicCn.Cn1=Cn0;
BasicCn.Cn1.Counter.dL=Para.dL*1.5;
BasicCn.Cn1.Counter.dH=Para.dH*1.5;

BasicCn.Cn2=Cn0;
BasicCn.Cn2.Counter.dL=Para.dL*0.5;
BasicCn.Cn2.Counter.dH=Para.dH*0.5;

BasicCn.Cn3=Cn0;
BasicCn.Cn3.Counter.kappa_etaL=ones(size(Para.kappa_etaL,1),size(Para.kappa_etaL,2))*max(Para.kappa_etaL,[],"all");
BasicCn.Cn3.Counter.kappa_etaH=ones(size(Para.kappa_etaH,1),size(Para.kappa_etaH,2))*max(Para.kappa_etaH,[],"all");

BasicCn.Cn4=Cn0;
BasicCn.Cn4.Counter.kappa_etaL=ones(size(Para.kappa_etaL,1),size(Para.kappa_etaL,2));
BasicCn.Cn4.Counter.kappa_etaH=ones(size(Para.kappa_etaH,1),size(Para.kappa_etaH,2));

BasicCn.Cn5=Cn0;
BasicCn.Cn5.Counter.WL=Data.WL*5;
BasicCn.Cn5.Counter.WH=Data.WH*5;

BasicCn.Cn6=Cn0;
BasicCn.Cn6.Counter.WL=Data.WL*0.2;
BasicCn.Cn6.Counter.WH=Data.WH*0.2;

%%
Cn2000.Cn1=Cn0;
Met2000inc=table2array(readtable('../output/h1d_2000met2013_inc.csv'));
Cn2000.Cn1.Counter.WL=1.5*Met2000inc(:,2);
Cn2000.Cn1.Counter.WH=1.5*Met2000inc(:,3);

Cn2000.Cn2=Cn0;
Dist_index=table2array(readtable('../output/e1_f2a_dist_index.csv'));
Migration_cost_theta=readtable('../output/h1b_migration_cost_theta.csv');
dL=table2array(Migration_cost_theta(:,2))./Para.thetaL;
dL=-[0;dL(1);dL(2:end)+dL(1)];
dH=table2array(Migration_cost_theta(:,3))./Para.thetaH;
dH=-[0;dH(1);dH(2:end)+dH(1)];
Cn2000.Cn2.Counter.dL=dL(Dist_index);
Cn2000.Cn2.Counter.dH=dH(Dist_index);

Cn2000.Cn3=Cn0;
Cn2000.Cn3.Counter.WL=1.5*Met2000inc(:,2);
Cn2000.Cn3.Counter.WH=1.5*Met2000inc(:,3);
Cn2000.Cn3.Counter.dL=dL(Dist_index);
Cn2000.Cn3.Counter.dH=dH(Dist_index);

%%
Cn1990.Cn1=Cn0;
Met1990inc=table2array(readtable('../output/h2d_1990met2013_inc.csv'));
Cn1990.Cn1.Counter.WL=1.96*Met1990inc(:,2);
Cn1990.Cn1.Counter.WH=1.96*Met1990inc(:,3);

Cn1990.Cn2=Cn0;
Dist_index=table2array(readtable('../output/e1_f2a_dist_index.csv'));
Migration_cost_theta=readtable('../output/h2b_migration_cost_theta.csv');
dL=table2array(Migration_cost_theta(:,2))./Para.thetaL;
dL=-[0;dL(1);dL(2:end)+dL(1)];
dH=table2array(Migration_cost_theta(:,3))./Para.thetaH;
dH=-[0;dH(1);dH(2:end)+dH(1)];
Cn1990.Cn2.Counter.dL=dL(Dist_index);
Cn1990.Cn2.Counter.dH=dH(Dist_index);

Cn1990.Cn3=Cn0;
Cn1990.Cn3.Counter.WL=1.96*Met1990inc(:,2);
Cn1990.Cn3.Counter.WH=1.96*Met1990inc(:,3);
Cn1990.Cn3.Counter.dL=dL(Dist_index);
Cn1990.Cn3.Counter.dH=dH(Dist_index);

%%
save('../output/g3_specify_counterfactuals.mat','Ori','BasicCn','Cn2000','Cn1990','Cn0','Option');