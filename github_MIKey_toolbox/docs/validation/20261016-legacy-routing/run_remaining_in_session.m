try
    run_remaining_checks;
catch MIKeyValidationError20261016
    disp(getReport(MIKeyValidationError20261016,'extended','hyperlinks','off'));
end
clear MIKeyValidationError20261016;
