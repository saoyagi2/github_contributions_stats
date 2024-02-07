class GithubApi
  def get_years
    response = File.open("years.json") {|f| JSON.load(f)}
    response["data"]["user"]["contributionsCollection"]["contributionYears"]
  end

  def get_contributions(year)
    response = File.open("contributions#{year}.json") {|f| JSON.load(f)}
    response["data"]["user"]["contributionsCollection"]["contributionCalendar"]["weeks"]
      .map{|e| e["contributionDays"]}
      .flatten
      .map{|e| [DateTime.parse(e["date"]).strftime("%Y%m%d"), e["contributionCount"]]}
      .to_h
  end
end
