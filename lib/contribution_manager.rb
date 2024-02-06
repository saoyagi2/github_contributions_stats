require 'date'

class ContributionManager
  def append(raw_contributions)
    _import(raw_contributions)
  end

  def total_contributions
    @contributions_by_day.values.sum
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

  def max_streaks_by_day
    @_max_streaks_by_day ||= @streaks_by_day.max
  end

  def max_streaks_by_week
    @_max_streaks_by_week ||= @streaks_by_week.max
  end

  def max_streaks_by_month
    @_max_streaks_by_month ||= @streaks_by_month.max
  end

  def max_streaks_by_year
    @_max_streaks_by_year ||= @streaks_by_year.max
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

  def _import(raw_contributions)
    flat_contributions = raw_contributions["data"]["user"]["contributionsCollection"]["contributionCalendar"]["weeks"]
      .map{|e| e["contributionDays"]}
      .flatten

    @contributions_by_day ||= {}
    @contributions_by_day.merge!(
      flat_contributions
        .map{|e| [DateTime.parse(e["date"]).strftime("%Y%m%d"), e["contributionCount"]]}
        .to_h
    )

    @contributions_by_week ||= {}
    @contributions_by_week.merge!(
      flat_contributions
        .group_by{|e| DateTime.parse(e["date"]).strftime("%Y%U")}
        .transform_values{|v| v.map{|e| e["contributionCount"]}.sum}
    )

    @contributions_by_month ||= {}
    @contributions_by_month.merge!(
      flat_contributions
        .group_by{|e| DateTime.parse(e["date"]).strftime("%Y%m")}
        .transform_values{|v| v.map{|e| e["contributionCount"]}.sum}
    )

    @contributions_by_year ||= {}
    @contributions_by_year.merge!(
      flat_contributions
        .group_by{|e| DateTime.parse(e["date"]).strftime("%Y")}
        .transform_values{|v| v.map{|e| e["contributionCount"]}.sum}
    )

    @streaks_by_day = _streaks(@contributions_by_day)
    @streaks_by_week = _streaks(@contributions_by_week)
    @streaks_by_month = _streaks(@contributions_by_month)
    @streaks_by_year = _streaks(@contributions_by_year)
  end

  def _distribution(counts)
    boundaries = (1..4).map {|e| [e, (counts.max.to_f / 4.0 * e).floor]}.to_h
    counts
      .select{|count| count != 0}
      .inject(Array.new(4, 0)) do |result, count|
        boundary_index = boundaries.select{|k, v| count > v}.keys.max || 0
        result[boundary_index] += 1
        result
    end
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
