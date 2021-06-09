clc
clear all
close all



fontSize=16

% Dir='/home/omarlocal/PhD/Writings/Papers/Covid-19/1Mic_full_noSheilds';
Dir='/home/omarlocal/PhD/Writings/Papers/Covid-19/Airbus/Data/NoShieldsNoNozzles';


nFiles=[15:23];

iFile=nFiles(1);



%%% Get total number of particals
tic
nPartTotal=300000;
% [nPartTotal,~]=get_nPart(Dir);
[nPartPass,tPass ]=get_nPart(fullfile(Dir,'passenger_*'));
[nPartMouth,tMouth ]=get_nPart(fullfile(Dir,'mouth_*'));
[nPartBack ]=get_nPart(fullfile(Dir,'back*'));
[nPartFront ]=get_nPart(fullfile(Dir,'front*'));
[nPartGround,tGround ]=get_nPart(fullfile(Dir,'ground*'));
% [nPartIn1 ]=get_nPart(fullfile(Dir,'inlet_x-*'));
% [nPartIn2 ]=get_nPart(fullfile(Dir,'inlet_x+*'));
[nPartIn ]=get_nPart(fullfile(Dir,'inlet*'));
% [nPartOut1 ]=get_nPart(fullfile(Dir,'outlet_left*'));
% [nPartOut2 ]=get_nPart(fullfile(Dir,'outlet_right*'));
[nPartOut,tOut ]=get_nPart(fullfile(Dir,'out*'));
toc
%%%


figure
set(axes,'FontSize',fontSize,'TickLabelInterpreter','latex')
hold on; grid on; box on;
myplot(tMouth,[1:length(tMouth)]/nPartTotal*100,'r',2,'Inhalable',fontSize)
myplot(tGround,[1:length(tGround)]/nPartTotal*100,'b',2,'Ground',fontSize)
myplot(tOut,[1:length(tOut)]/nPartTotal*100,'k',2,'Outlets',fontSize)
xlim([0 300])
xlabel('Time(s)','Interpreter','Latex','FontSize',fontSize)
ylabel('Deposition Fraction(\%)','Interpreter','Latex','FontSize',fontSize)

legend('Interpreter','Latex','FontSize',16,'location','best','EdgeColor',[1 1 1])

export_fig(fullfile(Dir,'Depos_time'), '-pdf','-transparent')
%%%

function myplot(x,y,Clr,wdth,name,fontSize)
    plot(x,y,Clr,'linewidth',wdth,'DisplayName',name)
    text(250, y(end)+0.5, num2str(y(end),'%3.1f\\%%'),...
    'Color',Clr,'FontSize',fontSize,'Interpreter','Latex','BackgroundColor','none');
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nPartTotal,time]=get_nPart(Dir)
fileinfo = dir(Dir);
nPartTotal=0;
time=[];
for I=1:length(fileinfo)
    if fileinfo(I).isdir
        continue
    end
[nPart,~,t,~,~]=readDPM(fullfile(fileinfo(I).folder,fileinfo(I).name));
nPartTotal=nPartTotal+nPart;
time=[time;t{I}];
end
time=sort(time);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nPart,Loc,time,vel,mass]=readDPM(fileName)
fileID = fopen(fileName);

Data = textscan(fileID,'%n %n %n %n %n %n %n %n %n %n %n %n %n %s %s',...
 'TreatAsEmpty',{'NA','na','((','(',')'},'CommentStyle','%','headerLines',2);
fclose(fileID);
[time,J]=sort(Data{13});
Loc(:,1)=Data{2}(J);
Loc(:,2)=Data{3}(J);
Loc(:,3)=Data{4}(J);

vel(:,1)=Data{5}(J);
vel(:,2)=Data{6}(J);
vel(:,3)=Data{7}(J);

d=Data{8}(J);
t=Data{9}(J);

parcel_mass=Data{10}(J);
diameter=Data{8}(J)
mass=Data{11}(J);

n_in_parcel=Data{12}(J);
nPart=length(time);
end














































































































