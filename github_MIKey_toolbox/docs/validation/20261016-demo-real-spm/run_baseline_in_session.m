try
    run_real_demo_pipeline('baseline');
catch MIKeyDemoError20261016
    disp(getReport(MIKeyDemoError20261016,'extended','hyperlinks','off'));
end
clear MIKeyDemoError20261016;
