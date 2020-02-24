function SaveFig(obj,xmin,xmax,ver)
    xlim([xmin(1)-(xmax(1)-xmin(1))/20 xmax(1)+(xmax(1)-xmin(1))/20]);      
    ylim([xmin(2)-(xmax(2)-xmin(2))/20 xmax(2)+(xmax(2)-xmin(2))/20]);
    if(obj.M==3)
        %zlim([xmin(3)-(xmax(3)-xmin(3))/20 xmax(3)+(xmax(3)-xmin(3))/20]);
        pbaspect([1 1 0.9]);
    end
    saveas(gcf,['image\',class(obj.problem),'_M',int2str(obj.M),ver],'svg');
end