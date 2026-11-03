# Validate parameters only when consumed

Decision: use `MIKey_parameter_scope` as the shared usage map for all public configuration fields. Always validate common execution/selection fields and reject typos. For stage-specific fields, validate only the selected steps and enabled conditional branches. Preserve inactive requested values so later selections can revalidate them.

Reason: global validation and unconditional control/metadata formatting made preprocessing fail on unrelated later-stage values. Merely restricting dropdown membership left the same failure in types, ranges, numeric lists, paths and downstream helpers.

Consequences: batch controls need safe inactive placeholders while `MIKeyBatchState.Config` retains requested values. Each stage rebuilds its controls for its own scope. Preflight checks only relevant dependencies/templates. Active errors are aggregated. The GUI component/layout function is unchanged. Tests separately cover active rejection, inactive preservation and transitions between stages. Unknown fields and invalid step syntax cannot be ignored.
