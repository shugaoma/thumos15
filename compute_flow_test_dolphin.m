%==============================================================================
%
% Computes optical flow for ucf101 video dataset.
%
%==============================================================================
addpath('/home/grad2/shugaoma/local/broxflow');
addpath('/home/grad2/shugaoma/local/matlab-video4linux');
video_path = '/research/action_features/thumos2015/thumos15_testing';
flow_path = '/research/action_features/thumos2015/thumos15_testing_flow';

video_list = dir([video_path filesep '*.mp4']);
for i = vid1:vid2
    try
    [~,vname,~] = fileparts(video_list(i).name);
    flow_dir = [flow_path filesep vname];
    
    imgs = read_video([video_path filesep video_list(i).name], 1);
    imgs = imgs(:,:,:,1:2:end);
    nfms = size(imgs, 4);
    fprintf('Video %d, nfms = %d\n', i, nfms);

    if exist(flow_dir, 'dir')
        flowimg_list = dir([flow_dir filesep '*.jpg']);
        if length(flowimg_list) >= (2 * (nfms - 1))
            fprintf('Video %d: flow already computed.', i);
            continue;
        else
            delete([flow_dir filesep '*.jpg']);
        end
    else
        mkdir(flow_dir);
    end

    fprintf('Video %d: compute flow...', i);
    K = 50;
    for k = 1:ceil(nfms / K)
        fprintf('k = %d\n', k);
        if k == 1
            imgs2 = imgs(:,:,:,1:K);
        else
            imgs2 = imgs(:,:,:,(k-1) * K : min(k * K, nfms));
        end
        flow = broxflow(imgs2, 'ransac');
        im_uv = flow2img(flow.u, flow.v);
        im_huhv = flow2img(flow.hu, flow.hv);
        for h = 1:size(im_uv, 4)
            if k == 1
                flow_name = sprintf('%06d', h);
            else
                flow_name = sprintf('%06d', (k-1) * K + h - 1);
            end
            imwrite(im_uv(:,:,:,h), [flow_dir filesep flow_name ...
                '_flow.jpg'], 'jpg', 'Quality', 80);
            imwrite(im_huhv(:,:,:,h), [flow_dir filesep flow_name ...
                '_stable_flow.jpg'], 'jpg', 'Quality', 80);
        end
    end
  
    catch exception
        getReport(exception)
        continue;
    end
    fprintf('finished\n');
end

