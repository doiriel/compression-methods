% Huffman encoding for an image
function codeBook = huffman_image(image)
% Find probability vector on image

% Determine image size
[rows,cols] = size(image);

% Compute histogram 
[counts,binLocations] = imhist(image);

% Normalize counts to find the probability vector
counts_normalized = counts/(rows*cols);
prob_vector = counts_normalized;

% Each label corresponds to a gray level (0-255)
alphabet = binLocations;

% Apply Huffman encoding to the probability vector
codeBook = huffman_encoding(prob_vector,alphabet);

end