clc
clear
cd 'C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\3ModelEstimation\code'

load('../output/g3_specify_counterfactuals.mat','Ori','BasicCn','Cn2000','Cn1990','Cn0','Option');

%% Main
Option.fsolve_opt=optimoptions('fsolve','OptimalityTolerance',1e-6,'StepTolerance',1e-6,'Display','none');
Option.fsolve_opt2=optimoptions('fsolve','OptimalityTolerance',1e-6,'StepTolerance',1e-6,'Display','iter-detailed');

%% Full Counterfactual

Cn0=g4A_main(Cn0,Ori,Option);

%BasicCn.Cn1=g4A_main(BasicCn.Cn1,Ori,Option);
%BasicCn.Cn2=g4A_main(BasicCn.Cn2,Ori,Option);
BasicCn.Cn3=g4A_main(BasicCn.Cn3,Ori,Option);
BasicCn.Cn4=g4A_main(BasicCn.Cn4,Ori,Option);

save('../output/g4A_counterfactual_results.mat','BasicCn','Cn0');




%% Function
function Cn=g4A_main(Cn,Ori,Option)
    LogPopDist0=log([Ori.Data.NL-Ori.Data.FL Ori.Data.FL Ori.Data.NH-Ori.Data.FH Ori.Data.FH]);
    LogPopDist=fsolve(@(LogPopDist)g4A_cou_solve(Cn,Ori,Option,LogPopDist),LogPopDist0,Option.fsolve_opt2);
    [~,Comp]=g4A_cou_solve(Cn,Ori,Option,LogPopDist);
    Cn.Solution=Comp;
end

function [x,Comp]=g4A_cou_solve(Cn,Ori,Option,LogPopDist)
    Comp=g4a_input_decode(Cn,LogPopDist);
    Comp=g4Ab_price_dist(Cn,Ori,Comp,Option);
    Comp=g4c_pop_dist(Cn,Comp);
    x=[Comp.NL;Comp.FL;Comp.NH;Comp.FH]-[Comp.NL1;Comp.FL1;Comp.NH1;Comp.FH1];
end

function Comp=g4c_pop_dist(Cn,Comp)
    PL_nbeta=(Comp.r.^(Cn.Cfund.rho).*Cn.Cfund.RL.^(-1)).^(-Cn.Cfund.beta);
    temp1=Cn.Counter.kappa_etaL.*(Cn.Cfund.ec2*Comp.ILW.*PL_nbeta).^Cn.Cfund.etaL;
    f=temp1./((Cn.Cfund.ec1*Comp.ILN).^Cn.Cfund.etaL+temp1);
    U=-Cn.Cfund.alpha*log(Comp.r)+exp(1)/Cn.Cfund.etaL+log(Cn.Cfund.ec1*Comp.ILN.*Cn.Cfund.AL)-log(1-f)./Cn.Cfund.etaL;
    Pi=exp(Cn.Cfund.thetaL*(U-Cn.Counter.dL));
    Comp.PiL=Pi./sum(Pi);
    Comp.NL1=Comp.PiL*Cn.Cfund.LL;
    Comp.FL1=f.*Comp.PiL*Cn.Cfund.LL;

    PH_nbeta=(Comp.r.^(Cn.Cfund.rho).*Cn.Cfund.RH.^(-1)).^(-Cn.Cfund.beta);
    temp1=Cn.Counter.kappa_etaH.*(Cn.Cfund.ec2*Comp.IHW.*PH_nbeta).^Cn.Cfund.etaH;
    f=temp1./((Cn.Cfund.ec1*Comp.IHN).^Cn.Cfund.etaH+temp1);
    U=-Cn.Cfund.alpha*log(Comp.r)+exp(1)/Cn.Cfund.etaH+log(Cn.Cfund.ec1*Comp.IHN.*Cn.Cfund.AH)-log(1-f)./Cn.Cfund.etaH;
    Pi=exp(Cn.Cfund.thetaH*(U-Cn.Counter.dH));
    Comp.PiH=Pi./sum(Pi);
    Comp.NH1=Comp.PiH*Cn.Cfund.LH;
    Comp.FH1=f.*Comp.PiH*Cn.Cfund.LH;
end

function Comp=g4a_input_decode(Cn,LogPopDist)
    PopDistL=exp(LogPopDist(:,1:2));
    PopDistH=exp(LogPopDist(:,3:4));

    PopDistL=sum(Cn.Cfund.LL)*PopDistL./sum(PopDistL,"all");
    Comp.NL=PopDistL(:,1)+PopDistL(:,2);
    Comp.FL=PopDistL(:,2);

    PopDistH=sum(Cn.Cfund.LH)*PopDistH./sum(PopDistH,"all");
    Comp.NH=PopDistH(:,1)+PopDistH(:,2);
    Comp.FH=PopDistH(:,2);
end


function Comp=g4Ab_price_dist(Cn,Ori,Comp,Option)
    Comp.r=Ori.Data.r;
    loghdmm0=(log(Comp.r)-Cn.Cfund.H_tilde)./((1-Cn.Cfund.epsilon)./Cn.Cfund.epsilon);
    loghdmm=fsolve(@(loghdmm)g4Ab1_solve_hdmm(Cn,Comp,loghdmm),loghdmm0,Option.fsolve_opt);
    [~,Comp]=g4Ab1_solve_hdmm(Cn,Comp,loghdmm);
end

function [x,Comp]=g4Ab1_solve_hdmm(Cn,Comp,loghdmm)
    Hdmm=exp(loghdmm);
    Comp=g4b1_obtain_income(Cn,Comp,Hdmm,Comp.r);
    x=g4b2_housing_clearing(Cn,Comp,Comp.r,Hdmm);
end

function Comp=g4b1_obtain_income(Cn,Comp,Hdmm,r)
    t=sum((1-Cn.Cfund.epsilon).*r.*Hdmm)/sum(Cn.Cfund.LL+Cn.Cfund.LH);
    Comp.ILN=Cn.Counter.WL+t;
    Comp.ILW=Cn.Counter.WL+t;
    Comp.IHN=Cn.Counter.WH+t;
    Comp.IHW=Cn.Counter.WH+t;
end

function x=g4b2_housing_clearing(Cn,Comp,r,Hdmm)
    temp1=Cn.Cfund.alpha*(Comp.ILN.*(Comp.NL-Comp.FL)+Comp.IHN.*(Comp.NH-Comp.FH));
    temp2=(Cn.Cfund.alpha+Cn.Cfund.beta_rho)*(Comp.ILW.*Comp.FL+Comp.IHW.*Comp.FH);
    x=Hdmm.*r-(temp1+temp2);
end
