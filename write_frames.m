video_root = 'thumos15_validation'
frame_root = 'thumos15_validation_frames'
video_list = dir([video_root filesep '*.mp4']);

for i = 1:length(video_list)
    [~,vname,~] = fileparts(video_list(i).name);
    avi2jpg([video_root filesep video_list(i).name], frame_root);
    val_video_list(i).video_name = [video_root filesep video_list(i).name];
    val_video_list(i).frame_name = [frame_root filesep vname];
    val_video_list(i).vname = vname;
end
save('thumos2015_val_data', 'val_data_list');

