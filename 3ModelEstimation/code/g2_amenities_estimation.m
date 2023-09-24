clc
clear
cd 'C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\3ModelEstimation\code'

load('../output/g1_production_side.mat','Data','Fund','Inc','Norm','Para');

Option.fsolve_opt=optimoptions('fsolve','OptimalityTolerance',1e-6,'StepTolerance',1e-6,'Display','none');

%% Main
Comp=g2a_generate_initial_guess(Para,Data,Option);
Comp=g2b_solve_for_adjusted_amenities(Para,Data,Comp,Option);
Fund=g2b_solve_for_amenities(Para,Data,Comp,Inc,Fund);
save('../output/g2_completed_calibration.mat','Data','Fund','Inc','Norm','Para','Option','Comp');

%% Draw Graph
logr=log(Data.r);
logRL=log(Fund.RL)-mean(log(Fund.RL));
logRH=log(Fund.RH)-mean(log(Fund.RH));


ax1 = figure(1);

hold on

scatter(logr,logRL,[],"red","o")
lsline

scatter(logr,logRH,[],"blue","x")
lsline
h = lsline;
set(h(1),'color','b')
set(h(2),'color','red')
    
legend('low skill','','high skill')
xlabel('Log rent')
ylabel('Log R_d^e')
hold off

exportgraphics(ax1,'../object/g2_price_dist.png')

%% Alternative, set kappa equal 1
clc
clear
cd 'C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\3ModelEstimation\code'

load('../output/g1_production_side.mat','Data','Fund','Inc','Norm','Para');

Para.kappa_etaL=ones(size(Para.kappa_etaL,1),size(Para.kappa_etaL,2));
Para.kappa_etaH=ones(size(Para.kappa_etaH,1),size(Para.kappa_etaH,2));

Option.fsolve_opt=optimoptions('fsolve','OptimalityTolerance',1e-6,'StepTolerance',1e-6,'Display','none');

%% Main
Comp=g2a_generate_initial_guess(Para,Data,Option);
Comp=g2b_solve_for_adjusted_amenities(Para,Data,Comp,Option);
Fund=g2b_solve_for_amenities(Para,Data,Comp,Inc,Fund);
NoKappaFund=Fund;
save('../output/g2_completed_calibration_nokappa.mat','NoKappaFund');

%% Draw Graph
logr=log(Data.r);
logRL=log(Fund.RL)-mean(log(Fund.RL));
logRH=log(Fund.RH)-mean(log(Fund.RH));


ax1 = figure(2);

hold on

scatter(logr,logRL,[],"red","o")
lsline

scatter(logr,logRH,[],"blue","x")
lsline
h = lsline;
set(h(1),'color','b')
set(h(2),'color','red')
    
legend('low skill','','high skill')
xlabel('Log rent')
ylabel('Log R_d^e')
hold off

exportgraphics(ax1,'../object/g2_price_dist_nokappa.png')


%% Function
function Fund=g2b_solve_for_amenities(Para,Data,Comp,Inc,Fund)
    Fund.AL=exp(Comp.logAAnL).^(1/Para.etaL)./(Para.ec1*Inc.ILN);
    Fund.RL=(exp(Comp.logAAwL).^(1/Para.etaL)./(Para.ec2*Fund.AL.*Data.r.^(-Para.beta_rho).*Inc.ILW)).^(1/(Para.beta));
    %Fund.PL=Data.r.^(Para.rho).*Fund.RL.^(Para.rho-1);

    Fund.AH=exp(Comp.logAAnH).^(1/Para.etaH)./(Para.ec1*Inc.IHN);
    Fund.RH=(exp(Comp.logAAwH).^(1/Para.etaH)./(Para.ec2*Fund.AH.*Data.r.^(-Para.beta_rho).*Inc.IHW)).^(1/(Para.beta));
    %Fund.PH=Data.r.^(Para.rho).*Fund.RH.^(Para.rho-1);
end


