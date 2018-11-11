for ii=1:16
    [PO(:,ii) fo]=pwelch(detrend(DataOpened(:,ii)),2000,1500,2^17,1000);
    [PC(:,ii) fc]=pwelch(detrend(DataClosed(:,ii)),2000,1500,2^17,1000);
    subplot(4,4,ii)
    plot(fo,PO(:,ii),'r')
    hold on
    plot(fc,PC(:,ii),'k')
    hold off
    title(int2str(ii))
    xlim([0 20])
    ii
end

save PSD_OC fo fc PO PC