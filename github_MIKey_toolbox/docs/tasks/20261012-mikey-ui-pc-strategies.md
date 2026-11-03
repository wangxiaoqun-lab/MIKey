# Requested GUI adjustments

Updated: 2026-10-12. Status: implementation complete; awaiting user visual testing.

Use the original three-column MIKey GUI. Retain its control order and styling. Add only the requested English interpolation legends, step 9/10/12 titles, default/custom PC-count controls, single numeric ROI input (default 100), and ROI explanation. Adjust the necessary spacing. The experimental scrolling layout has been removed from the executable path and preserved in the backup folder. Existing batch execution and BIDS filters remain available.

MATLAB R2018a passed GUI creation, parameter mapping, PC selection callbacks, visible-control bounds and pairwise overlap checks, and Code Analyzer parsing. See `../validation/20261012/mikey-original-ui-english.log`. The source timestamp precedes this successful validation. Earlier synthetic step 10/11/12 PC-strategy tests passed; this revision changes GUI controls and the empty ROI fallback. No native screenshot was captured. User visual testing is the next step; make no further cosmetic changes until feedback.
