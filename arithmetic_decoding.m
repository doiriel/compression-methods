
%The arithmetic_decoding function's inputs are the DNA alphabet, respective
%symbols probabilities, and binary code (last entry in binary sequence),
%respectively. The function outputs the decoded sequence.

function decoded_sequence = arithmetic_decoding(list_of_symbols, probabilities, decimal, size)
    
    %Create a list of all high ranges and a list of all low ranges for
    %symbols.    
    highrange(list_of_symbols(1)) = 1.0;
    lowrange(list_of_symbols(1)) = vpa(1. - probabilities(1));
    for i = 2 : length(list_of_symbols)
        highrange(list_of_symbols(i)) = lowrange(list_of_symbols(i-1));
        lowrange(list_of_symbols(i)) = vpa(highrange(list_of_symbols(i)) - probabilities(i));
    end
   
    %Fill the decoded_sequence by calculating with the given formulas. A
    %test condition is made to check if the decoded_sequence is at value 0,
    %and thus, 0 should not be included in the DNA alphabet.
    decoded_sequence = zeros(1,size);
    for i = 1 : size
        for j = 1 : length(list_of_symbols)
            if decoded_sequence(i) ~= 0
                break
            end
            if (decimal < highrange(j)) && (decimal >= lowrange(j))
                decoded_sequence(i) = list_of_symbols(j);
                if j == length(list_of_symbols)
                    decimal = vpa(decimal / probabilities(j))
                else
                    decimal = vpa((decimal - lowrange(j)) / probabilities(j))
                end 
            end
        end
    end
end
