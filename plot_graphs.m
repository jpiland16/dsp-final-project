plot_fft_with_Fs(background_audio, Fs)
exportgraphics(gcf, "img/01_original_spectrum.png", Resolution=300)

plot_fft_with_Fs(secret_audio - background_audio, Fs)
exportgraphics(gcf, "img/02_difference_spectrum.png", Resolution=300)

frequencies = plot_fft_with_Fs(secret_audio_repeat - background_audio(1:length(secret_audio_repeat)), Fs);
exportgraphics(gcf, "img/03_difference_spectrum_repeat.png", Resolution=300)

hold on
plot(frequencies, 5*10^4 * abs(sinc(frequencies / (44100/16))) )
hold off
exportgraphics(gcf, "img/04_difference_spectrum_repeat_sinc.png", Resolution=300)


frequencies = plot_fft_with_Fs(secret_audio_noisy_repeat - background_audio(1:length(secret_audio_repeat)), Fs);

hold on
plot(frequencies, 5*10^4 * abs(sinc(frequencies / (44100/16))) )
hold off
exportgraphics(gcf, "img/05_difference_spectrum_repeat_sinc_noisy.png", Resolution=300)

%%
stem(symbols_with_sync(1:48))
xlabel("Symbol number")
ylabel("Value")
exportgraphics(gcf, "img/06_symbols.png", Resolution=300)

plot_fft_with_Fs(upsample(symbols_with_sync, samples_per_symbol), Fs);
exportgraphics(gcf, "img/07_fft_symbols_up.png", Resolution=300)

plot(rcpulse)
xlabel("Sample number")
ylabel("Value")
exportgraphics(gcf, "img/08_rcpulse.png", Resolution=300)

freqz(rcpulse, 1, 512, Fs)
exportgraphics(gcf, "img/09_rcpulse_fft.png", Resolution=300)

grpdelay(rcpulse, 1, 512, Fs)
exportgraphics(gcf, "img/10_rcpulse_fft.png", Resolution=300)

baseband = conv(upsample(symbols_with_sync, samples_per_symbol), rcpulse);
plot_fft_with_Fs(baseband, Fs);
exportgraphics(gcf, "img/11_fft_symbols_up.png", Resolution=300)

%%
plot(baseband(1:1024))
add_rectangles(symbols_with_sync(1:64), 0.1, 88 - 8, samples_per_symbol);
xlabel("Sample number")
ylabel("Value")
exportgraphics(gcf, "img/12_baseband.png", Resolution=300)

eye_diagram(symbols_with_sync(1:1000), baseband, 88 - 8, samples_per_symbol);
exportgraphics(gcf, "img/12_eyediagram.png", Resolution=300)

%%

plot_fft_with_Fs(modulated_carrier, Fs);
exportgraphics(gcf, "img/13_mc_fft.png", Resolution=300)

plot(modulated_carrier(1:512))
add_rectangles(symbols_with_sync(1:27), 0.1, 88 - 8, samples_per_symbol);
xlabel("Sample number")
ylabel("Value")
exportgraphics(gcf, "img/14_mc.png", Resolution=300)

plot_fft_with_Fs(secret_audio_bpsk, Fs)
exportgraphics(gcf, "img/15_bpsk_fft.png", Resolution=300)

%%
show_scores(secret_audio_bpsk, samples_per_symbol)
xlabel("Timing offset (in number of samples)")
ylabel("Deviation score (higher is better)")
exportgraphics(gcf, "img/16_scores.png", Resolution=300)



%%

eye_diagram(symbols_with_sync(1:1000), baseband_first, samples_per_symbol * (filter_clip - 0.5), samples_per_symbol);
exportgraphics(gcf, "img/17_eyediagram1.png", Resolution=300)


eye_diagram(symbols_with_sync(1:1000), baseband1, samples_per_symbol * (filter_clip - 0.5), samples_per_symbol);
exportgraphics(gcf, "img/18_eyediagram2.png", Resolution=300)

function add_rectangles(symbols, height, delay, samples_per_symbol)
    % add colored rectangles to the plot

    for i = 1:length(symbols)
        s = symbols(i);
        if s == 1
            color = [0 1 0 0.2];
        else
            color = [1 0 0 0.2];
        end
        X = (i - 1) * samples_per_symbol + delay;
        Y = -height/2;
        H = height;
        W = samples_per_symbol;
        rectangle('Position', [X Y W H], FaceColor=color);
    end
end


function eye_diagram(symbols, baseband, delay, samples_per_symbol)
    % show possible ISI diagram
    clf()
    hold on
    for i = 1:length(symbols)
        s = symbols(i);
        if s == 1
            color = [0 0.7 0 0.2];
        else
            color = [0.8 0 0 0.2];
        end
        start = 1 + (i - 1) * samples_per_symbol + delay;
        stop =  i * samples_per_symbol + delay;
        data = baseband(start:stop);
        plot(data, color=color)
    end
    hold off
end


function show_scores(synchronized_signal, samples_per_symbol)

    scores = zeros([1 samples_per_symbol]);

    for i = 0:(samples_per_symbol - 1)
        num_symbols_to_check = floor((length(synchronized_signal) - i) / samples_per_symbol);
        score = 0;
        for j = 0:(num_symbols_to_check - 1)
            score = score + abs(mean(synchronized_signal(1 + j * samples_per_symbol + i: (j + 1) * samples_per_symbol + i)));
        end
        scores(i + 1) = score/num_symbols_to_check;
    end
    
    
    plot(0:(samples_per_symbol - 1), scores, "-o")
end