function Comp=g2b_solve_for_adjusted_amenities(Para,Data,Comp,Option)
    educ=0;
    for i=1:20
        Comp=g2b1_obtain_f(Para,Comp,educ);
        Comp.logAAnL1=fsolve(@(logAAn) g2b2_obtain_AAn1(Para,Data,Comp,educ,logAAn),Comp.logAAnL0,Option.fsolve_opt);
        [~,Comp.PiL]= g2b2_obtain_AAn1(Para,Data,Comp,educ,Comp.logAAnL1);
        Comp.logAAwL1=fsolve(@(logAAw) g2b3_obtain_AAw1(Para,Data,Comp,educ,logAAw),Comp.logAAwL0,Option.fsolve_opt);
        [Comp,x]=g2b4_update_and_normalize(Comp,educ);
    end
    if x>1e-10
       warning('AAL fails to converge') 
    end
    Comp.logAAnL=Comp.logAAnL1;
    Comp.logAAwL=Comp.logAAwL1;

    educ=1;
    for i=1:20
        Comp=g2b1_obtain_f(Para,Comp,educ);
        Comp.logAAnH1=fsolve(@(logAAn) g2b2_obtain_AAn1(Para,Data,Comp,educ,logAAn),Comp.logAAnH0,Option.fsolve_opt);
        [~,Comp.PiH]= g2b2_obtain_AAn1(Para,Data,Comp,educ,Comp.logAAnH1);
        Comp.logAAwH1=fsolve(@(logAAw) g2b3_obtain_AAw1(Para,Data,Comp,educ,logAAw),Comp.logAAwH0,Option.fsolve_opt);
        [Comp,x]=g2b4_update_and_normalize(Comp,educ);
    end
    if x>1e-10
       warning('AAH fails to converge') 
    end
    Comp.logAAnH=Comp.logAAnH1;
    Comp.logAAwH=Comp.logAAwH1;
end

function [Comp,x]=g2b4_update_and_normalize(Comp,educ)
    if educ==0
        meanc=mean([Comp.logAAnL1;Comp.logAAwL1],"all");
        Comp.logAAwL1=Comp.logAAwL1-meanc;
        Comp.logAAnL1=Comp.logAAnL1-meanc;
        x=norm([Comp.logAAnL1;Comp.logAAwL1]-[Comp.logAAnL0;Comp.logAAwL0]);
        Comp.logAAwL0=Comp.logAAwL1;
        Comp.logAAnL0=Comp.logAAnL1;
    elseif educ==1
        meanc=mean([Comp.logAAnH1;Comp.logAAwH1],"all");
        Comp.logAAwH1=Comp.logAAwH1-meanc;
        Comp.logAAnH1=Comp.logAAnH1-meanc;
        x=norm([Comp.logAAnH1;Comp.logAAwH1]-[Comp.logAAnH0;Comp.logAAwH0]);
        Comp.logAAwH0=Comp.logAAwH1;
        Comp.logAAnH0=Comp.logAAnH1;
    end
end

function x=g2b3_obtain_AAw1(Para,Data,Comp,educ,logAAw)
        AAw=exp(logAAw);
    if educ==0
        f=Para.kappa_etaL.*AAw./(exp(Comp.logAAnL1)+Para.kappa_etaL.*AAw);
        x=Data.FL-(Comp.PiL.*f)*Data.LL;
    elseif educ==1
        f=Para.kappa_etaH.*AAw./(exp(Comp.logAAnH1)+Para.kappa_etaH.*AAw);
        x=Data.FH-(Comp.PiH.*f)*Data.LH;
    end
end

function [x,Pi]=g2b2_obtain_AAn1(Para,Data,Comp,educ,logAAn)
    if educ==0
        U=g2b2a_obtain_U(Para,Data,Comp,educ,logAAn);
        Pi=exp(Para.thetaL*(U-Para.dL));
        Pi=Pi./sum(Pi);
        x=Data.NL-Pi*Data.LL;
    elseif educ==1
        U=g2b2a_obtain_U(Para,Data,Comp,educ,logAAn);
        Pi=exp(Para.thetaH*(U-Para.dH));
        Pi=Pi./sum(Pi);
        x=Data.NH-Pi*Data.LH;
    end
end

