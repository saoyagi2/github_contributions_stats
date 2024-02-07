class GithubApi
  def get_years
    File.open("years.json") {|f| JSON.load(f)}
  end

  def get_contributions(year)
    File.open("contributions#{year}.json") {|f| JSON.load(f)}
  end
end
