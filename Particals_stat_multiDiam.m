clc
clear all
close all



fontSize=16;
SaveDir='/home/omarlocal/PhD/Writings/Papers/Covid-19/Airbus/Data';
% Dir='/home/omarlocal/PhD/Writings/Papers/Covid-19/1Mic_full_noSheilds';
Dir{1}='/home/omarlocal/PhD/Writings/Papers/Covid-19/Airbus/Data/NoShieldsNoNozzles';
Dir{2}='/home/omarlocal/PhD/Writings/Papers/Covid-19/Airbus/Data/NoShieldsWithNozzles';
Dir{3}='/home/omarlocal/PhD/Writings/Papers/Covid-19/Airbus/Data/WithShieldsNoNozzles';
Dir{4}='/home/omarlocal/PhD/Writings/Papers/Covid-19/Airbus/Data/WithShieldsWithNozzles';



%%% Get total number of particals
tic
nPartTotal=338000;
% [nPartTotal,~]=get_nPart(Dir);
% [nPart,T,M,dRng]=readDPM(fullfile(Dir,'passenger_29.dpm'));

% figure(1)
% set(axes,'FontSize',fontSize,'TickLabelInterpreter','latex')
% hold on; grid on; box on;
szRng=[1]/10^6;
for iDir=1:4
    [nP_pass,T_pass,M_pass]=get_nPart(fullfile(Dir{iDir},'passenger_*'),szRng);
    [nP_mth,T_mth,M_mth]=get_nPart(fullfile(Dir{iDir},'mouth_*'),szRng);
    [nP_out,T_out,M_out]=get_nPart(fullfile(Dir{iDir},'outlet*'),szRng);
    [nP_grd,T_grd,M_grd]=get_nPart(fullfile(Dir{iDir},'ground*'),szRng);
    [nP_st,T_st,M_st]=get_nPart(fullfile(Dir{iDir},'seats*'),szRng);
    [nP_wll,T_wll,M_wll]=get_nPart(fullfile(Dir{iDir},'walls/*'),szRng);
    Escaped = nP_out+nP_mth
    try [nP_sld,T_sld,M_sld]=get_nPart(fullfile(Dir{iDir},'*shields*'),szRng); end
    DepositedPart(iDir,:)=nP_pass+nP_mth+nP_out+nP_grd+nP_st+nP_wll;
    try DepositedPart(iDir,:)=DepositedPart(iDir,:)+nP_sld; end
    for ISz=1:length(szRng);
        figure
        set(axes,'FontSize',fontSize,'TickLabelInterpreter','latex')
        % title(Dir{iDir}(end-20:end-1),'Interpreter','Latex','FontSize',10)
        hold on; grid on; box on;
        
        myplot(T_pass{ISz},[1:length(T_pass{ISz})]/nPartTotal*100,'k',2,'Passangers',fontSize)
        myplot(T_mth{ISz},[1:length(T_mth{ISz})]/nPartTotal*100,'r',2,'Inhalable',fontSize)
        myplot(T_out{ISz},[1:length(T_out{ISz})]/nPartTotal*100,'g',2,'Outlets',fontSize)
        myplot(T_grd{ISz},[1:length(T_grd{ISz})]/nPartTotal*100,'b',2,'Ground',fontSize)
        myplot(T_st{ISz},[1:length(T_st{ISz})]/nPartTotal*100,'c',2,'Seats',fontSize)
        myplot(T_grd{ISz},[1:length(T_grd{ISz})]/nPartTotal*100,'b',2,'Ground',fontSize)
        myplot(T_wll{ISz},[1:length(T_wll{ISz})]/nPartTotal*100,'m',2,'Walls',fontSize)
        try; myplot(T_sld{ISz},[1:length(T_sld{ISz})]/nPartTotal*100,'--r',2,'Shields',fontSize); end
        
        xlim([0 300]);
        ylim([0 60])
        xlabel('Time(s)','Interpreter','Latex','FontSize',fontSize)
        ylabel('Deposition Fraction(\%)','Interpreter','Latex','FontSize',fontSize)
        
        legend('NumColumns',4,'Interpreter','Latex','FontSize',14,'location','northoutside','EdgeColor',[1 1 1])
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.3, 0.6]);
        annotation('textbox', [0.4 0.95 0.05 0.05],'String',Dir{iDir}(end-20:end-1),'Interpreter','Latex','FontSize',14);  
