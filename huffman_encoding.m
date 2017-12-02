% Huffman encoding for a probability vector
function codeBook = huffman_encoding(prob_vector,alphabet)

% Create a row vector for probabilities
[rows,cols] = size(prob_vector);
if rows > cols
    prob_vector = prob_vector';
end

% Create labels
for i = 1:length(alphabet)
    labels{i} = num2str(alphabet(i));
end

% Save initial set of labels and probabilities
init_labels = labels;
init_prob = prob_vector;

% Initialize variables
sorted_prob = prob_vector;
rear = 1;
while (length(sorted_prob) > 1) % Stops when only one probability remains
    % Sort probabilities in ascendent order
    [sorted_prob,indeces] = sort(sorted_prob);
    
    % Sort labels based on indeces
    labels = labels(indeces);
    
    % Create new nodes in queue
    new_node = strcat(labels(2),labels(1));
    new_prob = sum(sorted_prob(1:2));
    
    % Eliminate old nodes in queue
    labels =  labels(3:length(labels));
    sorted_prob = sorted_prob(3:length(sorted_prob));
    
    % Add the new nodes to the queue
    labels = [labels, new_node];
    sorted_prob = [sorted_prob, new_prob];
    
    % Add new nodes to a new queue
    newq_str(rear) = new_node;
    newq_prob(rear) = new_prob;
    
    rear = rear + 1;
end
% Form tree
tree = [newq_str,init_labels];
tree_prob = [newq_prob, init_prob];

% Sort all tree elements
[sorted_tree_prob,indeces] = sort(tree_prob,'descend');
sorted_tree = tree(indeces);

% Find relationships between nodes
parent(1) = 0;
for i = 2:length(sorted_tree)
    % Extract current position
    current = sorted_tree{i};
    
    % Find parent's label (search until shortest match is found)
    count = 1;
    possible_parent = sorted_tree{i-count};
    % Evaluate the difference between the labels of current and possible
    % parent
    diff = strfind(possible_parent,current);
    while (isempty(diff)) % Ends whe the labels of parent and current match
        count = count + 1;
        possible_parent = sorted_tree{i-count};
        diff = strfind(possible_parent,current);
    end
    parent(i) = i - count;
end

% Build a tree based on parent
[xs,ys,~,~] = treelayout(parent);

% Assign weights to tree's branches
for i = 2:length(sorted_tree)
    % Get current coordinate
    curr_x = xs(i);
    curr_y = ys(i);
    
    % Get parent coordinate
    parent_x = xs(parent(i));
    parent_y = ys(parent(i));
    
    % Calculate weight coordinate (midpoint)
    mid_x = (curr_x + parent_x)/2;
    mid_y = (curr_y + parent_y)/2;
    
    % Calculate weight (positive slope = 1, negative = 0)
    slope  = (parent_y - curr_y)/(parent_x - curr_x);
    if (slope > 0)
        weight(i) = 1;
    else
        weight(i) = 0;
    end
    
end

% Generate Huffman codebook
for i = 1:length(sorted_tree)
    % Initialize code
    code{i} = '';
    
    % Loop until root is found
    index = i;
    p = parent(index);
    while(p ~= 0)
        % Turn weight into code symbol
        w = num2str(weight(index));
        
        % Concatenate code symbol
        code{i} = strcat(w,code{i});
        
        % Continue towards root
        index = parent(index);
        p = parent(index);
    end
end

% Codebook for all combinations 
full_codeBook = [sorted_tree', code'];
pos = [];

% Find codebook for input probabilities
for i = 1:length(init_labels)
    new_pos = find(strcmp(full_codeBook, init_labels(i)));
    new_pos = new_pos';
    pos = [pos,new_pos];
end

% Select only position in range
pos = pos(pos<=length(sorted_tree));
final_tree = sorted_tree(pos);
final_code = code(pos);
codeBook = [final_tree', final_code'];
    
end