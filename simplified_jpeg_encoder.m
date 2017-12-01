
%This function accepts an image as an array, performs DCT and
%normalization/quantization on 8x8 pixel blocks of the image, encodes the
%data, and outputs the final encoded image.

function streams_together = simplified_jpeg_encoder(array)

    %Ensure the array passed to the encoder is a matrix, is real, is
    %numeric, and is of made up of 8 bit integers. If not, output an error.
    if ~ismatrix(array) || ~isreal(array) || ~isnumeric(array) || ~isa(array, 'uint8')
    error('The input must be a uint8 image.');
    end
    
    %Ensure the image can be broke into 8x8 blocks, and if not, resize.
    [height, width] = size(array);
    if rem(height,8) ~= 0
        height = round(height/8.)*8;
        array = imresize(array,[height, width]);
    end
    if rem(width,8) ~= 0   
        width = round(width/8.)*8;
        array = imresize(array,[height, width]);
    end
    
    no_gray_levels = double(max(max(array))-min(min(array))) + 1.;
    m = log2(no_gray_levels);
    shift = 2^(m-1.);

    array = double(array) - shift; %Level shift the array

    %Perform the 2D discrete cosine transform on 8x8 blocks of the data
    H = dctmtx(8);
    fun = @(block_struct) (H * block_struct.data * H');
    transformation = blockproc(array, [8 8], fun);

    %Perform normalization and quantization using Z
    Z = [16 11 10 16 24 40 51 61;  % transformation normalization array
         12 12 14 19 26 58 60 55;   
         14 13 16 24 40 57 69 56; 
         14 17 22 29 51 87 80 62;
         18 22 37 56 68 109 103 77;
         24 35 55 64 81 104 113 92;
         49 64 78 87 103 121 120 101;
         72 92 95 98 112 100 103 99];
    fun2 =  @(block_struct) round(block_struct.data ./ Z);
    quantiz = blockproc(transformation, [8 8], fun2);

    %Reorder the elements of the result of quantization according to the zigzag
    %pattern
    order = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33  ... % zig-zag reordering pattern
             41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 ...
             43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 ...
             45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 ...
             62 63 56 64];
    quantiz = im2col(quantiz, [8 8], 'distinct');   % separate 8x8 blocks into 1d arrays
    quantiz = quantiz(order, :);                    % reorder column elements

    %Truncate the stream (each column after the last non-zero element. Add
    %the end of block symbol between streams, and save the result in the
    %array streams_together
    end_block = max(array(:)) + 1;  % create end-of-block symbol
    num_pixels = 64;                %number of pixels in a block
    num_blocks = height*width/64;   %number of blocks

    streams_together = zeros(numel(quantiz) + size(quantiz, 2), 1);   
    count = 0;
    for j = 1:num_blocks                        %vector to save the concantenated streams
        i = find(quantiz(:, j), 1, 'last');   % find last non-zero element
        if isempty(i)                   % check if there are no non-zero values
            i = 0; 
        end 
        p = count + 1;
        q = p + i;
        streams_together(p:q)  = [quantiz(1:i, j); end_block];     % truncate trailing zeros, add end_block
        count = count + i + 1;          % and add to output vector
    end
    streams_together((count + 1):end) = [];            % delete unused portion of streams_together
    
end