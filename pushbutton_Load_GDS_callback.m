function pushbutton_Load_GDS_callback(gcf, event_data)

global handle;
global color_num;
color_num = color_num+1;
sz = 1800;
[handle.filename,handle.pathname,filterindex] = uigetfile('*.gds');

if filterindex > 0
    fid = fopen([handle.pathname handle.filename],'r');
    Data = fread(fid);
    fclose(fid);
    
    index = 1;
    num = 1;
    handle.GDS_Polygon_num = 0;
    handle.GDS_Polygon = [];
    while num ~= 0;
        num = Integer_2Byte(Data(index:index+1));
        index = index + 2;
        
        header = Data(index);
        HEADER_TYPE(header);
        index = index + 1;
        
        data_type = Data(index);
        index = index + 1;
        
        data_stream = Data(index:index+num-5);
        index = index+num-4;
        
        if strcmp(HEADER_TYPE(header),'UNITS')
            User_Unit = Float_8Byte(data_stream(1:8));
            Phys_Unit = Float_8Byte(data_stream(9:16));
            Ratio = Phys_Unit/1e-9;
        end
        
        
        
        if strcmp(HEADER_TYPE(header),'XY')
            handle.GDS_Polygon_num = handle.GDS_Polygon_num + 1;
            handle.GDS_Polygon{handle.GDS_Polygon_num} = [];
            for i = 0:2:length(data_stream)/4-1
                handle.GDS_Polygon{handle.GDS_Polygon_num} = [handle.GDS_Polygon{handle.GDS_Polygon_num} ;...
                    Integer_4Byte(data_stream(1+i*4:4+i*4))*Ratio Integer_4Byte(data_stream(5+i*4:8+i*4))*Ratio];
            end
            
        end
    end
    
    figure(10);
    handle.axes_GDS = axes;
    set(handle.axes_GDS,'NextPlot','add');
    for i = 1:length(handle.GDS_Polygon)
            plot(handle.GDS_Polygon{i}(:,1),handle.GDS_Polygon{i}(:,2),'Parent',handle.axes_GDS,'Color',[0 0 0]);%color_index(mod(color_num,3)/2))
    end
    set(handle.axes_GDS,'NextPlot','replace');
    set(handle.axes_GDS,'xticklabel',{},'yticklabel',{},'XLim',[-sz sz],'YLim',[-sz sz])
    title(handle.filename,'FontSize',16,'Parent',handle.axes_GDS);
    
    
    
    figure
    hold
    Total_Length = 0;
    for i = 1:length(handle.GDS_Polygon)
        for j = 2:length(handle.GDS_Polygon{i})
            if (handle.GDS_Polygon{i}(j,1) > -sz & handle.GDS_Polygon{i}(j,1) < sz & ...
                handle.GDS_Polygon{i}(j,2) > -sz & handle.GDS_Polygon{i}(j,2) < sz ) | ...
               (handle.GDS_Polygon{i}(j-1,1) > -sz & handle.GDS_Polygon{i}(j-1,1) < sz & ...
                handle.GDS_Polygon{i}(j-1,2) > -sz & handle.GDS_Polygon{i}(j-1,2) < sz )
                x1 = max([-sz handle.GDS_Polygon{i}(j,1)]);
                y1 = max([-sz handle.GDS_Polygon{i}(j,2)]);
                x2 = max([-sz handle.GDS_Polygon{i}(j-1,1)]);
                y2 = max([-sz handle.GDS_Polygon{i}(j-1,2)]);
                x1 = min([sz x1]);
                y1 = min([sz y1]);
                x2 = min([sz x2]);
                y2 = min([sz y2]);
                Total_Length = Total_Length + ((x1-x2)^2 + (y1-y2)^2)^0.5;
               plot([x1 x2],[y1 y2])
            end
        end
    end
%     set(handle.edt_Total_Length,'String',num2str(Total_Length,'%6.0f'))
   axis([-sz sz -sz sz])
end
