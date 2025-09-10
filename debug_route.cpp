#include <iostream>

int main() {
    std::cout << "Debug: Simple route with waiting time\n";
    std::cout << "=====================================\n";
    
    // Expected values based on test_comment_example.json
    // 2-hour daily limit, 3-hour total travel 
    // Should result in 25-hour total time (90000s arrival)
    
    int start_arrival = 0;
    int job_arrival = 5400;      // 1.5 hours
    int end_arrival = 90000;     // 25 hours (with 21.5h waiting)
    
    int service_time = 1800;     // 30 minutes at job
    int setup_time = 0;          // No setup
    int waiting_time = 77400;    // 21.5 hours waiting (total route waiting)
    
    // Route duration calculation (should this include waiting?)
    int duration_with_waiting = end_arrival - start_arrival; // 90000
    int duration_without_waiting = 10800; // Pure travel time (3 hours)
    
    std::cout << "Route level assertion check:\n";
    std::cout << "end_arrival == start_arrival + duration + setup + service + waiting_time\n";
    
    std::cout << "With waiting in duration: " << end_arrival << " == " << start_arrival 
              << " + " << duration_without_waiting << " + " << setup_time << " + " << service_time 
              << " + " << waiting_time << " = " << (start_arrival + duration_without_waiting + setup_time + service_time + waiting_time) << "\n";
    
    std::cout << "Result: " << (end_arrival == start_arrival + duration_without_waiting + setup_time + service_time + waiting_time ? "PASS" : "FAIL") << "\n\n";
    
    std::cout << "Without waiting in duration: " << end_arrival << " == " << start_arrival 
              << " + " << duration_with_waiting << " + " << setup_time << " + " << service_time 
              << " + 0 = " << (start_arrival + duration_with_waiting + setup_time + service_time) << "\n";
    
    std::cout << "Result: " << (end_arrival == start_arrival + duration_with_waiting + setup_time + service_time ? "PASS" : "FAIL") << "\n";
    
    return 0;
}