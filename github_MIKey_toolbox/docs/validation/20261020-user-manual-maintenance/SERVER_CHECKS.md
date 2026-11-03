# Server validation after dependency cleanup

Pending; no local MATLAB run or code checker was executed.

Upload the entire current original toolbox folder while MATLAB is stopped. Remove stale deleted scripts on the server using script-dependencies.json only if the upload is an overlay; copying over files does not delete obsolete files. Do not delete configs, data or templates. A fresh source install beside separately stored BIDS data/configs avoids mixing old and new helpers.

In server MATLAB:

~~~matlab
toolboxRoot='/shared/software/MIKey_toolbox_main';
addpath(toolboxRoot); addpath(fullfile(toolboxRoot,'scripts'));
addpath(fullfile(toolboxRoot,'examples')); addpath(fullfile(toolboxRoot,'tests'));
MIKey_setup('/shared/software/spm12');
report=MIKey_verify_installation(); assert(report.ok);
checkcode(fullfile(toolboxRoot,'scripts','MIKey_verify_installation.m'),'-id');
[required,products]=matlab.codetools.requiredFilesAndProducts( ...
    {fullfile(toolboxRoot,'MIKey.m'),fullfile(toolboxRoot,'examples','run_mikey.m'), ...
     fullfile(toolboxRoot,'examples','submit_mikey_configs.m')});
disp(required); disp(products);
test_mikey_config_scopes;
test_mikey_config_choices;
test_mikey_config_paths;
test_mikey_config_export;
test_mikey_bids_spm_routing('/shared/software/spm12');
test_mikey_tissue_segmentation('/shared/software/spm12');
~~~

Use exact source-snapshot.json hashes because this original folder has no Git checkout/commit. Record actual command, environment, metrics, output markers and failures in the run report. The routing and segmentation fixtures use synthetic/copy-only data and do not establish real-image scientific quality.

For the integrity helper, additionally use an isolated temporary source copy: change one byte of a core file and require report.modified; remove one core file and require report.missing; add a scripts .m file and require report.unexpected. Changing a config must not fail checks. Never modify the production installation for these checks. Restore the disposable fixture from trusted source before each case.

After upload run bash maintenance/set_code_readonly.sh protect; confirm core source is nonwritable and config_project.m is writable. Review independent job outputs on a disposable test BIDS dataset before replacing a production install. Unchanged files may be skipped, so a skipped stage is not evidence of an executed runtime check.

Local maintenance evidence: 224 original scripts, 142 removals, 82 retained originals plus 1 new checker; no retained source token references a removed name; all 125 core content hashes matched; Windows Protect set 126 read-only items including manifest, and four existing config functions remained writable. Linux permission helper and MATLAB checker are not locally executed.
