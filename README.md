# lex-decision-fatigue

Decision fatigue modeling for the LegionIO brain-modeled cognitive architecture.

## What It Does

Models the ego depletion effect: each decision the agent makes costs willpower. More complex decisions cost more. As willpower depletes, decision quality degrades — but never below a minimum floor. The agent can rest to recover.

Tracks decision history, quality trends, and recommends rest when willpower falls below threshold.

## Usage

```ruby
client = Legion::Extensions::DecisionFatigue::Client.new

# Record a decision (deducts willpower proportional to complexity)
record = client.make_decision(
  label: 'select deployment strategy',
  decision_type: :analytical,
  complexity: 0.7
)
# => { label:, decision_type: :analytical, quality_at_time: 0.96, willpower_cost: 0.035, ... }

# Check current fatigue status
client.fatigue_status
# => { willpower: 0.85, quality_label: :good, should_rest: false, decision_rate: 0.5, ... }

# Check if rest is recommended
client.should_rest
# => { should_rest: false, willpower: 0.85 }

# Take a partial rest
client.rest(amount: 0.1)
# => { recovered: 0.08, willpower: 0.93, quality: 0.93, quality_label: :optimal }

# Full reset
client.full_rest
# => { recovered: 0.07, willpower: 1.0, quality: 1.0, quality_label: :optimal }

# Review recent decisions
client.recent_decisions(limit: 5)

# Quality trend over last 10 decisions
client.quality_trend(window: 10)
# => { trend: 0.84, label: :good, window: 10 }
```

## Quality Labels

| Willpower Range | Label |
|---|---|
| 0.85 – 1.0 | `:optimal` |
| 0.65 – 0.85 | `:good` |
| 0.45 – 0.65 | `:adequate` |
| 0.25 – 0.45 | `:compromised` |
| 0.0 – 0.25 | `:depleted` |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
