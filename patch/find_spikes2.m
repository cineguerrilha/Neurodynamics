function [amps, t, isi]=find_spikes(d,ti);

%time=(1:length(d))*(si);
time=tt;

plot(time,d)

disp('Mark threshold and length');


thr=ginput(1);
DL=thr(1);
thr=thr(2)

%DataLength=find(time>DL);
%DataLength=DataLength(1);

%d=d(1:round(DataLength));
%time=time(1:round(DataLength));

plot(time,d,'k')

cnt=1;
spkOn=0;
hold on

for ii=1:length(d)
    if d(ii)>thr
        if d(ii)<d(ii-1) && spkOn==0
            spkOn=1;
            amps(cnt)=d(ii);
            t(cnt)=time(ii);
            plot(t(cnt),amps(cnt),'ro')
            
            if cnt>1
                isi(cnt)=t(cnt)-t(cnt-1);
            end
            cnt=cnt+1;
        end
    end
    
    if spkOn==1 && d(ii)<thr
            spkOn=0;
    end
end

hold off

