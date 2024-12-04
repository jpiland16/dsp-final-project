function [F] = plot_fft_with_Fs(data, Fs)
    % Plot the fft of `data` with frequency in Hz labeled on the x-axis.
    %
    % Parameters:
    %  - data : data for which abs(fftshift(fft(X))) will be plotted
    %  - Fs   : sampling rate in Hz
    
    N = length(data);
    frequencies = -Fs/2 : Fs/N : (Fs/2 - Fs/N);

    plot(frequencies, abs(fftshift(fft(data))));

    xlabel("Frequency (Hz)")
    ylabel("Magnitude")

    if nargout == 1
        F = frequencies;
    end
end