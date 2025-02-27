% clear;
% 
% T = readtable("/Users/okorenok/Library/CloudStorage/GoogleDrive-okorenok@vcu.edu/.shortcut-targets-by-id/1vOqkSb5CBZCZsEqddGjAdtTL_JGCmCg6/Public Signals and Information Aggregation/data/dataAllcontr.xlsx",Range="A1:M18522");
% T.time = T.TimeSellTradinuyerOffersSelect+T.TimeBuyTradingllerOffersSelect;
% for i=1:3
%      T.Period((T.treatment==2)&(T.Period==i))=i+7;
% end
% T1 = readtable("/Users/okorenok/Library/CloudStorage/GoogleDrive-okorenok@vcu.edu/.shortcut-targets-by-id/1vOqkSb5CBZCZsEqddGjAdtTL_JGCmCg6/Public Signals and Information Aggregation/data/dataAllsubj.xlsx",Range="A1:BQ2281");
% for i=1:3
%      T1.Period((T1.treatment==2)&(T1.Period==i))=i+7;
% end
% 
% 
% tab = [];
% for s = 1:16
%     for p = 1:10
% 
%         prT = T.Price((T.session_1==s)&(T.Period==p)&(T.time>0)&(T.time<=60));
%         V = T1.assetsDiv((T1.session1==s)&(T1.Period==p)&(T1.Subject==1));
%         [n,m] = size(prT);
% 
%         tab = [tab; [s*ones(n,1),p*ones(n,1),V*ones(n,1),prT]];
%     end
% end
% 
% writematrix(tab,'p.xlsx','Sheet',1,'Range','A2:D1673')

% T = readtable("/Users/okorenok/Library/CloudStorage/GoogleDrive-okorenok@vcu.edu/.shortcut-targets-by-id/1vOqkSb5CBZCZsEqddGjAdtTL_JGCmCg6/Public Signals and Information Aggregation/data/dataAllsubj.xlsx",Range="A1:BQ2281");
% for i=1:3
%     T.Period((T.treatment==2)&(T.Period==i))=i+7;
% end
% tab  = zeros(160,4);
% j = 0;
% for s = 1:16
%     for p = 1:10
%         j = j+1;
% 
%         numA0 = sum(T.numA0((T.session1==s)&(T.Period==p)));
%         numA1 = sum(T.numA1((T.session1==s)&(T.Period==p)));
%         numF0 = sum(T.numF0((T.session1==s)&(T.Period==p)));
%         numF1 = sum(T.numF1((T.session1==s)&(T.Period==p)));
%         V = T.assetsDiv((T.session1==s)&(T.Period==p)&(T.Subject==1));
% 
%         n_a = numA1;
%         na = numA1+numA0;
%         eta_a = 2*n_a - na;
%         n_f = numF1; % sum of 1s
%         nf = numF1+numF0;
%         eta_f = 2*n_f - nf;
%         p_a = 0.7;
%         p_f = 0.7;
%         if s<6
%             PFA = 100*1/(1 + ((1-p_a)/p_a)^eta_a) + 100*1/(1 + ((1-p_f)/p_f)^eta_f);
%         else
%             psigA = T.psigA((T.session1==s)&(T.Period==p)&(T.Subject==1));
%             if psigA==1
%                 S_a = 1;
%             else
%                 S_a = -1;
%             end
% 
%             if s<11
%                 pp_a = 0.7;
%             else
%                 pp_a = 0.9;
%             end
% 
%             PFA = 100*1/(1 + ((1-pp_a)/pp_a)^S_a*((1-p_a)/p_a)^eta_a) + 100*1/(1 + ((1-p_f)/p_f)^eta_f);
% 
% 
%         end
% 
%         tab(j,:) = [s,p,V,PFA];
%     end
% end
% 
% writematrix(tab,'pfa.xlsx','Sheet',1,'Range','A2:D161')
% 

clear;

T = readtable("/Users/okorenok/Library/CloudStorage/GoogleDrive-okorenok@vcu.edu/.shortcut-targets-by-id/1vOqkSb5CBZCZsEqddGjAdtTL_JGCmCg6/Public Signals and Information Aggregation/data/dataAllcontr.xlsx",Range="A1:M18522");
T.time = T.TimeSellTradinuyerOffersSelect+T.TimeBuyTradingllerOffersSelect;
for i=1:3
     T.Period((T.treatment==2)&(T.Period==i))=i+7;
end
T1 = readtable("/Users/okorenok/Library/CloudStorage/GoogleDrive-okorenok@vcu.edu/.shortcut-targets-by-id/1vOqkSb5CBZCZsEqddGjAdtTL_JGCmCg6/Public Signals and Information Aggregation/data/dataAllsubj.xlsx",Range="A1:BQ2281");
for i=1:3
     T1.Period((T1.treatment==2)&(T1.Period==i))=i+7;
end

tab  = zeros(160,11);
j = 0;
for s = 1:16
    for p = 1:10
        j = j+1;
        prT = mean(T.Price((T.session_1==s)&(T.Period==p)&(T.time>0)&(T.time<=60)));
        V = T1.assetsDiv((T1.session1==s)&(T1.Period==p)&(T1.Subject==1));
        A = T1.stA((T1.session1==s)&(T1.Period==p)&(T1.Subject==1));
        F = T1.stF((T1.session1==s)&(T1.Period==p)&(T1.Subject==1));
        pS = T1.psigA((T1.session1==s)&(T1.Period==p)&(T1.Subject==1));
        avB = mean(T1.expV((T1.session1==s)&(T1.Period==p)));
        medB = median(T1.expV((T1.session1==s)&(T1.Period==p)));
        avAsig = mean(T1.sigA((T1.session1==s)&(T1.Period==p)));
        avFsig = mean(T1.sigF((T1.session1==s)&(T1.Period==p)));
        tab(j,:) = [s,p,A,F,V,prT,pS,avB,medB,avAsig,avFsig];
    end
end

writematrix(tab,'fcst1.xlsx','Sheet',1,'Range','A2:K161')
