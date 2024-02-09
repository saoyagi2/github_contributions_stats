require 'sinatra'
require 'sinatra/reloader'

require_relative 'lib/contribution_manager'
require_relative 'lib/github_api'
 
set :show_exceptions, false

get '/' do
  @username = params[:username]

  unless @username.nil? || @username.empty?
    github_api = GithubApi.new(@username)

    @years = github_api.get_years

    @all_contributions = ContributionManager.new
    @contributions_by_years = {}
    @years.each do |year|
      contributions = github_api.get_contributions(year)
      @all_contributions.append(contributions)
      contributions_by_year = ContributionManager.new
      contributions_by_year.append(contributions)
      @contributions_by_years[year] = contributions_by_year
    end
  end

  erb :index
end
