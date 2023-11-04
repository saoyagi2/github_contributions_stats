class Contributions
  def initialize(raw_contributions)
    @raw_contributions = raw_contributions
    @flat_contributions = @raw_contributions["data"]["user"]["contributionsCollection"]["contributionCalendar"]["weeks"].map{|e| e["contributionDays"]}.flatten
  end

  def max_contributions_par_day
    @_max_contributions_par_day ||= @flat_contributions.map{|e| e["contributionCount"]}.max
  end

  def contributions_par_day_statisticss
    return @_contributions_par_day_statisticss if instance_variable_defined? :@_contributions_par_day_statisticss
    contributions_range_boundaries = (1..4).map {|e| (max_contributions_par_day.to_f / 4.0 * e).floor}
    @_contributions_par_day_statisticss = @flat_contributions
      .select{|e| e["contributionCount"] != 0}
      .inject(Array.new(4, 0)) do |result, item|
        boundary_index = 0
        contributions_range_boundaries.each_with_index do |boundary, index|
          if item["contributionCount"].to_i > boundary
            boundary_index = index + 1
          end
        end
        result[boundary_index] += 1
        result
    end
  end

  def streaks
    return @_streaks if instance_variable_defined? :@_streaks
    @_streaks = []
    streak = 0
    @flat_contributions.each do |contribution|
      if contribution["contributionCount"] == 0
        if streak >= 2
          @_streaks << streak
          streak = 0
        end
      else
        streak += 1
      end
    end
    p @_streaks
    @_streaks
  end

  def max_streaks
    @_max_streaks ||= streaks.max
  end

  def streaks_statistics
    return @_streaks_statistics if instance_variable_defined? :@_streaks_statistics
    streaks_range_boundaries = (1..4).map {|e| (max_streaks.to_f / 4.0 * e).floor}
    @_streaks_statistics = streaks
      .inject(Array.new(4, 0)) do |result, item|
        boundary_index = 0
        streaks_range_boundaries.each_with_index do |boundary, index|
          if item > boundary
            boundary_index = index + 1
          end
        end
        result[boundary_index] += 1
        result
    end
  end
end
