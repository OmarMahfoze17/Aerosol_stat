clc ; clear all ; close all

Font=16;
Dir='/home/omar/Pictures';
FilesName='TwoPhaseNoShieldsNoNozzles_ToRun-2-';


% h5disp(fileName);

% h5disp(fileName,'/results/1/phase-1/particles/injection-2')
nPartTotal=368000;
xMin=-10;  xMax=10;
yMin=0;  yMax=2.3;
zMin=-10;  zMax=0;
partDimRang=[1 20]*10^(-6);

TimeRange=[500 1000];


nPartSub=[];
ITime=0;
for Time=TimeRange
    ITime=ITime+1;
    IPart=0;
    for partDim=partDimRang
    IPart=IPart+1;
    fileName=fullfile(Dir,num2str(Time,[FilesName,'%5.5i.dat.h5']));
    [~,nPartSub(ITime,IPart)]=getPartLoc(fileName,partDim,xMin,xMax,yMin,yMax,zMin,zMax)
    end

end


%%%%%   Plot the results
figure
set(axes,'FontSize',Font,'TickLabelInterpreter','latex')
hold on ; grid on ; box on ;
xlabel('Time(s)','Interpreter','Latex','FontSize',Font)
ylabel('Deposition Fraction(\%)','Interpreter','Latex','FontSize',Font)
plot(TimeRange/10,nPartSub(:,1)/nPartTotal*100,'k','LineWidth',2,'DisplayName',"$D=1\mu m$")
plot(TimeRange/10,nPartSub(:,2)/nPartTotal*100,'r','LineWidth',2,'DisplayName',"$D=20\mu m$")
% [x,y,z,t]

% legend('Dim =1 ', 'Dim=20')

legend('NumColumns',1,'Interpreter','Latex','FontSize',Font,'location','best','EdgeColor',[1 1 1])



function [nPartTotal,nPartSub]=getPartLoc(fileName,diamRng,xMin,xMax,yMin,yMax,zMin,zMax)


for I=0:1000

    try
        Diam = h5read(fileName,num2str(I,'/results/1/phase-1/particles/injection-%i/init_diameter'));
        if (single(diamRng)==Diam(1))
            break
        end
    catch
        error('File or Data not found')
    end
end
x = h5read(fileName,num2str(I,'/results/1/phase-1/particles/injection-%i/position_x'));
y = h5read(fileName,num2str(I,'/results/1/phase-1/particles/injection-%i/position_y'));
z = h5read(fileName,num2str(I,'/results/1/phase-1/particles/injection-%i/position_z'));
t = h5read(fileName,num2str(I,'/results/1/phase-1/particles/injection-%i/next_time_step'));
nPartTotal=length(x);



xSub=x(x>=xMin & x<xMax & y>=yMin & y<yMax & z>=zMin & z<zMax);


nPartSub=length(xSub);


% for I=1:length(diamRng)
%
%     time{I}=time{I}(Loc{I}(:,1)>=xMin & Loc{I}(:,1)<xMax & ...
%         Loc{I}(:,2)>=yMin & Loc{I}(:,2)<yMax & ...
%         Loc{I}(:,3)>=zMin & Loc{I}(:,3)<zMax);
%     time{I}=sort(time{I});
% end

end