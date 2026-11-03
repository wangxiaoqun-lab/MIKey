# BOLD threshold and cooperative GUI control

Use a strict T < N exclusion rule with default N=0 for backward compatibility. Apply it centrally to raw BOLD selection, not anatomical/fieldmap dependencies. Include nonzero N in group/concatenation namespaces and report exclusions, so cached short-run estimates cannot re-enter group analysis.

Use cooperative control in the current MATLAB session to avoid requiring another MATLAB license or PCT worker. Pause/Stop must propagate through processing catches and restore GUI state on cleanup. An active native SPM/MEX call is allowed to return before the next checkpoint; do not pretend requests interrupt native code immediately. Preserve the existing three-column layout and add only the requested top-row controls.
