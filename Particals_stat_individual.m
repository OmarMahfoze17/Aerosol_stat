clc
clear all
close all



fontSize=13;
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
for iDir=1:4;
    for iPass=1:60;
        [nP_pass{iPass}]=readDPM(fullfile(Dir{iDir},num2str(iPass,'passenger_%.2i.dpm')));
        [nP_mth{iPass}]=readDPM(fullfile(Dir{iDir},num2str(iPass,'mouth_%.2i.dpm')));
        nP_pass{iPass}=round(nP_pass{iPass}/nPartTotal*100,2);
        nP_mth{iPass}=round(nP_mth{iPass}/nPartTotal*100,2);
        
    end
    
    figure
    set(axes,'FontSize',fontSize,'TickLabelInterpreter','latex')
    hold on; grid on; box on;
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [.3, 0.2, 0.7, 0.5]);
    title(Dir{iDir}(end-20:end-1),'Interpreter','Latex','FontSize',12)
    dx=2;
    
    dy=.3;
    xlim([1 dx*11])
    ylim([dy dy*8.5])
    iPass=0;
    for I=1:10
        dyy=0;
        for J=1:6
            iPass=iPass+1;
            if J==4 ; dyy=dy*1; end
            text(I*dx, dy*9- (J*dy+dyy), num2str(nP_pass{iPass}(1)),...
                'Color','k','FontSize',fontSize,'Interpreter','Latex','BackgroundColor',[0 0 0 .1]);
            
            text(I*dx, dy*9- (J*dy+dyy)-dy/2, num2str(nP_mth{iPass}(1)),...
                'Color','r','FontSize',fontSize,'Interpreter','Latex','BackgroundColor',[1 0 0 .1]);
        end
    end
end
toc


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



