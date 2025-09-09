#ifndef VEHICLE_H
#define VEHICLE_H

/*

This file is part of VROOM.

Copyright (c) 2015-2025, Julien Coupey.
All rights reserved (see LICENSE).

*/

#include <string>
#include <tuple>
#include <unordered_map>

#include "structures/typedefs.h"
#include "structures/vroom/amount.h"
#include "structures/vroom/break.h"
#include "structures/vroom/cost_wrapper.h"
#include "structures/vroom/eval.h"
#include "structures/vroom/input/vehicle_step.h"
#include "structures/vroom/location.h"
#include "structures/vroom/time_window.h"

namespace vroom {

struct VehicleCosts {
  const Cost fixed;
  const Cost per_hour;
  const Cost per_km;

  VehicleCosts(UserCost fixed = 0,
               UserCost per_hour = DEFAULT_COST_PER_HOUR,
               UserCost per_km = DEFAULT_COST_PER_KM)
    : fixed(utils::scale_from_user_cost(fixed)),
      per_hour(static_cast<Cost>(per_hour)),
      per_km(static_cast<Cost>(per_km)){};

  friend bool operator==(const VehicleCosts& lhs,
                         const VehicleCosts& rhs) = default;

  friend bool operator<(const VehicleCosts& lhs, const VehicleCosts& rhs) {
    return std::tie(lhs.fixed, lhs.per_hour, lhs.per_km) <
           std::tie(rhs.fixed, rhs.per_hour, rhs.per_km);
  }
};

struct Vehicle {
  const Id id;
  std::optional<Location> start;
  std::optional<Location> end;
  const std::string profile;
  const Amount capacity;
  const Skills skills;
  const TimeWindow tw;
  const std::vector<Break> breaks;
  const std::string description;
  const VehicleCosts costs;
  CostWrapper cost_wrapper;
  size_t max_tasks;
  const Duration max_travel_time;
  const Duration max_daily_travel_time;
  const Distance max_distance;
  const bool has_break_max_load;
  std::vector<VehicleStep> steps;
  Index type;
  const std::string type_str;
  std::unordered_map<Id, Index> break_id_to_rank;

  Vehicle(
    Id id,
    const std::optional<Location>& start,
    const std::optional<Location>& end,
    std::string profile = DEFAULT_PROFILE,
    const Amount& capacity = Amount(0),
    Skills skills = Skills(),
    const TimeWindow& tw = TimeWindow(),
    const std::vector<Break>& breaks = std::vector<Break>(),
    std::string description = "",
    const VehicleCosts& costs = VehicleCosts(),
    double speed_factor = 1.,
    const std::optional<size_t>& max_tasks = std::optional<size_t>(),
    const std::optional<UserDuration>& max_travel_time =
      std::optional<UserDuration>(),
    const std::optional<UserDuration>& max_daily_travel_time =
      std::optional<UserDuration>(),
    const std::optional<UserDistance>& max_distance =
      std::optional<UserDistance>(),
    const std::vector<VehicleStep>& input_steps = std::vector<VehicleStep>(),
    std::string type_str = NO_TYPE);

  bool has_start() const;

  bool has_end() const;

  bool has_same_locations(const Vehicle& other) const;

  bool has_same_profile(const Vehicle& other) const;

  bool cost_based_on_metrics() const;

  Duration available_duration() const;

  Cost fixed_cost() const {
    return costs.fixed;
  }

  Duration duration(Index i, Index j) const {
    return cost_wrapper.duration(i, j);
  }

  Cost cost(Index i, Index j) const {
    return cost_wrapper.cost(i, j);
  }

  Eval eval(Index i, Index j) const {
    return Eval(cost_wrapper.cost(i, j),
                cost_wrapper.duration(i, j),
                cost_wrapper.distance(i, j));
  }

  bool ok_for_travel_time(Duration d) const {
    assert(0 <= d);
    return d <= effective_max_travel_time(d);
  }

  Duration effective_max_travel_time(Duration total_travel_time) const {
    Duration daily_limit = max_travel_time; // Default to regular max_travel_time
    
    if (max_daily_travel_time != DEFAULT_MAX_TRAVEL_TIME) {
      // Apply the daily travel time formula
      // Formula from problem: max_travel_time = (floor(total_travel_time/24) * max_daily_travel_time + 
      //                                         min(max_daily_travel_time, total_travel_time % 24)) * 3600
      // But internally everything is already scaled by DURATION_FACTOR, so we don't multiply by 3600
      const Duration hours_per_day = 24 * 3600 * DURATION_FACTOR; // 24 hours in internal units
      const Duration full_days = total_travel_time / hours_per_day;
      const Duration remaining_time = total_travel_time % hours_per_day;
      
      daily_limit = full_days * max_daily_travel_time + std::min(max_daily_travel_time, remaining_time);
    }
    
    // Return the minimum of the regular max_travel_time and the daily-computed limit
    return std::min(max_travel_time, daily_limit);
  }

  bool ok_for_distance(Distance d) const {
    assert(0 <= d);
    return d <= max_distance;
  }

  bool ok_for_range_bounds(const Eval& e) const {
    assert(0 <= e.duration && 0 <= e.distance);
    return e.duration <= effective_max_travel_time(e.duration) && e.distance <= max_distance;
  }

  bool has_range_bounds() const;

  Index break_rank(Id break_id) const;

  friend bool operator<(const Vehicle& lhs, const Vehicle& rhs) {
    // Sort by:
    //   - decreasing max_tasks
    //   - decreasing capacity
    //   - decreasing TW length
    //   - decreasing range (max travel time and distance)
    return std::tie(rhs.max_tasks,
                    rhs.capacity,
                    rhs.tw.length,
                    rhs.max_travel_time,
                    rhs.max_daily_travel_time,
                    rhs.max_distance) < std::tie(lhs.max_tasks,
                                                 lhs.capacity,
                                                 lhs.tw.length,
                                                 lhs.max_travel_time,
                                                 lhs.max_daily_travel_time,
                                                 lhs.max_distance);
  }
};

} // namespace vroom

#endif
