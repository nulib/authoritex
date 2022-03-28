import Config

config :exvcr,
  vcr_cassette_library_dir: "test/fixtures/vcr_cassettes",
  custom_cassette_library_dir: "test/fixtures/custom_cassettes",
  filter_sensitive_data: [
    [pattern: "username=([^&#]*)", placeholder: "<<geonames_username>>"]
  ],
  global_mock: true
