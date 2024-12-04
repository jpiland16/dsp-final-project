function [M] = decode_message_LSB(audio, n_repeats)
    % Retrieves an ASCII message that was embedded into the least
    % significant bit of an audio signal, and where each bit was repeated N
    % times.
    %
    % NOTE: the length of `audio` must be a multiple of `n_repeats`.
    %
    % Parameters: 
    %
    %  - audio     : column vector containing message in LSB
    %  - n_repeats : integer number of times to repeat each bit
    %
    % Returns:
    %
    %  - M : character vector (row) of decoded message

    run("src/constants.m")
    
    lsbs = reshape(...
        bitand(audio, 1),... % extract LSBs
        n_repeats, []... % group into columns by repeats
    );
    
    % collapse columns by consensus (majority) and reshape by byte
    consensus_lsbs = reshape(...
        mean(lsbs) > 0.5, ...
        BITS_PER_BYTE, []...
    );

    bit_values = 2.^((0:7)');
    
    % collapse columns again to sum binary places and convert to character
    M = char(sum(consensus_lsbs .* bit_values));
    
end