# Public source distribution and accidental-edit protection

Date: 2026-10-20

The user chose editable configuration .m functions with public core .m source, read-only accidental-edit protection and integrity checking. P-code and centrally owned server-only deployment were discussed but not chosen. Read-only attributes are not a complete lock on a user-controlled computer; a manifest that can also be replaced is not publisher authentication.

Core hashes are scoped to implementation, runners, tests and maintenance tools. Config templates/functions and data are excluded, and absolute external config paths remain supported. Windows attributes may not survive transfer to Linux, so a shell helper reapplies source permissions. Unlock is available to maintainers; approved source changes require refreshed published hashes.

Dependency cleanup uses a conservative transitive closure, preserves public MIKey APIs and all referenced helper names, and does not assert support for external projects using legacy standalone utilities. At the user's explicit request, no backups of the 142 removed functions are retained. The deletion manifest records names/original hashes only.
