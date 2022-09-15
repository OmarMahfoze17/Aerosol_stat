clc
clear all
close all



fontSize=16;
SaveDir='/home/omar/WORK/results/Covid-19';
%%%%%%%%%%%%%%%%%%%%%%%   NOTE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Copy all the files in a subdirectory called ALL %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Dir{1}='/mnt/nvme1n1/WORK/Covid/Airbus/Data/AirBusProject/NoShieldsNoNozzles';
Dir{2}='/mnt/nvme1n1/WORK/Covid/Airbus/Data/AirBusProject/NoShieldsWithNozzles';
Dir{3}='/mnt/nvme1n1/WORK/Covid/Airbus/Data/AirBusProject/NoShieldsNoNozzles_OneInlet';
Dir{4}='/mnt/nvme1n1/WORK/Covid/Airbus/Data/AirBusProject/NoShieldsWithNozzles_OneInlet';

Color={'k','b','r'}

%%% Get total number of particals
tic
nPartTotal=368000;
% nPartTotal=338000;


szRng=[1]/10^6;
maxHigth=[0.4 .9 1.5];
minHigth=[-10 0.4 0.9];

for iDir=1:length(Dir)
    figure
set(axes,'FontSize',fontSize,'TickLabelInterpreter','latex')
hold on; grid on; box on;
   
    %%%%%%%%%%%%%%%%%%%%% PLOT All %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for ISz=1:length(maxHigth);   
        [nP_all,T_all,M_all]=get_nPart(fullfile(Dir{iDir},'ALL/*'),szRng,minHigth(ISz),maxHigth(ISz));
        T_all{1}(end+1)=300;

        myplot(T_all{1},[1:length(T_all{1})]/nPartTotal*100,Color{ISz},2,num2str([max(0,minHigth(ISz)),maxHigth(ISz)],'Y = %0.1f : %0.1f'),fontSize)
    end

xlim([0 300]);
%         ylim([0 60])
xlabel('Time(s)','Interpreter','Latex','FontSize',fontSize)
ylabel('Deposition Fraction(\%)','Interpreter','Latex','FontSize',fontSize)

legend('NumColumns',1,'Interpreter','Latex','FontSize',14,'location','best','EdgeColor',[1 1 1])
annotation('textbox', [0.4 0.95 0.05 0.05],'String',[Dir{iDir}(find(Dir{iDir}=='/',1,'last')+1:end)],'Interpreter','Latex','FontSize',14);
exportgraphics(gca, fullfile(SaveDir,['Total_',Dir{iDir}(find(Dir{iDir}=='/',1,'last')+1:end),'.pdf']), 'ContentType', 'vector');

end
%%%




function myplot(x,y,Clr,wdth,name,fontSize)
plot(x,y,Clr,'linewidth',wdth,'DisplayName',name)
try
    text(250, y(end)+0.5, num2str(y(end),'%3.1f\\%%'),...
        'Color',Clr(end),'FontSize',fontSize,'Interpreter','Latex','BackgroundColor','none');
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nPartTotal,time,MSS,Loc]=get_nPart(Dir,diamRng,minHigth,maxHigth)
fileinfo = dir(Dir);
nPartTotal=[0 0 0 0 0];
time=cell(size(diamRng));
MSS=cell(size(diamRng));
Loc=cell(length(diamRng));
for J=1:length(fileinfo)
    if fileinfo(J).isdir
        continue
    end
    [nPart,T,M,dRng,L]=readDPM(fullfile(fileinfo(J).folder,fileinfo(J).name));
    % error('vdsvs#')
    for I=1:length(dRng)
        II=find(diamRng==dRng(I));
        if isempty(II); continue ; end
        nPartTotal(II)=nPartTotal(II)+nPart(I);
        time{II}=[time{II};T{I}];
        MSS{II}=[MSS{II};M{I}];
        Loc{II}=[Loc{II};L{I}];

    end

end

for I=1:length(diamRng)

    time{I}=time{I}(Loc{I}(:,2)>=minHigth & Loc{I}(:,2)<=maxHigth);
    time{I}=sort(time{I});
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nPart,T,M,dRng,L]=readDPM(fileName)
% fileName
fileName;
fileID = fopen(fileName);

Data = textscan(fileID,'%n %n %n %n %n %n %n %n %n %n %n %n %n %s %s',...
    'TreatAsEmpty',{'NA','na','((','(',')'},'CommentStyle','%','headerLines',2);
fclose(fileID);
nPart=length(Data{2});
[dTot,sortInd]=sort(Data{8},'ascend');

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

% remove duplicates
% ID(:,1)=Data{15};
[~, w] = unique(Data{15}, 'stable' );
for I=1:length(Data)
    Data{I}=Data{I}(w);
end


%%%%%%%%%%%%%%%%% Separate Partical based on the partical size %%%%%%%%%%%%
for nSize=1:length(dRng)
    L{nSize}(:,1)=Data{2}(Data{8}==dRng(nSize),:);
    L{nSize}(:,2)=Data{3}(Data{8}==dRng(nSize),:);
    L{nSize}(:,3)=Data{4}(Data{8}==dRng(nSize),:);
    %
    %     V{nSize}(:,1)=Data{5}(Data{8}==dRng(nSize),:);
    %     V{nSize}(:,2)=Data{6}(Data{8}==dRng(nSize),:);
    %     V{nSize}(:,3)=Data{7}(Data{8}==dRng(nSize),:);

    D{nSize}(:,1)=Data{8}(Data{8}==dRng(nSize));
    T{nSize}(:,1)=Data{13}(Data{8}==dRng(nSize));
    M{nSize}(:,1)=Data{11}(Data{8}==dRng(nSize));

    ID{nSize}(:,1)=Data{15}(Data{8}==dRng(nSize));

    %     A=[1 2 3 3 5 0 0]
    %     [v,w]=unique(A)
    %     [v, w] = unique(ID{nSize}, 'stable' )
    %     duplicate_indices = setdiff( 1:numel(ID{nSize}), w )
    %     vsdvsv

    %%%%%%%%%%%%%% Time Sort %%%%%%%%%%%%%%%%%%%%%%%%%
    [T{nSize},sortInd]=sort(T{nSize},'ascend');
    %     L{nSize}=L{nSize}(sortInd,:);
    %     V{nSize}=V{nSize}(sortInd,:);
    D{nSize}=D{nSize}(sortInd,:);
    L{nSize}=L{nSize}(sortInd,:);
    M{nSize}=M{nSize}(sortInd,:);
    nPart(nSize)=length(T{nSize});
end

end


