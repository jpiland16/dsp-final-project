function [A] = encode_message_LSB(background_audio, message)
    % Encodes an ASCII message into the least significant bit of an audio
    % signal.
    %
    % NOTE: the audio must be long enough to encode the message. The
    %       audio will be truncated to the minimum length required.
    %
    % Parameters: 
    %
    %  - background_audio : column vector 
    %  - message          : character vector
    %
    % Returns:
    %
    %  - A : column vector of secret audio

    run("src/constants.m")

    num_audio_samples_required = length(message) * BITS_PER_BYTE;

    A = background_audio(1:num_audio_samples_required);

    for i = 1:length(message)
        % NOTE: this could be implemented much more efficiently, but is
        % shown with two `for` loops here for clarity. 
        character = message(i);
        for b = 1:BITS_PER_BYTE
            if (bitand(double(character), bitshift(1, b-1)) > 0)
                A((i - 1) *  BITS_PER_BYTE + b) = bitset( A((i - 1) *  BITS_PER_BYTE + b), 1, 1); % set LSB
            else
                A((i - 1) *  BITS_PER_BYTE + b) = bitset( A((i - 1) *  BITS_PER_BYTE + b), 1, 0); % clear LSB
            end
        end
    end
end