video_root = 'thumos15_testing';
frame_root = '/research/action_data/thumos2015/thumos15_testing_frames';
video_list = dir([video_root filesep '*.mp4']);

parfor i = 1:length(video_list)
    [~,vname,~] = fileparts(video_list(i).name);
    avi2jpg([video_root filesep video_list(i).name], frame_root);
    testing_video_list(i).video_name = [video_root filesep video_list(i).name];
    testing_video_list(i).frame_name = [frame_root filesep vname];
    testing_video_list(i).vname = vname;
end
save('thumos2015_testing_data', 'testing_video_list');

