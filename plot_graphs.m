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