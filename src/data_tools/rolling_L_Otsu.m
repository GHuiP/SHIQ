% Using the multi-time Otsu algorithm to produce highlight mask, since
% the only-one-time one often generates highlight masks with much
% noise even errors
function [mask] = Rolling_L_Otsu(image, iter_num)
    % Lab=rgb2lab(image);
    % L=Lab(:,:,1);

    % 检查输入图像是否为灰度图像
    if size(image, 3) == 1
        % 如果是灰度图像，直接使用
        L = image;
    else
        % 如果是彩色图像，转换为LAB颜色空间并使用L通道
        Lab = rgb2lab(image);
        L = Lab(:,:,1);
    end
    % 归一化L通道到0-1范围
    L=(L-min(L(:)))./(max(L(:))-min(L(:)));
    
    mask=ones(size(image,1),size(image,2));
    for i=1:iter_num
        L_temp=extract(L,mask);
        T=graythresh(L_temp);
        mask(find(L<=T))=0;
    end
end
