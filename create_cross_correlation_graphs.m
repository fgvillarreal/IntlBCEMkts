clear all
clc

% change to the folder that contains 'data_results_hp.xlsx'
cd C:\Users\rothert\Dropbox\work\research\emrers\data\


variables  = {'gdp';'con';'inv';'nxy';'iratio';'irate'};
variables2 = {'GDP';'C';'I';'NX';'ImpRatio';'R'};
for iv = 1:length(variables)
   varname  = variables{iv}; 
   varname2 = variables2{iv}; 
sheet_name = strcat('xc_',varname,'_rex');
xcor_rex.(varname2) = readtable('data_results_hp.xlsx','Sheet',sheet_name,'ReadRowNames',true);
end
% 
% xcor_dev = readtable('data_results_hp.xlsx','Sheet','xc_rex_dev','ReadRowNames',true);
% xcor_emg = readtable('data_results_hp.xlsx','Sheet','xc_rex_emg','ReadRowNames',true);
% xcor_can = readtable('data_results_hp.xlsx','Sheet','xc_rex_can','ReadRowNames',true);
% xcor_mex = readtable('data_results_hp.xlsx','Sheet','xc_rex_mex','ReadRowNames',true);


columns = {'t_4';'t_3';'t_2';'t_1';'t';'t1';'t2';'t3';'t4'};


for i = 1:length(variables2)
    var = variables2{i};    
    xcors.(var) = zeros(9,9);
    for t = 1:9
        colmn = columns{t};        
        xcors.(var)(2,t) = xcor_rex.(var).(colmn)('Developed')+ xcor_rex.(var).(colmn)('Developed_se');
        xcors.(var)(3,t) = xcor_rex.(var).(colmn)('Developed');
        xcors.(var)(4,t) = xcor_rex.(var).(colmn)('Developed')- xcor_rex.(var).(colmn)('Developed_se');
        xcors.(var)(5,t) = xcor_rex.(var).(colmn)('Emerging') + xcor_rex.(var).(colmn)('Emerging_se');
        xcors.(var)(6,t) = xcor_rex.(var).(colmn)('Emerging');
        xcors.(var)(7,t) = xcor_rex.(var).(colmn)('Emerging') - xcor_rex.(var).(colmn)('Emerging_se');
        xcors.(var)(8,t) = xcor_rex.(var).(colmn)('Mexico');
        xcors.(var)(9,t) = xcor_rex.(var).(colmn)('Canada');
    end
    if strcmp(var,'ImpRatio') == 1
        xcors.(var)(2:9,:) = inf;
    end
end

% change to the folder where you want to save the graphs
cd graphs\hp

for nn = 1:length(variables2)
    fig = figure(nn);
    var = variables2{nn};
    axes1 = axes('Parent',fig);
    tittle = strcat('corr(',variables2{nn},'_t,RER_{t+j})');
    h1 = plot(xcors.(var)(1,:)','Color','r','LineWidth',1); hold on
    h2 = plot(xcors.(var)(2,:)','--','Color','b','LineWidth',0.5,'DisplayName','95% bounds');
    h3 = plot(xcors.(var)(3,:)','Color','b','LineWidth',2,'DisplayName','Developed   ');
    h4 = plot(xcors.(var)(4,:)','--','Color','b','LineWidth',0.5);
    h5 = plot(xcors.(var)(5,:)','--','Color','k','LineWidth',0.5);
    h6 = plot(xcors.(var)(6,:)','Color','k','LineWidth',2,'DisplayName','Emerging   ');
    h7 = plot(xcors.(var)(7,:)','--','Color','k','LineWidth',0.5,'DisplayName','95% bounds'); 
    h8 = plot(xcors.(var)(8,:)','-o','Color','k','LineWidth',2.5,'DisplayName','Mexico   '); 
    h9 = plot(xcors.(var)(9,:)','-o','Color','b','LineWidth',2.5,'DisplayName','Canada   '); hold off
    title(tittle,'FontSize',18);
    %ylim([-1,1])
    xlim([1,9])
    set(axes1,'FontSize',16,'XTick',[1 2 3 4 5 6 7 8 9],'XTickLabel',...
    {'-4','-3','-2','-1','0','1','2','3','4'},'YTick',[-1 -0.5 0 0.5 1]);
    xlabel('j^{th} lead / lag','FontSize',16)
    if strcmp(var,'ImpRatio') == 1
        title(' ','FontSize',18);
    set(axes1,'FontSize',16,'XTick',[],'YTick',[]);
        xlabel('')
    legend([h3,h2,h6,h7,h8,h9],'Location','best',{},'FontSize',20,'NumColumns',3)    
    end
    figname = strcat('xcor_',var,'_rex.pdf');
    print(fig,figname,'-dpdf')
end



