% function [ctr_out,gds_bias,final_rounding] = ctr_match(mask_gds,mask_sem,gds_fov,sem_fov, disp_result)

gds_path = 'D:\SAGAR\WORK SPACE\SAGAR\fidelity\Wafer_Ctr';
gds_file = 'testM0101.png';
mask_path = 'D:\SAGAR\WORK SPACE\SAGAR\fidelity\Wafer_Ctr';
mask_file = 'S02_M0121-02MS.jpg';

disp_result = false;
mask_gds = im2double(imread(fullfile(gds_path,gds_file)));
mask_sem1 = im2double(imread(fullfile(mask_path,mask_file)));
gds_fov = 1800;
sem_fov = 1800;

mask_sem = mask_sem1;

mask_sem = imresize(mask_sem(:,:,1),[2048 2048]);

gds_size = size(mask_gds);
sem_size = size(mask_sem);

gds_pz = gds_fov/gds_size(1);
sem_pz = sem_fov/sem_size(1);

mask_gds = ~(mask_gds(:,:,1)~=0);
mask_gds = imresize(mask_gds,gds_pz/sem_pz,'nearest'); % 0.94

G = fspecial('gaussian',11,5);
for fl=1:5   
    mask_sem=conv2(mask_sem,G,'same');
    mask_sem = medfilt2(mask_sem,[5 5],'symmetric');
end;
% op_out = img_op1;
[~,~,~,~,~,p1,p2]=gradAll(mask_sem,1);
pt = (p1-min(p1(:)))/(max(p1(:))-min(p1(:)));
ptt = (p2-min(p2(:)))/(max(p2(:))-min(p2(:)));
pt = pt./(1+ptt);
% figure(); imshow(im2bw(pt,graythresh(pt)));
bw1=im2bw(pt,graythresh(pt)*0.8);
bw1 = bwmorph(bw1,'thin',Inf);

N=24;
bw1 = bw1(N+1:end-N, N+1:end-N);
pt = pt(N+1:end-N, N+1:end-N);
img_op1 = mask_sem(N+1:end-N, N+1:end-N);

gds_base = conv2(double(edge(mask_gds)),G,'same');

C = normxcorr2(pt,gds_base);

temp_size = size(pt);
[r1,c1] = find(C==max(C(:)));
img_gds = mask_gds(r1(1)-temp_size(1)+1:r1(1),c1(1)-temp_size(2)+1:c1(1));

if ~disp_result
    figure(); imshowpair(img_gds,bw1);
end;

%%
lb_gdst = bwlabel(img_gds); img_dist = bwdist(~img_gds);
img_bw1 = false(size(bw1));
for i=1:max(lb_gdst(:))
    temp = img_dist.*(lb_gdst==i);
    [x_pt,y_pt]=find(temp==max(temp(:)));    
    img_bw1 = (img_bw1 | imfill(bw1,[x_pt(1),y_pt(1)]));
%     figure(); imshow(img_bw1);
end;
% figure(); imshow(img_bw1);
img_bw1 = imopen(img_bw1,strel('disk',3));
img_bw1 = bwareaopen(img_bw1,size(img_bw1,1));
img_bw1 = ~bwareaopen(~img_bw1,size(img_bw1,1));
if ~disp_result
    figure(); imshowpair(img_bw1,img_op1);
end;

%%

img_bw3 = img_gds;
img_bwt = img_bw3;
img_gdst = img_bw1;

old_err = length(img_bw3);
new_err = 0;
 
% master_flg = false;

xoffset2 = 0;
yoffset2 = 0;
bias_value = 0;

projectx_gds = sum(img_gds,2)';
projecty_gds = sum(img_gds);
x_flg = isequal(projectx_gds,projectx_gds(1)*ones(1,length(projectx_gds)));
y_flg = isequal(projecty_gds,projecty_gds(1)*ones(1,length(projecty_gds)));

