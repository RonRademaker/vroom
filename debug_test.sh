#!/bin/bash

# Debug test to understand what's happening with daily travel time logic

cd /home/runner/work/vroom/vroom

echo "Testing simple case with debug output..."

# Create a simple test that should trigger the waiting time logic
cat > debug_test.json << EOF
{
  "vehicles": [
    {
      "id": 1,
      "start_index": 0,
      "end_index": 0,
      "max_daily_travel_time": 7200,
      "description": "Vehicle with 2-hour daily limit"
    }
  ],
  "jobs": [
    {
      "id": 1,
      "location_index": 1,
      "service": 1800
    }
  ],
  "matrices": {
    "car": {
      "durations": [
        [0, 5400],
        [5400, 0]
      ]
    }
  }
}
EOF

echo "Running test..."
./bin/vroom -i debug_test.json | jq '.'

echo ""
echo "Expected behavior:"
echo "1. Start at time 0"  
echo "2. Travel 1.5h (5400s) to job → arrival at 5400"
echo "3. Service 0.5h (1800s) → finish at 7200"
echo "4. Try to travel 1.5h back, but daily limit (2h) would be exceeded"
echo "5. Wait until next day → wait ~21.5h until 86400"
echo "6. Travel 1.5h on new day → arrival at 90000"
echo ""
echo "Actual end arrival: should be ~90000, not 12600"