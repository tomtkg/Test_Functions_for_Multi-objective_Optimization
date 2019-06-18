function Draw(Data,varargin)
    [~,M] = size(Data);

    %% Draw the figure
    set(gca,'NextPlot','add','Box','on','Fontname','Times New Roman','FontSize',13);
    if M == 2
        plot(Data(:,1),Data(:,2),varargin{:});
        xlabel('\it f\rm_1'); ylabel('\it f\rm_2');
        set(gca,'View',[0 90]);
    elseif M == 3
        plot3(Data(:,1),Data(:,2),Data(:,3),varargin{:});
        xlabel('\it f\rm_1'); ylabel('\it f\rm_2'); zlabel('\it f\rm_3');
        set(gca,'View',[135 30]);
    end
    axis square; 
    set(gcf,'PaperPosition',[0 0 10 9.9],'Color','white','InvertHardcopy','off');
end