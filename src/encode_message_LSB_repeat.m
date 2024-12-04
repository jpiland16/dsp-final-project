function [A] = encode_message_LSB_repeat(background_audio, message, n_repeats)
    % Encodes an ASCII message into the least significant bit of an audio
    % signal. Each bit is repeated N times (i.e. there will be N samples
    % with an LSB of 1 or N samples with an LSB of 0 before the next
    % character from the message is encoded.)
    %
    % NOTE: the audio must be long enough to encode the message. The
    %       audio will be truncated to the minimum length required.
    %
    % NOTE: The message must be a row vector. (This is the default for
    %       character arrays.)
    %
    % Parameters: 
    %
    %  - background_audio : column vector 
    %  - message          : character vector
    %  - n_repeats        : integer number of times to repeat each bit
    %
    % Returns:
    %
    %  - A : column vector of secret audio

    run("src/constants.m")

    num_audio_samples_required = length(message) * BITS_PER_BYTE * n_repeats;

    A = background_audio(1:num_audio_samples_required);

    % actually do this efficiently
    bits = (0:7)';

    message_bits = reshape(... % use reshape to create row vector
        bitand(double(message), bitshift(1, bits)) > 0,...
        1, []...
    );

    % repeat the bits N times and reshape to column vector
    bits_with_repeats = reshape(...
        repmat(message_bits, n_repeats, 1),... % repeat vertically
        [], 1 ...
    );

    % modify audio
    A = bitset(A, 1, bits_with_repeats);

end