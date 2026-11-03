try
    replay_remaining_sequence;
catch MIKeyReplayError20261016
    disp(getReport(MIKeyReplayError20261016,'extended','hyperlinks','off'));
end
clear MIKeyReplayError20261016;
