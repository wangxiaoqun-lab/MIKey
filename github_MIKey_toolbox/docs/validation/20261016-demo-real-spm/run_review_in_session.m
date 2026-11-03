try
    clear render_real_demo_overlays test_real_demo_gui_stops;
    rehash path;
    render_real_demo_overlays(1);
    test_real_demo_gui_stops;
    run_real_demo_pipeline('restored-cache-run01','01');
catch MIKeyDemoError20261016
    disp(getReport(MIKeyDemoError20261016,'extended','hyperlinks','off'));
end
clear MIKeyDemoError20261016;
