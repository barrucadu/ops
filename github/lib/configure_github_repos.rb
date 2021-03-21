require_relative "configure_github_repo"

require "octokit"
require "yaml"

class ConfigureGitHubRepos
  attr_reader :dry_run

  def initialize(dry_run: false)
    @dry_run = dry_run
  end

  def configure!
    repos.each do |repo|
      ConfigureGitHubRepo.new(
        dry_run: dry_run,
        client: client,
        repo: repo,
        overrides: overrides[repo[:full_name]],
      ).configure!

      puts ""
    end
  end

private

  def repos
    # the client.repo(...) is needed because client.repos returns a
    # slightly different result (eg, it doesn't include the merge
    # permissions)
    @repos ||= client
      .repos({}, query: { type: "owner", sort: "asc" })
      .reject(&:archived)
      .sort_by { |repo| repo[:full_name] }
      .map { |repo| client.repo(repo[:full_name]) }
  end

  def overrides
    @overrides ||= YAML.load_file("#{__dir__}/../repo_overrides.yml")
  end

  def client
    Octokit.auto_paginate = true
    @client ||= Octokit::Client.new(access_token: ENV.fetch("GITHUB_TOKEN"))
  end
end
