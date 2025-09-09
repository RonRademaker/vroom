# Test for max_daily_travel_time Feature

This test demonstrates that the `max_daily_travel_time` feature works correctly as implemented.

## Overview

The `max_daily_travel_time` parameter enforces travel time limits per 24-hour period for vehicles. This is particularly useful for multi-day routes where drivers have daily working hour restrictions.

## Test Scenarios

### 1. Basic Functionality
- **Test 1**: Route within daily travel limit → ✅ Route completed
- **Test 2**: Route exceeding daily travel limit → ✅ Jobs unassigned

### 2. Multi-day Formula Testing  
- **Test 3**: 26-hour route with 4-hour daily limit → ✅ Route completed
- **Test 6**: Problem statement example (25-hour route, 10-hour limit) → ✅ Route completed

### 3. Constraint Interaction
- **Test 4**: Both `max_travel_time` and `max_daily_travel_time` set → ✅ More restrictive constraint applies

### 4. Edge Cases
- **Test 5**: Exactly 24-hour route duration → ✅ Handled correctly

## Formula Verification

The implementation correctly applies the formula from the problem statement:
```
effective_limit = floor(total_time/24) * max_daily_travel_time + min(max_daily_travel_time, total_time % 24)
```

For the 25-hour example with 10-hour daily limit:
- `floor(25/24) * 10 + min(10, 25%24) = 1 * 10 + min(10, 1) = 11 hours`
- Since actual travel time < 11 hours, the route is accepted ✅

## Running the Test

```bash
# Build VROOM (without routing for simplicity)
make -C src USE_ROUTING=false

# Run the comprehensive test
./comprehensive_test.sh
```

## Test Results

All test scenarios pass, demonstrating that:
- ✅ Routes within daily limits are accepted
- ✅ Routes exceeding daily limits are rejected  
- ✅ Multi-day formula calculations work correctly
- ✅ Integration with existing `max_travel_time` constraints
- ✅ Edge cases are handled properly

The feature successfully enables realistic modeling of driver regulations and multi-day logistics scenarios while maintaining full compatibility with existing VROOM functionality.