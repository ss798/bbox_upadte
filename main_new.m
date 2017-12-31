clear; clc; close all; warning off;
addpath(genpath('meanShift'));
datapath = 'flo';                               %flo�ļ�Ŀ¼ 
filenms = dir(fullfile(datapath,'*.flo'));      %��ȡĿ¼������flo�ļ����ļ���
win = 2;
% for i = 1:length(filenms)                     %�������ļ����д���
for i = 3:6                                     %��ǰ2���ļ����д���
    close all;
    file = fullfile(datapath,filenms(i).name);  %flo�ļ�ȫ·��
    flow = readFlowFile(file);                  %��ȡflo�ļ�
    u = flow(win:win:end,win:win:end,1);        %u�������
    v = flow(win:win:end,win:win:end,2);        %v�������
    r = sqrt(u.^2+v.^2);                        %������С
    maxr = max(abs(r(:)));
    r = r/maxr;                                 %������Դ�С
    o = atan2(u,v); o = o/pi;                   %��������
    ind = find(r>.15 & r*maxr>.6);              %�ҵ����й�����Դ�С����0.15�Ҿ��Դ�С����.6�Ĺ�����
    r_ = r(ind);
    o_ = o(ind);
    L_ = meanShift([r_(:), o_(:)],.4,.25,50);          %meanShift������Ŀ������         
    L = zeros(size(u));
    L(ind) = L_;
    L = reshape(L,size(u));
    L1 = zeros(size(L));
    max_id = 0;
    for li = 1:max(L(:))                        %��Ŀ������������±��
        Ib = (L==li);
        L_ = bwlabeln(Ib,8);
        L_(Ib) = L_(Ib)+max_id;
        max_id = max_id+max(L_(:));
        L1 = L1+L_;
    end
    if ~exist('output','dir'), mkdir('output'); end
    rects = []; f = ['output\' filenms(i).name(1:end-4)];
    % ���ͼ1
    img = flowToColor(flow);                    %������ת��Ϊ��ɫͼ
    h1 = figure(1); imshow(img); hold on
    for li = 1:max(L1(:))
        Ib = (L1==li);
        meanr = mean(r(Ib(:)));                 %Ŀ��ƽ��������Դ�С
        numPts = sum(double(Ib(:)));            %Ŀ�����ش�С
        % ����ʾ������Դ�С����0.3 �� Ŀ���С���˵�����
        if meanr>.3 && numPts>100 && numPts<numel(u)/10
            B = bwboundaries(Ib,'noholes');
            boundary = win*B{1};
            plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);    %����
        end
    end
    filename = [f '_boundary'];
    savefig(filename,h1,'png');
    
    % ���ͼ2
    h2 = figure(2); imshow(img); hold on
    for li = 1:max(L1(:))
        Ib = (L1==li);
        meanr = mean(r(Ib(:)));                 %Ŀ��ƽ��������Դ�С
        numPts = sum(double(Ib(:)));            %Ŀ�����ش�С
        % ����ʾ������Դ�С����0.3 �� Ŀ���С���˵�����
        if meanr>.3 && numPts>100 && numPts<numel(u)/10
            B = bwboundaries(Ib,'noholes');
            boundary = win*B{1};
            plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);    %����
            minx = min(boundary(:,2));
            maxx = max(boundary(:,2));
            miny = min(boundary(:,1));
            maxy = max(boundary(:,1));
            rect = [minx,miny;minx maxy;maxx maxy;maxx miny;minx miny]; %box
            rects = [rects; rect(1:4,:)];
            plot(rect(:,1), rect(:,2), 'r', 'LineWidth', 2);
        end
    end
    filename = [f '_box'];
    savefig(filename,h2,'png');
    
    % ���ͼ3
    img = zeros(size(u));                  
    for li = 1:max(L1(:))
        Ib = (L1==li);
        meanr = mean(r(Ib(:)));                 %Ŀ��ƽ��������Դ�С
        numPts = sum(double(Ib(:)));            %Ŀ�����ش�С
        % ����ʾ������Դ�С����0.3 �� Ŀ���С���˵�����
        if meanr>.3 && numPts>100 && numPts<numel(u)/10
            B = bwboundaries(Ib,'noholes');
            boundary = B{1};
            ind = sub2ind(size(u),boundary(:,1),boundary(:,2));
            img(ind) = 1;
        end
    end
    img = imresize(img,win);
    imshow(img);
    filename = [f '_bw.png'];
    imwrite(img,filename);
    csvwrite([f '_gt.txt'],rects);
end