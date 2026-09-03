#!/bin/zsh
set -eu

main_file="${0:A:h:h}/main.txt"
passed=0

search_match() {
    if command -v rg >/dev/null 2>&1; then
        rg -q "$1" "$main_file"
    else
        grep -E -q "$1" "$main_file"
    fi
}

search_line() {
    if command -v rg >/dev/null 2>&1; then
        rg -n "$1" "$main_file" | tail -1 | cut -d: -f1
    else
        grep -E -n "$1" "$main_file" | tail -1 | cut -d: -f1
    fi
}

assert_match() {
    if ! search_match "$1"; then
        print -u2 "FAIL: $2"
        exit 1
    fi

    passed=$((passed + 1))
}

assert_not_match() {
    if search_match "$1"; then
        print -u2 "FAIL: $2"
        exit 1
    fi

    passed=$((passed + 1))
}

assert_match 'fun clickSearchAreaAfterSwipe' 'missing per-swipe Search Area helper'
assert_match 'fun completeReservation' 'missing complete reservation helper'
assert_not_match 'searchAreaVisible' 'persistent Search Area state must not cross swipes'
assert_match 'var swipeSettleDelay = 200' 'missing physical-device swipe settle delay'
assert_match 'var priorityRideParam = FParam.timeout\(50\)' 'missing immediate ride probe timeout'
assert_match 'var postSearchRideParam = FParam.timeout\(700\)' 'missing combined API wait & scan timeout'
assert_match 'var btnReserveParam = FParam.timeout\(500\)' 'reserve timeout is out of sync'
assert_match 'var btnConfirmParam = FParam.timeout\(500\)' 'confirm timeout is out of sync'
assert_match 'var searchAreaClickParam = FParam.timeout\(1200\)' 'Search Area match window is out of sync'
assert_match 'var searchAreaRegion = Region.deviceReg\(\)\.middle\(\)' 'Search Area must use the middle region'
assert_match 'searchAreaRegion\.click\("search_this_area"' 'Search Area must use its dedicated region'
assert_not_match 'popupRegion\.find\(' 'redundant find() calls must be eliminated in favor of direct click()'
assert_not_match 'wait\(apiResultDelay\)' 'blind API wait delay must be eliminated in favor of combined timeout'

search_call_line=$(search_line 'clickSearchAreaAfterSwipe\(\)')
priority_line=$(search_line 'popupRegion\.click\("new_available_rides", priorityRideParam\)')

if [[ -z "$priority_line" || -z "$search_call_line" || "$priority_line" -ge "$search_call_line" ]]; then
    print -u2 'FAIL: immediate ride probe must run before Search Area'
    exit 1
fi

passed=$((passed + 1))

assert_match 'if \(!popupRegion\.click\("btn_reserve_confirm", btnConfirmParam\)\)' 'confirmation-click failure must not report success'
assert_match 'return completeReservation\(\)' 'a triggered reservation must conclude without falling through to search area'
assert_not_match 'if \(completeReservation\(\)\)' 'a failed reservation must not repeat stale ride detection'
assert_match 'wait\(swipeSettleDelay\)' 'Search Area must wait for the swipe animation to settle'
assert_not_match 'fun waitForAvailableRide' 'API-result polling loop must not block the next swipe'

print "PASS: $passed main flow invariants"

