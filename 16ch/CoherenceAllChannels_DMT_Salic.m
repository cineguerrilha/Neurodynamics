PCh=[3
3
4
4
4
6
6];

VCh=[15
15
14
11
15
13
14
15];
%%
for ii=1:8
    vd=animal_zscore(ii).baseline.dataZ(:,VCh(ii));
    pd=animal_zscore(ii).baseline.dataZ(:,PCh(ii));
    [CvpC(:,ii) f]=mscohere(vd,pd,2000,1500,2^17,1000);
    ii
end
%%
for ii=1:8
    vd=animal_zscore(ii).salicylate.dataZ(:,VCh(ii));
    pd=animal_zscore(ii).salicylate.dataZ(:,PCh(ii));
    [CvpS(:,ii) f]=mscohere(vd,pd,2000,1500,2^17,1000);
    ii
end

%%
for ii=8:8
    vd=animal_zscore(ii).DMT_salicylate.dataZ(:,VCh(ii));
    pd=animal_zscore(ii).DMT_salicylate.dataZ(:,PCh(ii));
    [CvpD(:,ii-1) f]=mscohere(vd,pd,2000,1500,2^17,1000);
    ii
end
%%
for ii=1:7
    subplot(2,1,1)
    plot(f, CvpC(:,ii),'k')
    hold on
    plot(f, CvpS(:,ii),'r')
    hold off
    xlim([0 10])
    
    subplot(2,1,2)
    plot(f, CvpC(:,ii),'k')
    hold on
    plot(f, CvpS(:,ii),'r')
    hold off
    xlim([30 100])
    
    
    ii
    pause
end

%%
for ii=1:7
    subplot(2,1,1)
    plot(f, CvpS(:,ii),'r')
    hold on
    plot(f, CvpD(:,ii),'g')
    hold off
    xlim([0 10])
    
    subplot(2,1,2)
    plot(f, CvpS(:,ii),'r')
    hold on
    plot(f, CvpD(:,ii),'g')
    hold off
    xlim([30 100])
    
    ii
    pause
end

%%
% Measure coherence in t2 e t1

t2=[3 5];
t1=[7 10];

for ii=1:7
    CVC(ii,1)=max(CvpC(f>t2(1) & f<t2(2),ii));
    CVS(ii,1)=max(CvpS(f>t2(1) & f<t2(2),ii));
end

%%
for ii=1:7
    CVD(ii,1)=max(CvpD(f>t2(1) & f<t2(2),ii));
end

%%

for ii=1:7
    plot(f, CvpC(:,ii),'k')
    hold on
    plot(f, CvpS(:,ii),'r')
    hold off
    xlim([0 10])
    ylim([0 0.5])
    box off
    set(findall(gcf,'-property','FontSize'),'FontSize',18)
    set(findall(gcf,'-property','FontName'),'FontName','arial')
    ii
    pause
end

%%
%------------Animais Velhos

PCh = [
3
4
3
4
5
4
4
];

VCh = [
14
12
13
11
14
11
12
];

for ii=9:15   
    vd=animal_zscore(ii).baseline.dataZ(:,VCh(ii-8));
    pd=animal_zscore(ii).baseline.dataZ(:,PCh(ii-8));
    [CvpC(:,ii-8) f]=mscohere(vd,pd,2000,1500,2^17,1000);
    ii
end
%%
for ii=9:15
    vd=animal_zscore(ii).salicylate.dataZ(:,VCh(ii-8));
    pd=animal_zscore(ii).salicylate.dataZ(:,PCh(ii-8));
    [CvpS(:,ii-8) f]=mscohere(vd,pd,2000,1500,2^17,1000);
    ii
end