%         export_fig(fullfile(Dir{iDir},num2str([ISz],'Depos_time_size-%i')), '-pdf','-transparent')
    end
end
%%%

function myplot(x,y,Clr,wdth,name,fontSize)
plot(x,y,Clr,'linewidth',wdth,'DisplayName',name)

text(250, y(end)+0.5, num2str(y(end),'%3.1f\\%%'),...
    'Color',Clr(end),'FontSize',fontSize,'Interpreter','Latex','BackgroundColor','none');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nPartTotal,time,MSS]=get_nPart(Dir,diamRng)
fileinfo = dir(Dir);
nPartTotal=[0 0 0 0 0];
time=cell(size(diamRng));
MSS=cell(size(diamRng));
for I=1:length(fileinfo)
    if fileinfo(I).isdir
        continue
    end
    [nPart,T,M,dRng]=readDPM(fullfile(fileinfo(I).folder,fileinfo(I).name));
    
    % error('vdsvs#')
    for I=1:length(dRng)
        II=find(diamRng==dRng(I));
        if isempty(II); continue ; end
        nPartTotal(II)=nPartTotal(II)+nPart(I);
        time{II}=[time{II};T{I}];
        MSS{II}=[MSS{II};M{I}];
    end
    
end
for I=1:length(diamRng)
    time{I}=sort(time{I});
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nPart,T,M,dRng]=readDPM(fileName)
% fileName
fileID = fopen(fileName);

Data = textscan(fileID,'%n %n %n %n %n %n %n %n %n %n %n %n %n %s %s',...
    'TreatAsEmpty',{'NA','na','((','(',')'},'CommentStyle','%','headerLines',2);
fclose(fileID);
nPart=length(Data{2});
[dTot,sortInd]=sort(Data{8},'ascend');
% Loc(:,1)=Data{2};
% Loc(:,2)=Data{3};
% Loc(:,3)=Data{4};
% vel(:,1)=Data{5};
% vel(:,2)=Data{6};
% vel(:,3)=Data{7};
% diam=Data{8};
% tme=Data{13};
% parcel_mass=Data{10}
% mass=Data{11}
%%%%%%%%%%%%%%%%% get the order of the particals sizes
if nPart==0
    dRng=[];T=[];L=[];V=[];D=[];M=[];nPart=0;
else
    dRng= dTot(1);
end
ii=1;
for i=1:nPart
    if (dRng(end)~=dTot(i))
        dRng=[dRng;dTot(i)];
    end
end

% dRng
%%%%%%%%%%%%%%%%% Separate Partical based on the partical size %%%%%%%%%%%%
for nSize=1:length(dRng)
    L{nSize}(:,1)=Data{2}(Data{8}==dRng(nSize),:);
    L{nSize}(:,2)=Data{3}(Data{8}==dRng(nSize),:);
    L{nSize}(:,3)=Data{4}(Data{8}==dRng(nSize),:);
    
    V{nSize}(:,1)=Data{5}(Data{8}==dRng(nSize),:);
    V{nSize}(:,2)=Data{6}(Data{8}==dRng(nSize),:);
    V{nSize}(:,3)=Data{7}(Data{8}==dRng(nSize),:);
    
    D{nSize}(:,1)=Data{8}(Data{8}==dRng(nSize));
    T{nSize}(:,1)=Data{13}(Data{8}==dRng(nSize));
    M{nSize}(:,1)=Data{11}(Data{8}==dRng(nSize));
    %%%%%%%%%%%%%% Time Sort %%%%%%%%%%%%%%%%%%%%%%%%%
    [T{nSize},sortInd]=sort(T{nSize},'ascend');
    L{nSize}=L{nSize}(sortInd,:);
    V{nSize}=V{nSize}(sortInd,:);
    D{nSize}=D{nSize}(sortInd,:);
    M{nSize}=M{nSize}(sortInd,:);
    nPart(nSize)=length(T{nSize});
end
%  M{1:2}
% D{1}
% nPart
% T{1}
end



