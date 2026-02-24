# Notification Patterns

## Trigger ID Pattern
- `domain-reminder-<weekday>`

## Reschedule Events
- user toggles tracked character/weapon
- user changes notification time
- user changes enabled weekdays
- app refresh after permission becomes authorized

## Test Points
- weekday mapping correctness under server timezone
- payload text accuracy (counts/day)
- no schedule for empty weekday results
