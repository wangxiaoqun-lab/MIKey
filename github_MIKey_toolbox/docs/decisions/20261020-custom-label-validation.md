# Label ID contract

Zero denotes background. Nonzero integer values are categorical IDs; missing, sparse or signed IDs are preserved. Fractional values are rejected exactly, without rounding or tolerance. A floating storage format may hold integer-valued labels and does not alone determine validity. The file must match the analysis grid. FC rows follow sorted present IDs with an explicit roi_ids mapping; row numbers must not be interpreted as original atlas IDs. No atlas source data is rewritten.
