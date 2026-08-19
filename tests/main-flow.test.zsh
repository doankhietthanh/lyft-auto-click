#!/bin/zsh
set -eu

main_file="${0:A:h:h}/main.txt"
passed=0

assert_match() {
    if ! rg -q "$1" "$main_file"; then
        print -u2 "FAIL: $2"
        exit 1
    fi

    passed=$((passed + 1))
}

assert_not_match() {
    if rg -q "$1" "$main_file"; then
        print -u2 "FAIL: $2"
        exit 1
    fi

    passed=$((passed + 1))
}

assert_match 'fun clickSearchAreaAfterSwipe' 'missing per-swipe Search Area helper'
assert_match 'fun checkAvailableRideOnce' 'missing one-shot API-result probe'
assert_match 'fun revealAvailableRides' 'missing available rides fallback helper'
assert_match 'fun checkAvailableRideWithFallback' 'missing fallback ride flow'
assert_match 'fun reserveAvailableRide' 'missing complete reservation helper'
assert_not_match 'searchAreaVisible' 'persistent Search Area state must not cross swipes'
assert_match 'var swipeSettleDelay = 50' 'missing physical-device swipe settle delay'
assert_match 'var apiResultDelay = 500' 'missing bounded API-result wait'
assert_match 'var findFastParam = FParam.timeout\(200\)' 'find timeout is out of sync'
assert_match 'var reserveParam = FParam.timeout\(500\)' 'reserve timeout is out of sync'
assert_match 'var priorityRideParam = FParam.timeout\(50\)' 'missing immediate ride probe timeout'
assert_match 'var searchAreaClickParam = FParam.timeout\(200\)' 'Search Area match window is too short for a physical device'
assert_match 'var searchAreaRegion = Region.deviceReg\(\)\.middle\(\)' 'Search Area must use the middle region'
assert_match 'searchAreaRegion\.click\("search_this_area"' 'Search Area must use its dedicated region'
assert_match 'available_rides' 'missing available rides fallback template'
assert_not_match 'swipe_handle' 'fallback must not depend on swipe handle detection'
assert_match 'return checkAvailableRideWithFallback\(\)' 'API result phase must use the fallback flow'
assert_match 'SwipePoint\(Point\(500, 1600\)' 'fallback swipe must start lower on the screen'

search_call_line=$(rg -n 'clickSearchAreaAfterSwipe\(\)' "$main_file" | tail -1 | cut -d: -f1)
ride_call_line=$(rg -n 'checkAvailableRideOnce\(\)' "$main_file" | tail -1 | cut -d: -f1)
priority_line=$(rg -n 'popupRegion\.find\("new_available_rides", priorityRideParam\)' "$main_file" | tail -1 | cut -d: -f1)

if [[ -z "$priority_line" || -z "$search_call_line" || "$priority_line" -ge "$search_call_line" ]]; then
    print -u2 'FAIL: immediate ride probe must run before Search Area'
    exit 1
fi

passed=$((passed + 1))

assert_match 'if \(!popupRegion\.click\("btn_reserve_confirm", reserveParam\)\)' 'confirmation-click failure must not report success'
assert_match 'return reserveAvailableRide\(\)' 'a failed reservation must end the current swipe cycle'
assert_not_match 'if \(reserveAvailableRide\(\)\)' 'a failed reservation must not repeat stale ride detection'
assert_match 'wait\(swipeSettleDelay\)' 'Search Area must wait for the swipe animation to settle'
assert_match 'wait\(apiResultDelay\)' 'ride probing must wait for the Search Area API response'
assert_not_match 'fun waitForAvailableRide' 'API-result polling loop must not block the next swipe'

print "PASS: $passed main flow invariants"
