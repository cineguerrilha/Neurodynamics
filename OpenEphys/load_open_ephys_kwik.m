function DATA = load_open_ephys_kwik(filename)
%20160126, Coded by C. Latchoumane
%load kwik format recorded from open ephys 0.3.5
%not coded in a systematic way

display('Loading OpenEphys Kwik format(2) >0.3.5')
%get extension
dt = find(filename=='.');
dt = dt(end);
ext = filename(1,dt+1:end);
%
switch ext
    case 'kwx' %spike file
        display('loading OpenEphys data (kwik format=2)')
        
        info = h5info(filename);
        
        num_data = size(info.Groups.Groups,1);%number of tetrode or groupings
        %attributes
        filenamek1 = ls('*.kwik');
        filenamek2 = ls('*.kwe');
        if isempty(filenamek1)
            sample_rate = uint64(h5readatt(filenamek2,'/recordings/0/','sample_rate'));
            start_time = 1e6*h5readatt(filenamek2,'/recordings/0/','start_time')/sample_rate;%usec
        else
            sample_rate = uint64(h5readatt(filenamek1,'/recordings/0/','sample_rate'));
            start_time = 1e6*h5readatt(filenamek1,'/recordings/0/','start_time')/sample_rate;%usec
        end
        for tt = 1:num_data
            
            rec = h5read(filename,['/channel_groups/' num2str(tt-1) '/recordings']);%
            ts = h5read(filename,['/channel_groups/' num2str(tt-1) '/time_samples']);%timestamps
            data = h5read(filename,['/channel_groups/' num2str(tt-1) '/waveforms_filtered']);%4x40xsamples
            
            display(['Extracted TT' num2str(tt-1) ', #spikes ' num2str(length(rec))])
            DATA{tt,1} = ['TT' num2str(tt-1)];
            DATA{tt,2} = (1e6*ts./sample_rate);%%convert in usec
            DATA{tt,3} = data;
            DATA{tt,4} = rec;
        end
        clear rec ts data
    case {'kwe','kwik'} %event file
        %inspired from antonin blot's post (openephys forum discussion)
        %"open ephys kwik format"
        ttl_time = h5read(filename, '/event_types/TTL/events/time_samples');
        ttl_rec = h5read(filename, '/event_types/TTL/events/recording');
        ttl_eventID = h5read(filename, '/event_types/TTL/events/user_data/eventID');
        ttl_chan = h5read(filename, '/event_types/TTL/events/user_data/event_channels');
        ttl_nodeID = h5read(filename, '/event_types/TTL/events/user_data/nodeID');
        
        %attributes
        info = 0;
        
        info.sample_rate = uint64(h5readatt(filename,'/recordings/0/','sample_rate'));
        info.start_time = 1e6*h5readatt(filename,'/recordings/0/','start_time')./info.sample_rate;%usec
        DATA{1,1} = 'TTL events';
        DATA{1,2} = horzcat(1e6*ttl_time/info.sample_rate, ttl_chan, ttl_rec, ttl_eventID, ttl_nodeID);
        DATA{1,3} = info;
    case 'kwd' %continuous recordings
        data = double(h5read(filename,'/recordings/0/data'));
        %info attributes
        info = 0;
        
        info.sample_rate = uint64(h5readatt(filename,'/recordings/0/','sample_rate'));
        info.start_time = 1e6*h5readatt(filename,'/recordings/0/','start_time')./info.sample_rate;%in usec
        %info.start_time = h5readatt(filename,'/recordings/0/','start_time');%in sample
        info.bit_depth = h5readatt(filename,'/recordings/0/','bit_depth');
        info.channel_bit_volts = double(h5read(filename,'/recordings/0/application_data/channel_bit_volts'));
        %assume constant sampling rate
        ts = 1e6*uint64(1:length(data))/info.sample_rate + info.start_time;
        DATA{1,1} = info;
        DATA{1,2} = ts;%usec
       DATA{1,3} = data*info.channel_bit_volts(1);%convert to uv
    otherwise
        display('format not supported')
        
end

