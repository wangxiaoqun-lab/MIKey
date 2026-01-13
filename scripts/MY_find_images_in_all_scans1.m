function all_img_list_cell=MY_find_images_in_all_scans1(animal_root_path, prefix, suffix, frames)
%     This function is to select images with specifc prefix and
%     sufix in all scans of a animal. This structure of the directory must
%     be like: under the "animal_root_path", there are scan folders named
%     by their scan ids with pure number in range from 1 to 99. And under
%     each scan folders, there are the images to be selected, whose names matches
%     regular expressions "prefix scan_id sufix". If the "concatenating_type"is all mixed,
%     all the scan images will be put in a cell, while if it is 'separate_cells', images of
%     each scan will be put into one cell and there is one outer cell wrapping up all these cells.
%     The result will be returned in the form compatible with spm preprocessing functions.
all_img_list_cell={};

working_folder=animal_root_path;
if exist(working_folder,'file')
    cell_func= MY_select_file_for_SPM(working_folder,[prefix suffix],frames);
    all_img_list_cell=[all_img_list_cell, {cell_func}];  
end
end

