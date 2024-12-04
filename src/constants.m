BITS_PER_BYTE = 8;

carrier_sync = ones(1, 16);
symbol_sync = repmat([1 -1], [1 8]);

sync_sequence = [carrier_sync symbol_sync];


samples_per_symbol = 16;                            % NOTE: characters per second will be Fs / (SPS * BITS_PER_BYTE)
carrier_frequency_relative_to_symbol_frequency = 7; % NOTE: if (CF/SF) is greather than (Fs / SPS), then the carrier frequency may be less than expected due to aliasing
carrier_amplitude = 1;                              % amplitude of carrier wave before modulation
chars_per_group   = 32;                             % number of characters sent before sync sequence is repeated
message_amplitude = 1;                              % amplitude scaling of modulated carrier before addition to background signal

error_factor      = 0.0001;                         % tuning factor for Costas loop in phase detection


rolloff           = 0.25; % [0, 1] rolloff of RRC filter
filter_clip       = 11;   % in number of symbol periods

Fs = 44100;


%% calculated values
symbol_rate       = Fs / samples_per_symbol;
carrier_frequency = symbol_rate * carrier_frequency_relative_to_symbol_frequency;
symbols_per_group = chars_per_group * BITS_PER_BYTE + length(sync_sequence);

rcpulse = rcosdesign(rolloff, filter_clip, samples_per_symbol, 'sqrt');
