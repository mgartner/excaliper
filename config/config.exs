use Mix.Config

config :dogma,
  rule_set: Dogma.RuleSet.All,
  override: %{ LineLength => [ max_length: 120 ] }
