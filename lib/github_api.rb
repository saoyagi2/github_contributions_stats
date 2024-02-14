require "net/http"
require "json"
require "date"

class GithubApi
  def initialize(config, username)
    @config = config
    @username = username
  end

  def get_years
    query = "query($userName:String!) { user(login: $userName) { contributionsCollection { contributionYears } } }"
    variables = {"userName": @username}
    params = {"query": query, variables: variables}
    response = _call_api(params)
    if response.code == "200"
      JSON.parse(response.body)["data"]["user"]["contributionsCollection"]["contributionYears"]
    else
      nil
    end
  end

  def get_contributions(year)
    query = "query ($userName: String!, $from: DateTime!, $to: DateTime) { user(login: $userName) { contributionsCollection(from: $from, to: $to) { contributionCalendar { weeks { contributionDays { date contributionCount } } } } } }"
    variables = {"userName": @username, "from": "#{year}-01-01T00:00:00", "to": "#{year}-12-31T23:59:59"}
    params = {"query": query, "variables": variables}
    response = _call_api(params)
    if response.code == "200"
      JSON.parse(response.body)["data"]["user"]["contributionsCollection"]["contributionCalendar"]["weeks"]
        .map{|e| e["contributionDays"]}
        .flatten
        .map{|e| [DateTime.parse(e["date"]).strftime("%Y-%m-%d"), e["contributionCount"]]}
        .to_h
    else
      nil
    end
  end

  private

  def _call_api(params)
    uri = URI.parse("https://api.github.com/graphql")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"
    headers = {
      "Authorization" => "bearer #{@config["api_token"]}",
      "Content-Type" => "application/json"
    }
    3.times do |count|
      response = http.post(uri.path, params.to_json, headers)
      if response.code == "200"
        return response
      end
      sleep 0.1
    end
    nil
  end
end
