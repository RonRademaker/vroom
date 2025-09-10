#include <iostream>
#include <fstream>
#include <string>

int main() {
    // Simple debug program to check expected values
    
    // Expected values for test_comment_example.json
    int final_arrival = 90000;
    int start_arrival = 0;
    int pure_travel_time = 10800; // 3 hours
    int setup_time = 0;
    int service_time = 1800; // 0.5 hours
    
    int calculated_waiting_time = final_arrival - start_arrival - pure_travel_time - setup_time - service_time;
    
    std::cout << "Expected assertion check:" << std::endl;
    std::cout << "final_arrival = " << final_arrival << std::endl;
    std::cout << "start_arrival + duration + setup + service + waiting_time = " 
              << start_arrival << " + " << pure_travel_time << " + " << setup_time 
              << " + " << service_time << " + " << calculated_waiting_time 
              << " = " << (start_arrival + pure_travel_time + setup_time + service_time + calculated_waiting_time) << std::endl;
    std::cout << "Required waiting_time = " << calculated_waiting_time << std::endl;
    std::cout << "Waiting time in hours = " << (calculated_waiting_time / 3600.0) << std::endl;
    
    return 0;
}