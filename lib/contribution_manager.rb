require 'date'

class ContributionManager
  def initialize
    @contributions_by_day = {}
    @contributions_by_week = {}
    @contributions_by_month = {}
    @contributions_by_year = {}
    @streaks_by_day = []
    @streaks_by_week = []
    @streaks_by_month = []
    @streaks_by_year = []
  end

  def append(raw_contributions)
    _import(raw_contributions)
  end

  def total_contributions
    @contributions_by_day.values.sum
  end

  def contributions_by_day
    @contributions_by_day
  end

  def max_contributions_by_day
    @contributions_by_day.values.max
  end

  def max_contributions_by_week
    @contributions_by_week.values.max
  end

  def max_contributions_by_month
    @contributions_by_month.values.max
  end

  def max_contributions_by_year
    @contributions_by_year.values.max
  end

  def contribution_by_day_distribution
    _distribution(@contributions_by_day.values)
  end

  def contribution_by_week_distribution
    _distribution(@contributions_by_week.values)
  end

  def contribution_by_month_distribution
    _distribution(@contributions_by_month.values)
  end

  def contribution_by_year_distribution
    _distribution(@contributions_by_year.values)
  end

  def contributed_days
    @contributions_by_day.select{|date, count| count != 0}.size
  end

  def contributed_weeks
    @contributions_by_week.select{|date, count| count != 0}.size
  end

  def contributed_months
    @contributions_by_month.select{|date, count| count != 0}.size
  end

  def contributed_years
    @contributions_by_year.select{|date, count| count != 0}.size
  end

  def average_contributions_per_contributed_days
    if contributed_days != 0
      (total_contributions.to_f / contributed_days.to_f).round(2)
    else
      nil
    end
  end

  def average_contributions_per_contributed_weeks
    if contributed_weeks != 0
      (total_contributions.to_f / contributed_weeks.to_f).round(2)
    else
      nil
    end
  end

  def average_contributions_per_contributed_months
    if contributed_months != 0
      (total_contributions.to_f / contributed_months.to_f).round(2)
    else
      nil
    end
  end

  def average_contributions_per_contributed_years
    if contributed_years != 0
      (total_contributions.to_f / contributed_years.to_f).round(2)
    else
      nil
    end
  end

  def max_streaks_by_day
    @streaks_by_day.max
  end

  def max_streaks_by_week
    @streaks_by_week.max
  end

  def max_streaks_by_month
    @streaks_by_month.max
  end

  def max_streaks_by_year
    @streaks_by_year.max
  end

  def streak_by_day_distribution
    _distribution(@streaks_by_day)
  end

  def streak_by_week_distribution
    _distribution(@streaks_by_week)
  end

  def streak_by_month_distribution
    _distribution(@streaks_by_month)
  end

  def streak_by_year_distribution
    _distribution(@streaks_by_year)
  end

  private

  def _import(contributions)
    @contributions_by_day.merge!(contributions)

    @contributions_by_week = @contributions_by_day
      .group_by do |date, count|
        dt = DateTime.parse(date)
        if dt.strftime("%U") != "00"
          dt.strftime("%Y%U")
        else
          DateTime.parse("#{dt.year - 1}-12-31").strftime("%Y%U")
        end
      end
      .transform_values{|v| v.map{|e| e[1]}.sum}

    @contributions_by_month = @contributions_by_day
      .group_by{|date, count| DateTime.parse(date).strftime("%Y%m")}
      .transform_values{|v| v.map{|e| e[1]}.sum}

    @contributions_by_year = @contributions_by_day
      .group_by{|date, count| DateTime.parse(date).strftime("%Y")}
      .transform_values{|v| v.map{|e| e[1]}.sum}

    @streaks_by_day = _streaks(@contributions_by_day)
    @streaks_by_week = _streaks(@contributions_by_week)
    @streaks_by_month = _streaks(@contributions_by_month)
    @streaks_by_year = _streaks(@contributions_by_year)
  end

  def _distribution(counts)
    thresholds = (1..4).map {|e| [e, (counts.max.to_f / 4.0 * e).floor]}.to_h
    distribution = counts
      .select{|count| count != 0}
      .inject(Array.new(4, 0)) do |result, count|
        threshold_index = thresholds.select{|k, v| count > v}.keys.max || 0
        result[threshold_index] += 1
        result
    end
    return distribution, thresholds
  end

  def _streaks(contributions)
    streaks = []
    streak = 0
    contributions.keys.sort.each do |date|
      if contributions[date] != 0
        streak += 1
      else
        if streak >= 2
          streaks << streak
        end
        streak = 0
      end
    end
    if streak >= 2
      streaks << streak
    end
    streaks
  end
end
