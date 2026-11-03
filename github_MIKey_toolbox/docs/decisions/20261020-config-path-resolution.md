# Configuration filename resolution

Preserve normal cwd-relative precedence for existing files. Fall back to the known toolbox root and, for bare names, its examples folder. Never fall back from a missing absolute filename. Build absolute candidates explicitly using MATLAB pwd before Java canonicalization. Share this behavior between the general entry and .m configuration import; report the selected full path.
