# Use the confirmed direct launcher model

Expose local as an explicit mode of the existing generic helper. It starts independent MATLAB processes on the current node without calling a scheduler, while reusing config snapshots and conflict checks. Use the current MATLAB executable rather than expecting Bash aliases in noninteractive child shells. Preserve scientific settings and distinguish wrapper launch from computation completion using exit-code files. Do not imply scheduler resource reservation or cross-node dispatch.
