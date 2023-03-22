import Config

config :authoritex,
  authorities: [
    Authoritex.FAST.CorporateName,
    Authoritex.FAST.EventName,
    Authoritex.FAST.Form,
    Authoritex.FAST.Geographic,
    Authoritex.FAST.Personal,
    Authoritex.FAST.Topical,
    Authoritex.FAST.UniformTitle,
    Authoritex.FAST,
    Authoritex.GeoNames,
    Authoritex.Getty.AAT,
    Authoritex.Getty.TGN,
    Authoritex.Getty.ULAN,
    Authoritex.Getty,
    Authoritex.Homosaurus,
    Authoritex.LOC.GenreForms,
    Authoritex.LOC.Languages,
    Authoritex.LOC.Names,
    Authoritex.LOC.SubjectHeadings,
    Authoritex.LOC
  ]

config :httpoison_retry,
  max_attempts: 3,
  wait: 1_000,
  retry_unknown_errors: false

import_config "#{Mix.env()}.exs"
