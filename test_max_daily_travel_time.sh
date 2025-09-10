#!/bin/bash

echo "Testing max_daily_travel_time functionality"
echo "==========================================="
echo

# Test 1: Simple valid scenario
echo "Test 1: Valid scenario - 8 hours travel time with 10-hour daily limit"
echo "Expected: Jobs should be completed successfully"
cat > test1.json << 'EOF'
{
  "vehicles": [
    {
      "id": 1,
      "start_index": 0,
      "end_index": 0,
      "max_daily_travel_time": 36000,
      "description": "Vehicle with 10-hour daily travel limit"
    }
  ],
  "jobs": [
    {
      "id": 1,
      "location_index": 1,
      "service": 1800,
      "description": "Job taking 30 minutes service time"
    }
  ],
  "matrices": {
    "car": {
      "durations": [
        [0, 14400],
        [14400, 0]
      ]
    }
  }
}
EOF

result1=$(./bin/vroom -i test1.json | jq -r '.summary.routes')
echo "Result: $result1 routes completed (expected: 1)"
echo

# Test 2: Simple invalid scenario
echo "Test 2: Invalid scenario - 12 hours travel time with 10-hour daily limit"
echo "Expected: Jobs should be unassigned due to travel time constraint"
cat > test2.json << 'EOF'
{
  "vehicles": [
    {
      "id": 1,
      "start_index": 0,
      "end_index": 0,
      "max_daily_travel_time": 36000,
      "description": "Vehicle with 10-hour daily travel limit"
    }
  ],
  "jobs": [
    {
      "id": 1,
      "location_index": 1,
      "service": 1800,
      "description": "Job taking 30 minutes service time"
    }
  ],
  "matrices": {
    "car": {
      "durations": [
        [0, 21600],
        [21600, 0]
      ]
    }
  }
}
EOF

result2=$(./bin/vroom -i test2.json | jq -r '.summary.routes')
unassigned2=$(./bin/vroom -i test2.json | jq -r '.summary.unassigned')
echo "Result: $result2 routes completed, $unassigned2 unassigned (expected: 0 routes, 1 unassigned)"
echo

# Test 3: Multi-day formula test - simulating the 25-hour example
echo "Test 3: Multi-day formula test"
echo "Scenario: Route with total duration >24 hours to test daily limit formula"
echo "Formula: effective_limit = floor(total_time/24) * max_daily + min(max_daily, total_time % 24)"

cat > test3.json << 'EOF'
{
  "vehicles": [
    {
      "id": 1,
      "start_index": 0,
      "end_index": 0,
      "max_daily_travel_time": 36000,
      "description": "Vehicle testing multi-day formula"
    }
  ],
  "jobs": [
    {
      "id": 1,
      "location_index": 1,
      "service": 82800,
      "description": "Job with 23-hour service time to extend route duration"
    }
  ],
  "matrices": {
    "car": {
      "durations": [
        [0, 19800],
        [19800, 0]
      ]
    }
  }
}
EOF

echo "Details:"
echo "- Service time: 23 hours (82,800 seconds)"
echo "- Travel time: 11 hours total (5.5 hours each way)"
echo "- Total route duration: ~34 hours"
echo "- Max daily travel time: 10 hours (36,000 seconds)"
echo "- Expected effective limit calculation:"
echo "  floor(34/24) * 10 + min(10, 34%24) = 1 * 10 + min(10, 10) = 20 hours"
echo "- Since travel time (11 hours) < effective limit (20 hours), this should work"

result3=$(./bin/vroom -i test3.json | jq -r '.summary.routes')
unassigned3=$(./bin/vroom -i test3.json | jq -r '.summary.unassigned')
echo "Result: $result3 routes completed, $unassigned3 unassigned (expected: 1 route, 0 unassigned)"
echo

# Test 4: Comparison with regular max_travel_time
echo "Test 4: Interaction with regular max_travel_time constraint"
echo "Testing that the more restrictive constraint applies"

cat > test4.json << 'EOF'
{
  "vehicles": [
    {
      "id": 1,
      "start_index": 0,
      "end_index": 0,
      "max_travel_time": 28800,
      "max_daily_travel_time": 36000,
      "description": "Vehicle with both constraints (8h regular, 10h daily)"
    }
  ],
  "jobs": [
    {
      "id": 1,
      "location_index": 1,
      "service": 1800,
      "description": "Job taking 30 minutes service time"
    }
  ],
  "matrices": {
    "car": {
      "durations": [
        [0, 16200],
        [16200, 0]
      ]
    }
  }
}
EOF

echo "Details:"
echo "- Travel time: 9 hours total"
echo "- max_travel_time: 8 hours"
echo "- max_daily_travel_time: 10 hours"
echo "- Expected: Should be rejected due to regular max_travel_time (more restrictive)"

result4=$(./bin/vroom -i test4.json | jq -r '.summary.routes')
unassigned4=$(./bin/vroom -i test4.json | jq -r '.summary.unassigned')
echo "Result: $result4 routes completed, $unassigned4 unassigned (expected: 0 routes, 1 unassigned)"
echo

# Cleanup
rm -f test1.json test2.json test3.json test4.json

echo "==========================================="
echo "max_daily_travel_time functionality test completed"