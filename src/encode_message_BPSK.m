function [A] = encode_message_BPSK(background_audio, message)
    % Encodes an ASCII message into a BPSK signal applied to a carrier wave
    % and added background audio signal. This technique works well if the
    % carrier is at a high frequency (~ultrasonic) such that it is
    % inaudible to the human ear.
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
    %
    % Returns:
    %
    %  - A : column vector of secret audio

    run("src/constants.m")

    message_length = length(message);
    remainder = mod(message_length, chars_per_group);

    if remainder ~=0 
        num_chars_to_add = chars_per_group - remainder;
        message = [message blanks(num_chars_to_add)];
    end

    bits = (0:7)';

    message_bits = reshape(... % use reshape to create 1 column for each group of characters
        bitand(double(message), bitshift(1, bits)) > 0,...
        chars_per_group * BITS_PER_BYTE, []...
    );

    message_symbols = message_bits * 2 - 1;

    % add sync sequence to each group of characters
    num_groups = size(message_symbols, 2);
    sync_symbols = repmat(sync_sequence', [1 num_groups]);
    
    % add sync symbols and reshape to column vector
    symbols_with_sync = reshape(...
        [sync_symbols ; message_symbols], ...
        [], 1 ...
    );

    symbols_per_group = chars_per_group * BITS_PER_BYTE + length(sync_sequence);
    symbols_duration_seconds = symbols_per_group * num_groups / symbol_rate;

    assignin('base', 'symbols_with_sync', symbols_with_sync) % for analysis later
    
    carrier_samples = symbols_duration_seconds * Fs;
    T = (1:carrier_samples)/Fs;
    
    carrier_wave = cos(2 * pi * carrier_frequency * T') * carrier_amplitude;
    
    % pulse shape the symbols    
    baseband_signal = conv(upsample(symbols_with_sync, samples_per_symbol), rcpulse);

    % apply modulation
    modulated_carrier = carrier_wave .* baseband_signal(1:length(symbols_with_sync)*samples_per_symbol);

    assignin('base', "modulated_carrier", modulated_carrier); % for analysis later
    
    % add to background
    A = modulated_carrier .* message_amplitude + background_audio(1:length(modulated_carrier));

end