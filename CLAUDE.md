# lex-decision-fatigue

**Level 3 Documentation** — Parent: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## Purpose

Decision fatigue modeling for the LegionIO cognitive architecture. Tracks willpower depletion as the agent makes decisions over a session, degrades decision quality as willpower falls, and provides recovery mechanics. Models the ego depletion phenomenon: each decision costs willpower; harder decisions cost more; quality degrades below a configurable floor.

## Gem Info

- **Gem name**: `lex-decision-fatigue`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::DecisionFatigue`
- **Location**: `extensions-agentic/lex-decision-fatigue/`

## File Structure

```
lib/legion/extensions/decision_fatigue/
  decision_fatigue.rb           # Top-level requires
  version.rb                    # VERSION = '0.1.0'
  client.rb                     # Client class with @fatigue_engine
  helpers/
    constants.rb                # DEPLETION_RATE, RECOVERY_RATE, QUALITY_LABELS, DECISION_TYPES
    decision_record.rb          # Immutable record of one decision with metadata
    fatigue_engine.rb           # Engine: make_decision, rest!, quality tracking
  runners/
    decision_fatigue.rb         # Runner module: all public methods
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `MAX_DECISIONS` | 500 | Rolling decision log cap |
| `DEFAULT_WILLPOWER` | 1.0 | Starting willpower |
| `DEPLETION_RATE` | 0.05 | Base cost per decision (multiplied by complexity) |
| `RECOVERY_RATE` | 0.08 | Default willpower recovered by `rest!` |
| `QUALITY_FLOOR` | 0.2 | Minimum quality regardless of depletion |
| `DECISION_TYPES` | `[:analytical, :evaluative, :creative, :routine, :social, :moral]` | Valid decision categories |
| `QUALITY_LABELS` | range hash | `optimal / good / adequate / compromised / depleted` |
| `COMPLEXITY_LABELS` | range hash | `trivial / simple / moderate / complex / overwhelming` |

## Runners

All methods in `Legion::Extensions::DecisionFatigue::Runners::DecisionFatigue`.

| Method | Key Args | Returns |
|---|---|---|
| `make_decision` | `label:, decision_type: :routine, complexity: 0.5` | `DecisionRecord#to_h` |
| `fatigue_status` | — | `FatigueEngine#fatigue_report` |
| `rest` | `amount: nil` | `{ recovered:, willpower:, quality:, quality_label: }` |
| `full_rest` | — | `{ recovered:, willpower: 1.0, quality: 1.0, quality_label: :optimal }` |
| `recent_decisions` | `limit: 10` | `{ decisions:, count: }` |
| `decisions_by_type` | `decision_type:` | `{ decisions:, count:, decision_type: }` |
| `quality_trend` | `window: 10` | `{ trend:, label:, window: }` |
| `should_rest` | — | `{ should_rest:, willpower: }` |

## Helpers

### `DecisionRecord`
Immutable value object. Attributes: `id`, `label`, `decision_type`, `complexity`, `quality_at_time`, `willpower_cost`, `created_at`. Methods: `complexity_label`, `quality_label`, `to_h`.

### `FatigueEngine`
Central state: `@willpower`, `@total_decisions`, `@session_start`. Key methods:
- `make_decision(label:, decision_type:, complexity:)`: deducts `complexity * DEPLETION_RATE` from willpower, floors at `QUALITY_FLOOR`, creates `DecisionRecord`
- `current_quality`: returns clamped willpower
- `rest!(amount:)`: adds to willpower, caps at 1.0
- `full_rest!`: resets willpower to `DEFAULT_WILLPOWER`
- `should_rest?`: returns true when willpower < 0.3
- `quality_trend(window:)`: rolling average quality over last N decisions
- `decision_rate`: decisions per minute since session start
- `fatigue_report`: comprehensive hash including willpower, quality_label, should_rest, quality_trend

## Integration Points

- `fatigue_status` feeds into lex-tick for load-aware scheduling
- `should_rest` can signal lex-emotion to reduce valence
- `make_decision` should be called whenever lex-tick's `action_selection` resolves to an action
- `quality_trend` can modulate lex-prediction confidence

## Development Notes

- Willpower cost = `complexity * DEPLETION_RATE` (not flat)
- Quality floor prevents total inability to decide
- `should_rest?` threshold is hard-coded at 0.3, not a constant
- `decision_rate` uses 1.0 as the minimum elapsed minutes to avoid division by zero
