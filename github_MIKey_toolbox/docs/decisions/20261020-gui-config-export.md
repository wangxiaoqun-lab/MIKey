# One active configuration for GUI-to-server execution

Keep run_mikey parameter-free apart from the selected configuration filename. No argument reads examples/mikey_config_example.m; an explicit .m path reads only that exported function. Export all settings as direct cfg assignments without depending on another configuration file or a MAT snapshot. Preserve loaded nonvisual options and reuse the shared GUI parameter map. Keep the Step 1/manual-mask boundary.

Apply only the requested layout changes: custom file labels, the shared parcellation block above Step 17, and the green bottom toolbar. Group Network has conditional Step 14 usage and is not a universal replacement for its own prior. Tests are server-only at the user request.
