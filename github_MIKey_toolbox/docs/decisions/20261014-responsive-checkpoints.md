# Bounded Stage 1 I/O for GUI run control

Date: 2026-10-14.

Keep the existing GUI layout and the original callback entry points. Explicitly allow callback interruption/queuing on releases exposing those properties. Yield with drawnow and a short pause at bounded checkpoints so the web UI has time to deliver events.

Do not move the entire calculation into a long timer callback: R2018a live-control regression tests showed that this prevents the control observer from executing during processing. That prototype was removed before delivery.

Stage 1 processes one BOLD volume at a time rather than materializing an entire run before checking controls. Raw copying and gzip extraction use bounded transfers with checkpoints. Both transfers and scaled images publish through temporary files, so Stop removes partial work without marking it as a completed derivative. Completed outputs are retained. Close streams before deleting partial transfer files on Windows.

Native SPM/MEX calls remain cooperative units; no unsafe asynchronous thread interruption, external MATLAB worker, license dependency or change to numerical scaling is introduced. UI event testing through matlab.uitest is separate from direct callback assertions and requires MATLAB Connector/UI test services in that test process.

Reference for MATLAB queue processing: https://www.mathworks.com/help/matlab/creating_guis/interrupt-callback-execution.html . Implementation details for older UI components were also inspected in the installed R2018a sources.
