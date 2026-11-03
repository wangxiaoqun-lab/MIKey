try
    clear MIKey_registration_qc run_real_demo_pipeline;
    rehash path;
    run_real_demo_pipeline('guarded-original','01');
    MIKeyRealDemoFolder20261016=fileparts(mfilename('fullpath'));
    MIKeyGuardResult20261016=jsondecode(fileread(fullfile(MIKeyRealDemoFolder20261016,'guarded-original-result.json')));
    assert(strcmp(MIKeyGuardResult20261016.status,'failed'));
    assert(numel(MIKeyGuardResult20261016.stages)==1 && MIKeyGuardResult20261016.stages.step==6);
    initialize_demo_copy;
    run_real_demo_pipeline('initialized-run01','01');
catch MIKeyDemoError20261016
    disp(getReport(MIKeyDemoError20261016,'extended','hyperlinks','off'));
end
clear MIKeyDemoError20261016 MIKeyRealDemoFolder20261016 MIKeyGuardResult20261016;
