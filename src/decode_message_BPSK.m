function [M] = decode_message_BPSK(received_signal)
    % Uses a Costas loop to recover the baseband signal from a
    % BPSK-modulated carrier added to background audio. Selects the signal
    % and decodes symbols back into the ASCII message.
    %
    % Parameters:
    %
    %  - received_signal : column vector of audio with BPSK signal
    %
    % Returns:
    %
    %  - M : character vector (row) of decoded message

    run("src/constants.m")

    phi             = zeros(length(received_signal), 1);
    xi              = zeros(length(received_signal), 1);
    xq              = zeros(length(received_signal), 1);
    error           = zeros(length(received_signal), 1);
    
    
    %% Costas loop
    % Modified from https://schaumont.dyn.wpi.edu/ece4703b21/lecture10.html
    
    pulse_length = length(rcpulse);
    pulse_vertical = rcpulse';
    start = pulse_length;

    for i = start:length(received_signal)
        
        if mod(i, 50000) == 0
            % Used to show progress
            disp(i) 
        end

        xi(i)    = received_signal(i) .* cos(- 2 * pi * i * carrier_frequency_relative_to_symbol_frequency / samples_per_symbol - phi(i-1));
        xq(i)    = received_signal(i) .* sin(- 2 * pi * i * carrier_frequency_relative_to_symbol_frequency / samples_per_symbol - phi(i-1));

        zi_1     =  sum(pulse_vertical .* flip(xi(i - pulse_length + 1 : i)));
        zq_1     =  sum(pulse_vertical .* flip(xq(i - pulse_length + 1 : i)));
        
        error(i) = zi_1 * zq_1;
        
        phi(i)   = phi(i-1) + error_factor * error(i);
    end

    zi = conv(rcpulse, xi);

    % assignin('base', 'zi', zi) % debug

    %% symbol timing recovery
    synchronized_signal = zi(1:end);
    
    % possible offsets are 0-(SPS - 1) 
    scores = zeros([1 samples_per_symbol]);
    
    for i = 0:(samples_per_symbol - 1)
        num_symbols_to_check = floor((length(synchronized_signal) - i) / samples_per_symbol);
        score = 0;
        for j = 0:(num_symbols_to_check - 1)
            score = score + abs(mean(synchronized_signal(1 + j * samples_per_symbol + i: (j + 1) * samples_per_symbol + i)));
        end
        scores(i + 1) = score/num_symbols_to_check;
    end
    
    
    plot(0:(samples_per_symbol - 1), scores)

    assignin('base', 'baseband1', synchronized_signal); % used for plotting later

    % select the offset that gives us the maximum mean absolute deviation
    [~, offset_index] = max(scores);
    offset = offset_index - 1;
    
    %% shift to offset and read symbols
    readable_signal = synchronized_signal(offset:end);
    num_symbols_to_read = floor(length(readable_signal) / samples_per_symbol);
    
    decoded_symbols = zeros([num_symbols_to_read 1]);
    
    for i = 1:num_symbols_to_read
        % check the center of the symbol for +/- phase
        decoded_symbols(i) = readable_signal((i - 0.5) * samples_per_symbol) > 0;
    end

    % assignin('base', 'ds', decoded_symbols); % debug

    %% resolve phase ambiguity
    sync_logic = sync_sequence' > 0;
    
    % check for 180 degree rotation
    for i = 1:(length(decoded_symbols) - length(sync_logic))
        if all(decoded_symbols(i:i+length(sync_logic) - 1) == ~sync_logic)
            disp("180 degree phase rotation detected, flipping...")
            decoded_symbols = ~decoded_symbols;
            break
        end
    end

    %% discard sync sequences

    num_chars_to_read = floor(length(decoded_symbols) / BITS_PER_BYTE);
    char_symbols = zeros([1 num_chars_to_read * BITS_PER_BYTE]);
    
    char_bit_counter = 1;
    
    L = length(symbol_sync);
    symbol_count = chars_per_group * BITS_PER_BYTE;
    
    i = L + 1;
    while i + symbol_count <= length(decoded_symbols)
        if all(decoded_symbols(i - L : i - 1) == (symbol_sync' + 1) * 0.5)
            char_symbols(char_bit_counter : char_bit_counter + symbol_count - 1) = decoded_symbols(i : i + symbol_count - 1);
            i = i + symbols_per_group;
            char_bit_counter = char_bit_counter + symbol_count;
        else
            i = i + 1;
        end
    end
    
    %% convert bits to ASCII characters
    
    C = length(char_symbols);
    ascii_columns = reshape(... % convert to one column per character
        char_symbols(1:C - mod(C, BITS_PER_BYTE)), ...
        BITS_PER_BYTE, []...
    );

    bit_values = 2.^((0:7)');
    
    % collapse columns to sum binary places and convert to character
    M = char(sum(ascii_columns .* bit_values));

end