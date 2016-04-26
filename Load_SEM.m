function img_out = Load_SEM(pathname1,filename1,sz,imgsz)

% pathname1 = 'D:\SAGAR\WORK SPACE\SAGAR\fidelity\Multi-Image_Operation\GDS read';
% filename1 = 'CD000001.gds';
% sz = 1000;
% imgsz = [2000 2000];

global handle;
global color_num;
color_num = color_num+1;

sz = round((sz+200)/2);
img_temp = false(2*sz+1);
handle.pathname = pathname1; handle.filename = filename1;



% [handle.filename,handle.pathname,filterindex] = uigetfile('*.gds');

% if filterindex > 0
    fid = fopen(fullfile(handle.pathname,handle.filename),'r');
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
    
%     figure(10);
%     handle.axes_GDS = axes;
%     set(handle.axes_GDS,'NextPlot','add');
%     for i = 1:length(handle.GDS_Polygon)
%             plot(handle.GDS_Polygon{i}(:,1),handle.GDS_Polygon{i}(:,2),'Parent',handle.axes_GDS,'Color',[0 0 0]);%color_index(mod(color_num,3)/2))
%     end
%     set(handle.axes_GDS,'NextPlot','replace');
%     set(handle.axes_GDS,'xticklabel',{},'yticklabel',{},'XLim',[-sz sz],'YLim',[-sz sz])
%     title(handle.filename,'FontSize',16,'Parent',handle.axes_GDS);
    
    
    
%     figure
%     hold
    my_pts = zeros([length(handle.GDS_Polygon) 2 2]);
%     Total_Length = 0;
    for i = 1:length(handle.GDS_Polygon)    
        tempt = false(size(img_temp));
        break_flg = false;
        pts_flg = true;
        for j = 2:length(handle.GDS_Polygon{i})            
            if (handle.GDS_Polygon{i}(j,1) > -sz && handle.GDS_Polygon{i}(j,1) < sz && ...
                handle.GDS_Polygon{i}(j,2) > -sz && handle.GDS_Polygon{i}(j,2) < sz ) || ...
               (handle.GDS_Polygon{i}(j-1,1) > -sz && handle.GDS_Polygon{i}(j-1,1) < sz && ...
                handle.GDS_Polygon{i}(j-1,2) > -sz && handle.GDS_Polygon{i}(j-1,2) < sz ) || ...
               ((handle.GDS_Polygon{i}(j,1)+handle.GDS_Polygon{i}(j-1,1))/2 > -sz && (handle.GDS_Polygon{i}(j,1)+handle.GDS_Polygon{i}(j-1,1))/2 < sz && ...
                (handle.GDS_Polygon{i}(j,2)+handle.GDS_Polygon{i}(j-1,2))/2 > -sz && (handle.GDS_Polygon{i}(j,2)+handle.GDS_Polygon{i}(j-1,2))/2 < sz )
                x1 = max([-sz handle.GDS_Polygon{i}(j,1)]);
                y1 = max([-sz handle.GDS_Polygon{i}(j,2)]);
                x2 = max([-sz handle.GDS_Polygon{i}(j-1,1)]);
                y2 = max([-sz handle.GDS_Polygon{i}(j-1,2)]);
                x1 = min([sz x1]);
                y1 = min([sz y1]);
                x2 = min([sz x2]);
                y2 = min([sz y2]);
