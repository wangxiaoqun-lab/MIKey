function all_roi_filter = Matrix_Filter(all_roi, TR, High, Low)
%MATRIX_FILTER Temporal FFT bandpass for TIME-BY-VOXEL data.
%   Y = Matrix_Filter(X, TR, High, Low)
%   X: number of time points x number of voxels (real single or double).
%   Y: same dimensions, double precision. Every column is filtered separately.
%   TR: seconds; High: UPPER cutoff in Hz; Low: LOWER cutoff in Hz.
%   Example: Y = Matrix_Filter(X, TR, 0.1, 0.01);
%
%   Compatible with the EXISTING combined-regression call:
%       processed_data = Matrix_Filter(processed_data', TR, High, Low);
%   Here processed_data is voxel-by-time BEFORE the call. Keep that transpose.
%   Do not pass voxel-by-time data directly or guess orientation from size.
%
%   Symmetric rectangular FFT band projection, including cutoff bins.
%   Uses the run's actual TR and length; no Hamming spectral taper.
%   Low > 0 removes DC; Low = 0 retains DC. No additional regression,
%   detrending, mean restoration, frame removal, or spatial filtering.
%   FFT assumes a periodic finite run: run boundaries are not padded.
%   Process each run separately. No Signal Processing Toolbox is required.
%   MATLAB R2018a/R2019 compatible. Invalid samples raise an error.

narginchk(4, 4);
if ~(isa(all_roi, 'double') || isa(all_roi, 'single')) || ...
        ~isreal(all_roi) || ~ismatrix(all_roi) || issparse(all_roi) || ...
        isempty(all_roi) || size(all_roi, 1) < 2
    error('Matrix_Filter:InvalidData', ...
        'Input must be a nonempty real time-by-voxel single/double matrix with at least 2 time points.');
end
if ~isnumeric(TR) || ~isreal(TR) || ~isscalar(TR) || ~isfinite(TR) || TR <= 0
    error('Matrix_Filter:InvalidTR', 'TR must be a finite positive scalar in seconds.');
end
if ~isnumeric(High) || ~isreal(High) || ~isscalar(High) || ~isfinite(High) || ...
        ~isnumeric(Low) || ~isreal(Low) || ~isscalar(Low) || ~isfinite(Low)
    error('Matrix_Filter:InvalidBand', 'High and Low must be finite real scalar frequencies in Hz.');
end
TR = double(TR);
High = double(High);
Low = double(Low);
nyquist = 0.5 / TR;
if Low < 0 || Low >= High || High > nyquist
    error('Matrix_Filter:InvalidBand', ...
        'Require 0 <= Low < High <= 1/(2*TR). High is the upper cutoff, Low the lower cutoff.');
end

[n_time, n_voxel] = size(all_roi);
bins = (0:n_time-1)';
frequency = min(bins, n_time-bins) / (n_time * TR);
tolerance = 16 * eps(max(nyquist, High));
keep = frequency >= Low-tolerance & frequency <= High+tolerance;
keep(1) = (Low == 0); % exclude DC explicitly whenever Low is positive
if ~any(keep)
    error('Matrix_Filter:NoPassbandBins', ...
        'No FFT frequencies lie in this band. Check run length, TR, and cutoff frequencies.');
end

all_roi_filter = zeros(n_time, n_voxel);
chunk_voxels = 4096; % bounds FFT working memory; no mixing between columns
for first = 1:chunk_voxels:n_voxel
    last = min(first + chunk_voxels - 1, n_voxel);
    X = double(all_roi(:, first:last));
    if any(~isfinite(X(:)))
        error('Matrix_Filter:NonfiniteData', ...
            'NaN/Inf found in voxel columns %d-%d. Resolve missing samples before filtering.', first, last);
    end
    F = fft(X, [], 1); % DIMENSION 1 IS TIME
    F(~keep, :) = 0;   % same symmetric temporal band for every voxel
    Y = real(ifft(F, [], 1));
    if any(~isfinite(Y(:)))
        error('Matrix_Filter:NumericalFailure', ...
            'Filtering overflowed in voxel columns %d-%d. Check input scaling.', first, last);
    end
    all_roi_filter(:, first:last) = Y;
end
end
