# Swipe Search Reserve Design

## Goal

After every map swipe, trigger Lyft's `search_this_area` API action as soon as
the button is visible, then reserve and confirm the first available ride.

## Flow

Each cycle owns exactly one swipe direction. It performs the following phases
in order:

1. Swipe the map.
2. Poll for `search_this_area` for a short, bounded window and click it once.
3. Poll for `new_available_rides` for the API-response window.
4. Click the ride, then wait for and click `btn_reserve`, then wait for and
   click `btn_reserve_confirm`.
5. Stop only when all three ride actions returned success. Otherwise, swipe in
   the opposite direction and retry indefinitely.

## Reliability Rules

- There is no cross-cycle `searchAreaVisible` state; every swipe gets a fresh
  opportunity to click Search This Area.
- Search Area is attempted before checking for a new ride, so it cannot be
  delayed by a ride-image lookup.
- Each phase has a separate bounded timeout. A failed click does not report a
  successful reservation.
- Template matching remains limited to the bottom screen region and retains
  the existing minimum score of 0.85.

## Validation

A portable zsh regression test will assert the static control-flow invariants
in `main.txt`: no persistent search-area flag, Search Area before ride polling,
and success only after both Reserve buttons are clicked. A real-device run is
still needed to calibrate coordinates, template crops, and actual Lyft API
latency.
