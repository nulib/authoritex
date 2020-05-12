use Mix.Config

config :authoritex,
  authorities: [
    Authoritex.Getty.AAT,
    Authoritex.Getty.TGN,
    Authoritex.Getty.ULAN,
    Authoritex.Getty,
    Authoritex.LOC.Languages,
    Authoritex.LOC.Names,
    Authoritex.LOC.SubjectHeadings,
    Authoritex.LOC
  ]

import_config "#{Mix.env()}.exs"
