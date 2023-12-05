# OFP-DM-FAD_import
Routines and function to automate the import of Satlink, Kato and Marine instruments FAD positions
Database is NOUSQL03.FAD_tracking
Each FAD provider is in a different schema
Each FAD provider schema host a separate function, used in main code:
  - ImportVessellFAD_satlink
  - ImportVessellFAD_kato
  - ImportVessellFAD_MI
