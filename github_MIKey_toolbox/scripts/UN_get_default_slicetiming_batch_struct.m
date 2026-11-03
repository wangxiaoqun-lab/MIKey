function SliceTiming_mlb = UN_get_default_slicetiming_batch_struct(all_func, Nslice, TR, sliceorder)
    SliceTiming_mlb{1}.spm.temporal.st.scans = all_func;
    SliceTiming_mlb{1}.spm.temporal.st.nslices = Nslice;
    SliceTiming_mlb{1}.spm.temporal.st.tr = TR;
    SliceTiming_mlb{1}.spm.temporal.st.ta = TR - TR/Nslice;
    
    % Convert user-friendly slice order descriptions to SPM-compatible format
    switch lower(strrep(sliceorder, ' ', '')) % Remove spaces and convert to lowercase for comparison
        case {'ascending', 'asc'}
            SliceTiming_mlb{1}.spm.temporal.st.so = 1:Nslice;
            
        case {'descending', 'desc'}
            SliceTiming_mlb{1}.spm.temporal.st.so = Nslice:-1:1;
            
        case {'interleavedascending', 'interleavedasc', 'interleavedascending(oddfirst)'}
            SliceTiming_mlb{1}.spm.temporal.st.so = [1:2:Nslice, 2:2:Nslice];
            
        case {'interleaveddescending', 'interleaveddesc', 'interleaveddescending(oddfirst)'}
            SliceTiming_mlb{1}.spm.temporal.st.so = [Nslice:-2:1, Nslice-1:-2:1];
            
        case {'interleavedascending(evenfirst)'}
            SliceTiming_mlb{1}.spm.temporal.st.so = [2:2:Nslice, 1:2:Nslice];
            
        case {'interleaveddescending(evenfirst)'}
            SliceTiming_mlb{1}.spm.temporal.st.so = [Nslice-1:-2:1, Nslice:-2:1];
            
        otherwise
            % If we can't match, use the most common default (interleaved ascending)
            warning('Unknown slice order "%s", using default interleaved ascending', sliceorder);
            SliceTiming_mlb{1}.spm.temporal.st.so = [1:2:Nslice, 2:2:Nslice];
    end
    
    SliceTiming_mlb{1}.spm.temporal.st.refslice = 1;
    SliceTiming_mlb{1}.spm.temporal.st.prefix = 'slicetime';
end