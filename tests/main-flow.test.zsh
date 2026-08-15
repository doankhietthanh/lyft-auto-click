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
assert_match 'fun waitForAvailableRide' 'missing API-result polling helper'
assert_match 'fun reserveAvailableRide' 'missing complete reservation helper'
assert_not_match 'searchAreaVisible' 'persistent Search Area state must not cross swipes'

search_call_line=$(rg -n 'clickSearchAreaAfterSwipe\(\)' "$main_file" | tail -1 | cut -d: -f1)
ride_call_line=$(rg -n 'waitForAvailableRide\(\)' "$main_file" | tail -1 | cut -d: -f1)

if [[ -z "$search_call_line" || -z "$ride_call_line" || "$search_call_line" -ge "$ride_call_line" ]]; then
    print -u2 'FAIL: Search Area must run before API-result polling'
    exit 1
fi

passed=$((passed + 1))

assert_match 'if \(!popupRegion\.click\("btn_reserve_confirm", reserveParam\)\)' 'confirmation-click failure must not report success'

print "PASS: $passed main flow invariants"
