%% plotvars
colormap = [0, 0.4470, 0.7410;0.8500, 0.3250, 0.0980;0.9290, 0.6940, 0.1250;0.4940, 0.1840, 0.5560];
psvec = -999:4000;
lenny = length(decode.sample);
fs = 16;
xaxlab = "time from taste delivery (ms)";

%% avg plot
psvec = -999:4000;
lenny = length(decode.sample); 
avgplot = figure('Units','Centimeters','Position', [0 0 8 14])
for i = 1:4
    subplot(5,1, i)
    pltArr = squeeze(decode.avg(:,i,1001:6000));
    clear gca
    plot(psvec,pltArr, 'LineWidth', 2)
    hold on
    line(decode.sample-1999, ones(lenny,1)*decode.winavg(i,i),'Color', colormap(i,:),'LineWidth', 2, 'LineStyle','--');
    hold off
    ttl = title([decode.tastants{i} ' delivered'])
    ylab = ylabel({'p(taste)'})
    xlim([-1000 4000])
    ylim([0 1])
    if i == 4
        xlab = xlabel(xaxlab) 
    end
    fontsize = set(gca,'FontSize',fs)
end
lgnd = legend({"Salty", "Sweet", "Sour", "Bitter","None"},'Orientation','horizontal','Position',[0.2 0.19 0.6 0.05])  
lgnd.Title.String = "Decoded Taste"
set(gca,'FontSize',16)
saveas(avgplot, [name '_' num2str(decode.sample(1)) '-' num2str(decode.sample(end)) '_avgplot.png']);
%% percent plot
colormap = [0, 0.4470, 0.7410;0.8500, 0.3250, 0.0980;0.9290, 0.6940, 0.1250;0.4940, 0.1840, 0.5560];
psvec = -1999:5000;
lenny = length(decode.sample); 
percentplot = figure('Position', [100 -100 500 800]);
for i = 1:4
    subplot(5,1, i)
    pltArr = squeeze(decode.percent(:,i,:));
    clear gca
    plot(psvec,pltArr, 'LineWidth', 2);
    hold on
    line(decode.sample-1999, ones(lenny,1)*decode.winpercent(i,i),'Color', colormap(i,:),'LineWidth', 2, 'LineStyle','--');
    hold off
    
    ttl = title([decode.tastants{i} ' delivered'])
    ylab = ylabel({'% trials(taste)'})
    if i == 4
        xlab = xlabel("time from taste delivery (ms)") 
    end
    set(gca,'FontSize',11)
end
lgnd = legend({"NaCl", "Suc", "CA", "QHCl","None"},'Orientation','horizontal','Position',[0.2 0.19 0.6 0.05])  
lgnd.Title.String = "Decoded Taste"
% ttl.FontSize = 12;
% ylab.FontSize = 12;
% xlab.FontSize = 12;

saveas(percentplot, [name '_' num2str(decode.sample(1)) '-' num2str(decode.sample(end)) '_percentplot.png']);
%%
winplot = figure('Units','Inches','Position', [0 0 4 14])
colormap = [0, 0.4470, 0.7410;0.8500, 0.3250, 0.0980;0.9290, 0.6940, 0.1250;0.4940, 0.1840, 0.5560;0.4660, 0.6740, 0.1880];

for i = 1:4
    subplot(4,1,i)
    yarr = reshape(decode.winpost(:,decode.tasteInd==i),1,[])';
    index = reshape((ones(size(decode.winpost(:,decode.tasteInd==i))).*(1:5)'),1,[])';
    b = bar(1:5,decode.winavg(:,i),'FaceColor','flat');
    hold on
    e = errorbar(1:5,decode.winavg(:,i),squeeze(decode.winCI95(:,2,i)),'vertical','o','LineWidth',2,'MarkerEdgeColor','black');
    e.Color = 'black';
    hold off
    b.CData = colormap;
    ylim([0 1])
    xlim([0.5 5.5])
    ylab = ylabel({'p(taste)'})
    xticklabels({"Salty", "Sweet", "Sour", "Bitter","None"})
    ttl = title([decode.tastants{i} ' delivered'])
    grid on
    %hold on
    %beeswarm(index,yarr,'hex','gutter',0.5);
    ax = gca;
    ax.FontSize = 16;
    if i ==4
        xlab = xlabel("taste decoded")
    end
end

saveas(winplot, [name '_' num2str(decode.sample(1)) '-' num2str(decode.sample(end)) '_winplot.png']);
%%
winperplot = figure('Units','Inches','Position', [0 0 4 14])
colormap = [0, 0.4470, 0.7410;0.8500, 0.3250, 0.0980;0.9290, 0.6940, 0.1250;0.4940, 0.1840, 0.5560;0.4660, 0.6740, 0.1880];

for i = 1:4
    subplot(5,1,i)
    yarr = reshape(decode.winpost(:,dat.trlInd==i),1,[])';
    index = reshape((ones(size(decode.winpost(:,dat.trlInd==i))).*(1:5)'),1,[])';
    b = bar(1:5,decode.winavg(:,i),'FaceColor','flat');
    b.CData = colormap;
    ylim([0 1])
    xlim([0.5 5.5])
    ylab = ylabel({'p(taste)'})
    xticklabels({'NaCl', 'Suc', 'CA', 'QHCl','None'})
    ttl = title([decode.tastants{i} ' delivered'])
    %hold on
    %beeswarm(index,yarr,'hex','gutter',0.5);
    ax = gca;
    ax.FontSize = 16;
    if i ==4
        xlab = xlabel("taste decoded")
    end
end

saveas(winplot, [name '_' num2str(decode.sample(1)) '-' num2str(decode.sample(end)) '_winplot.png']);
%%
nacl = decode.posterior(:,dat.trlInd == 1,:);
suc = decode.posterior(:,dat.trlInd == 2,:);
ca = decode.posterior(:,dat.trlInd == 3,:);
qhcl = decode.posterior(:,dat.trlInd == 4,:);
psvec = -1999:5000;
%naclplot = figure('Position', [100 -100 800 800])
%pltnm =1;
for i = 1:size(nacl,2)
    figure
    %subplot(size(1:5:size(nacl,2),2),1, pltnm)
    pltnm = pltnm+1;
    pltArr = squeeze(nacl(:,i,:));
    plot(psvec,pltArr)
    if i == 1
        title(['NaCl delivered'])
        ylabel("p(taste)")
        xlabel("time from taste delivery (ms)")
    end
end
legend("NaCl", "Suc", "CA", "QHCl","None")   
saveas(naclplot, [name '_' num2str(decode.sample(1)) '-' num2str(decode.sample(end)) '_naclplot.png']);
%%
qhclplot = figure('Position', [100 -100 800 800])
pltnm =1;
for i = 1:5:size(qhcl,2)
    subplot(size(1:5:size(qhcl,2),2),1, pltnm)
    pltnm = pltnm+1;
    pltArr = squeeze(qhcl(:,i,:));
    plot(psvec,pltArr)
    if i == 1
        title(['QHCl delivered'])
        ylabel("p(taste)")
        xlabel("time from taste delivery (ms)")
    end
end
legend("NaCl", "Suc", "CA", "QHCl","None")   
saveas(qhclplot, [name '_' num2str(decode.sample(1)) '-' num2str(decode.sample(end)) '_qhclplot.png']);
