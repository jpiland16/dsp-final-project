% NOTE: This document contains code that runs the functions needed to
% execute the project and generate all associated figures, etc. The actual
% functions can be found in the `src` folder. This file is primarily for
% ANALYSIS of the results, not for the creation of the results.

% seed the RNG to get the same results every time
rng(555);

addpath("src")
run("src/constants.m")

[audio, Fs] = audioread("background/weeknd.wav");
lewis = fileread("secret_messages/lewis.txt");

secret_message = lewis(1:Fs); % select Fs characters --> 8 seconds

% select just one channel, and start 10 seconds in; convert to integer
audio_int32 = int32(audio(:, 1) * (2^31)); 
background_audio = audio_int32(10*Fs:18*Fs - 1); 

secret_audio = encode_message_LSB(background_audio, secret_message);
received_message = decode_message_LSB(secret_audio);

% listen to secret audio
% soundsc(double(secret_audio), Fs);
audiowrite("generated_examples/01_lsb_lewis_8s.wav", secret_audio, Fs, "BitsPerSample", 32);

% verify message can be decoded from WAV file
[secret_audio_again, Fs] = audioread("generated_examples/01_lsb_lewis_8s.wav");
received_message_again = decode_message_LSB(int32(secret_audio_again * 2^31));

disp(received_message_again(1:100))

assert(all(received_message_again == secret_message), "received message from file not equal to secret message")

%% now try adding tiny noise to secret audio

secret_audio_noisy = secret_audio + int32((randn(size(secret_audio)) * 0.0000000002) * 2^31);
received_message_noisy = decode_message_LSB(secret_audio_noisy);
audiowrite("generated_examples/02_lsb_lewis_8s_noisy.wav", secret_audio, Fs, "BitsPerSample", 32);

disp(received_message_noisy(1:100))
correct = sum(received_message_noisy == secret_message);
disp(correct)
disp(length(secret_message))
disp(correct/length(secret_message))

%% demonstrate working of repeat method

N = 16; % 16 repeats
secret_message_short = secret_message(1:floor(Fs/N)); % select 8 seconds of characters
secret_audio_repeat = encode_message_LSB_repeat(background_audio, secret_message_short, N);
audiowrite("generated_examples/03_lsb_lewis_8s_repeat.wav", secret_audio_repeat, Fs, "BitsPerSample", 32);

received_message_repeat = decode_message_LSB_repeat(secret_audio_repeat, N);
assert(all(received_message_repeat == secret_message_short), "received message with repeat not equal to secret message")

disp(received_message_repeat(1:100))

%% try adding noise there

secret_audio_noisy_repeat = secret_audio_repeat + int32((randn(size(secret_audio_repeat)) * 0.0000000002) * 2^31);
received_message_noisy_repeat = decode_message_LSB_repeat(secret_audio_noisy_repeat, N);
audiowrite("generated_examples/04_lsb_lewis_8s_repeat_noisy.wav", secret_audio_noisy_repeat, Fs, "BitsPerSample", 32);

disp(received_message_noisy_repeat(1:100))
correct = sum(received_message_noisy_repeat == secret_message_short);
disp(correct)
disp(length(secret_message_short))
disp(correct/length(secret_message_short))

%% demonstrate working of BPSK method

% estimate overhead of adding sync sequence to determine audio length
% needed
sync_overhead = (chars_per_group + length(sync_sequence)/BITS_PER_BYTE) / chars_per_group;
chars_per_second = Fs / samples_per_symbol / BITS_PER_BYTE / sync_overhead;
chars_8seconds_count = chars_per_group * ceil(chars_per_second * 8 / chars_per_group);
chars_duration = chars_8seconds_count / chars_per_second;

secret_message_bpsk = secret_message(1:chars_8seconds_count);
background_audio_bpsk = audio(10*Fs : (10 + chars_duration) * Fs)';

secret_audio_bpsk = encode_message_BPSK(background_audio_bpsk, secret_message_bpsk);
audiowrite("generated_examples/05_lsb_lewis_8s_bpsk.wav", secret_audio_bpsk, Fs, "BitsPerSample", 32);

received_message_bpsk = decode_message_BPSK(secret_audio_bpsk);
disp(received_message_bpsk(1:100))

valid_message = received_message_bpsk(1:chars_8seconds_count);

correct = sum(valid_message == secret_message_bpsk);
disp(correct)
disp(length(secret_message_bpsk))
disp(correct/length(secret_message_bpsk))

%% demonstrate read/write from file

[secret_audio_bpsk_again, Fs] = audioread("generated_examples/05_lsb_lewis_8s_bpsk.wav");
received_message_bpsk_file = decode_message_BPSK(secret_audio_bpsk_again);
disp(received_message_bpsk(1:100))

%% demonstrate resilience to noise

secret_audio_bpsk_noisy = secret_audio_bpsk + randn(size(secret_audio_bpsk)) * 0.1;
audiowrite("generated_examples/06_lsb_lewis_8s_bpsk_noisy.wav", secret_audio_bpsk_noisy, Fs, "BitsPerSample", 32);

baseband_first = baseband1; % pull variable from other file for plotting in analysis

received_message_bpsk_noisy = decode_message_BPSK(secret_audio_bpsk_noisy);
disp(received_message_bpsk_noisy(1:100))

valid_message = received_message_bpsk_noisy(1:chars_8seconds_count);

correct = sum(valid_message == secret_message_bpsk);
disp(correct)
disp(length(secret_message_bpsk))
disp(correct/length(secret_message_bpsk))

%% show plots

run("plot_graphs.m")