function U=g2b2a_obtain_U(Para,Data,Comp,educ,logAAn)
    if educ==0
        U=-Para.alpha*log(Data.r)+exp(1)/Para.etaL-log(1-Comp.fL)/Para.etaL+logAAn/Para.etaL;
    elseif educ==1
        U=-Para.alpha*log(Data.r)+exp(1)/Para.etaH-log(1-Comp.fH)/Para.etaH+logAAn/Para.etaH;
    end
end


function Comp=g2b1_obtain_f(Para,Comp,educ)
    if educ==0
        Comp.fL=Para.kappa_etaL.*exp(Comp.logAAwL0)./(exp(Comp.logAAnL0)+Para.kappa_etaL.*exp(Comp.logAAwL0));
    elseif educ==1
        Comp.fH=Para.kappa_etaH.*exp(Comp.logAAwH0)./(exp(Comp.logAAnH0)+Para.kappa_etaH.*exp(Comp.logAAwH0));
    end
end

function Comp=g2a_generate_initial_guess(Para,Data,Option)
    educ=0;
    Comp.fL=Data.FL./Data.NL;
    [Comp.UL]=fsolve(@(U)g2a1_initial_Ud(Para,Data,educ,U),ones(length(Data.NL),1),Option.fsolve_opt);
    [~,Comp.PiL]=g2a1_initial_Ud(Para,Data,educ,Comp.UL);
    Comp.logAAnL0=g2a2_adjusted_An(Para,Data,Comp,educ);
    Comp.logAAwL0=fsolve(@(logAAw)g2a3_adjusted_Aw(Data,Comp,educ,logAAw),Comp.logAAnL0,Option.fsolve_opt);

    educ=1;
    Comp.fH=Data.FH./Data.NH;
    [Comp.UH]=fsolve(@(U)g2a1_initial_Ud(Para,Data,educ,U),ones(length(Data.NH),1),Option.fsolve_opt);
    [~,Comp.PiH]=g2a1_initial_Ud(Para,Data,educ,Comp.UH);
    Comp.logAAnH0=g2a2_adjusted_An(Para,Data,Comp,educ);
    Comp.logAAwH0=fsolve(@(logAAw)g2a3_adjusted_Aw(Data,Comp,educ,logAAw),Comp.logAAnH0,Option.fsolve_opt);

    %normalize logAA
    meanc=mean([Comp.logAAnL0;Comp.logAAwL0],"all");
    Comp.logAAwL0=Comp.logAAwL0-meanc;
    Comp.logAAnL0=Comp.logAAnL0-meanc;

    meanc=mean([Comp.logAAnH0;Comp.logAAwH0],"all");
    Comp.logAAwH0=Comp.logAAwH0-meanc;
    Comp.logAAnH0=Comp.logAAnH0-meanc;
end


function x=g2a3_adjusted_Aw(Data,Comp,educ,logAAw)
    AAw=exp(logAAw);
    if educ==0
        f=AAw./(exp(Comp.logAAnL0)+AAw);
        x=Data.FL-(Comp.PiL.*f)*Data.LL;
    elseif educ==1
        f=AAw./(exp(Comp.logAAnH0)+AAw);
        x=Data.FH-(Comp.PiH.*f)*Data.LH;
    end
end

function logAAn=g2a2_adjusted_An(Para,Data,Comp,educ)
    if educ==0
        AAn=Comp.UL+Para.alpha*log(Data.r)-exp(1)/Para.etaL+log(1-Comp.fL)/Para.etaL;
        AAn=exp(AAn).^Para.etaL;
        logAAn=log(AAn);
    elseif educ==1
        AAn=Comp.UH+Para.alpha*log(Data.r)-exp(1)/Para.etaH+log(1-Comp.fH)/Para.etaH;
        AAn=exp(AAn).^Para.etaH;
        logAAn=log(AAn);
    end
end

function [x,Pi]=g2a1_initial_Ud(Para,Data,educ,U)
    if educ==0
        Pi=exp(Para.thetaL*(U-Para.dL));
        Pi=Pi./sum(Pi);
        x=Data.NL-Pi*Data.LL;
    elseif educ==1
        Pi=exp(Para.thetaH*(U-Para.dH));
        Pi=Pi./sum(Pi);
        x=Data.NH-Pi*Data.LH;
    end
end
