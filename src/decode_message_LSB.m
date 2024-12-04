function [M] = decode_message_LSB(audio)
    % Retrieves an ASCII message that was embedded into the least
    % significant bit of an audio signal.
    %
    % Parameters: 
    %
    %  - audio : column vector containing message in LSB
    %
    % Returns:
    %
    %  - M : character vector (row) of decoded message

    run("src/constants.m")

    num_characters = floor(length(audio) / BITS_PER_BYTE);

    M = blanks(num_characters);
    
    for i = 1:num_characters
        ascii = 0;
        for b = 1:BITS_PER_BYTE
            if bitand(audio((i - 1) * BITS_PER_BYTE + b), 1) > 0
                ascii = bitset(ascii, b);
            end
        end
        M(i) = char(ascii);
    end

end