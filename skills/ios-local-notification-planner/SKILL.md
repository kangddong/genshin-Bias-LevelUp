---
name: ios-local-notification-planner
description: Standardize iOS local notification architecture for weekday/time-based reminders using UNUserNotificationCenter, async/await, and reschedule-on-change behavior.
---

# iOS Local Notification Planner

Use this skill when implementing or refactoring reminder flows.

## Required Pattern
- Ask permission via `requestAuthorization`.
- Map system permission to app-level status enum.
- Keep scheduling logic in an `actor`.
- Rebuild all requests when selection or settings change.

## Schedule Contract
- Input: selected entities + weekday set + time(HH:mm) + server timezone.
- Output: repeating `UNCalendarNotificationTrigger` requests with stable identifiers.
- Skip schedule creation for weekdays with zero eligible items.

## Safety Checklist
- Remove stale requests before re-registering.
- Keep notification copy concise and count-based.
- Avoid APNs dependencies in MVP.