org_gds = img_bw3;      % unchanged contour
org_bwt = img_bw3;      % unchanged contour
while(old_err>new_err)
    old_err = sum(xor(img_bwt(:),img_gdst(:)));
    temp1 = sum(xor(img_bwt(:),img_gdst(:)) & (img_gdst(:)));
    temp2 = sum(xor(img_bwt(:),img_gdst(:)) & (~img_gdst(:)));
    final_gds = img_bwt;
    final_sem = img_gdst;
    org_gds = org_bwt;          % unchanged contour
    gds_bias = bias_value;
     
    if(temp1<temp2)
        bias_value = bias_value-1;
    end;
    if(temp1>temp2)
        bias_value = bias_value+1;
    end;
    
    if(bias_value<0)
        img_bwt = imerode(img_bw3,strel('square',-(2*bias_value-1)));        
    end;    
    if(bias_value>=0)
        img_bwt = imdilate(img_bw3,strel('square',2*bias_value+1));        
    end;
    
        [yoffset2,xoffset2,c] = ImgRegister(img_bwt(1:end/2,1:end/2),img_bw1(1:end/2,1:end/2),0.15);
        xoffset2 = xoffset2-1; yoffset2 = yoffset2-1;
        
        if x_flg
            xoffset2 = 0;
        end;
        if y_flg
            yoffset2 = 0;
        end;    

        [img_bwt,img_gdst] = Im_align(xoffset2,yoffset2,img_bwt,img_bw1);
        [org_bwt,~] = Im_align(xoffset2,yoffset2,img_bw3,img_bw3);      % unchanged contour
       
%         if disp_result
%             figure;
%             imshowpair(img_bwt,img_gdst);
%         end;
       
        new_err = sum(xor(img_bwt(:),img_gdst(:)));

end;

if disp_result
    figure(); imshowpair(final_gds, final_sem);
end;


if(gds_bias<0)
    ctr_out = imerode(mask_gds,strel('square',-(2*gds_bias-1)));
else
    ctr_out = imdilate(mask_gds,strel('square',2*gds_bias+1));
end;




final_gdst = final_gds;
% final_semt = final_sem;

old_err = sum(xor(final_gdst(:),final_sem(:)));
new_err = 0;

out_rounding = 0;

while(old_err>new_err)
    final_gds = final_gdst;
    old_err = sum(xor(final_gdst(:),final_sem(:)));
    finalout_rounding = out_rounding;
    
    out_rounding = out_rounding+1;
    final_gdst = imopen((final_gdst),strel('disk',out_rounding,0));      
    new_err = sum(xor(final_gdst(:),final_sem(:)));    
end;

final_gdst = final_gds;
old_err = sum(xor(final_gdst(:),final_sem(:)));
new_err = 0;
in_rounding = 0;

while(old_err>new_err)
    final_gds = final_gdst;
    old_err = sum(xor(final_gdst(:),final_sem(:)));
    finalin_rounding = in_rounding;
    
    in_rounding = in_rounding+1;
    final_gdst = imclose((final_gdst),strel('disk',in_rounding,0));      
    new_err = sum(xor(final_gdst(:),final_sem(:)));    
end;


if ~disp_result
    figure(); imshowpair(final_gds,final_sem);
end;

ctr_out = imclose(imopen(ctr_out,strel('disk',finalout_rounding,0)),strel('disk',finalin_rounding,0));

if disp_result
    figure(); imshow(ctr_out);
end;


    [final_out1,sem1t3,data_sem1] = colorPVmeasure(org_gds,final_sem);
%         handles.datasem1 = sem1t3(sem1t3~=0);
    [global_xmin,global_ymin] = find(sem1t3 == min(sem1t3(:)));
    [global_xmax,global_ymax] = find(sem1t3 == max(sem1t3(:)));
    figure(); 
    imshow(final_out1); hold on;
    scatter(global_ymin,global_xmin,'filled','m');         
    scatter(global_ymax,global_xmax,'filled','c');        
    hold off;     


% end