%                 Total_Length = Total_Length + ((x1-x2)^2 + (y1-y2)^2)^0.5;
%                plot([x1 x2],[y1 y2])
%                if x1>x2
%                    td = x1; x1=x2; x2=td;
%                end;
%                if y1>y2
%                    td = y1; y1=y2; y2=td;
%                end;
               x1 = round(x1+sz+1); x2 = round(x2+sz+1); y1 = round(y1+sz+1); y2 = round(y2+sz+1);
               
               if (x2==x1) && (y2==y1)
                   cx=x1; cy=y1;
               elseif abs(x2-x1)>abs(y2-y1)                   
                   cx = (x1:(x2-x1)/abs(x2-x1):x2);
                   if y2==y1
                       cy = y1*ones(1,length(cx));
                   else
                       cy = round(y1:(y2-y1)/abs(x2-x1):y2);
                   end;                   
               else
                   cy = (y1:(y2-y1)/abs(y2-y1):y2);
                   if x2==x1
                       cx = x1*ones(1,length(cy));
                   else
                       cx = round(x1:(x2-x1)/abs(y2-y1):x2);
                   end;
                   
               end;
%                cx = round(cx); cy = round(cy);
               tempt(cy+((cx-1)*(2*sz+1)))=1;
%                figure(10); imshow(tempt);

               if (abs(x2-x1)>=3 ||  abs(y2-y1)>=3)
                   if pts_flg
                       pts_flg=false;   
                       ind1 = round(length(cx)/2);
                       if abs(x2-x1)>abs(y2-y1)
                           my_pts(i,:,1)=[cy(ind1)-1,cx(ind1)];
                           my_pts(i,:,2)=[cy(ind1)+1,cx(ind1)];
                       else
                           my_pts(i,:,1)=[cy(ind1),cx(ind1)-1];
                           my_pts(i,:,2)=[cy(ind1),cx(ind1)+1];
                       end;                   
                   end;               
               end;
               if ((x1==1) || (x1==(2*sz+1)) || (y1==1) || (y1==(2*sz+1)) || (x2==1) || (x2==(2*sz+1)) || (y2==1) || (y2==(2*sz+1)))
                   break_flg = true;
               end;
            end            
        end
        
        if ~pts_flg
            if ~break_flg
                temp1 = imfill(tempt,my_pts(i,:,1)); a1 = sum(temp1(:));
                temp2 = imfill(tempt,my_pts(i,:,2)); a2 = sum(temp2(:));
                if (a1 < a2) 
                    tempt = temp1;                       
                end;
                if (a1 > a2)
                    tempt = temp2;
                end;               
            end;       
            img_temp = img_temp | tempt;
%             figure(15); imshow(img_temp);
        end;
    end
%     set(handle.edt_Total_Length,'String',num2str(Total_Length,'%6.0f'))
%    axis([-sz sz -sz sz])
   
%    img_new = imfill((img_temp~=0),'holes');
   img_new = img_temp(end:-1:1,:);
   frm1 = true(size(img_temp));
   frm1(2:end-1,2:end-1)=false;   
   
   if sum(frm1(:) & img_new(:))
       mask1 = (~img_new) & (frm1);
       am = size(mask1);
       myarray = [mask1(:,1);mask1(end,2:end)';mask1(end-1:-1:1,end);mask1(1,end-1:-1:2)'];       
       myarray1 = bwmorph(myarray,'shrink',Inf);
       if myarray(1) && myarray(end)
           ind = find(myarray1);
           myarray1(ind(end))=0;
       end;
       r1 = [(1:am(1))';am(1)*ones(am(2)-1,1);((am(1)-1):-1:1)';ones(am(2)-2,1)];
       c1 = [ones(am(1),1);(2:am(2))';am(2)*ones(am(1)-1,1);((am(2)-1):-1:2)'];
       r1 = r1(myarray1);
       c1 = c1(myarray1);
       temp1 = imfill(img_new,[r1(1:2:end) c1(1:2:end)]);
       temp2 = imfill(img_new,[r1(2:2:end) c1(2:2:end)]);
       if (sum(xor(temp1(:),img_new(:))) < sum(xor(temp2(:),img_new(:))))
           img_out = temp1;
       else
           img_out = temp2;
       end;
   else
       img_out = img_new;
   end;
   
   img_out = imresize(img_out(102:end-100,102:end-100),imgsz,'nearest');
%    figure(); imshow(img_out);  
   
end
