use Mix.Config

config :authoritex,
  authorities: [
    Authoritex.LOC.Languages,
    Authoritex.LOC.Names,
    Authoritex.LOC.SubjectHeadings,
    Authoritex.LOC
  ]

import_config "#{Mix.env()}.exs"
