require "base64"
require "yaml"

class ConfigureGitHubRepo
  attr_reader :dry_run, :client, :repo, :overrides

  def initialize(dry_run:, client:, repo:, overrides:)
    @dry_run = dry_run
    @client = client
    @repo = repo
    @overrides = overrides || {}
  end

  def configure!
    puts "Updating #{repo[:full_name]}"

    check_attr :allow_squash_merge, repo[:allow_squash_merge]
    check_attr :allow_rebase_merge, repo[:allow_rebase_merge]
    check_attr :delete_branch_on_merge, repo[:delete_branch_on_merge]

    unless dry_run
      client.edit_repository(
        repo[:full_name],
        allow_merge_commit: opts[:allow_merge_commit],
        allow_squash_merge: opts[:allow_squash_merge],
        allow_rebase_merge: opts[:allow_rebase_merge],
        delete_branch_on_merge: opts[:delete_branch_on_merge],
      )
    end

    check_attr :master_branch_protection, branch_protection?
    if opts[:master_branch_protection]
      check_attr :required_status_checks, branch_protection.dig(:required_status_checks, :contexts)&.sort
      check_attr :enforce_admins, branch_protection.dig(:enforce_admins, :enabled)
      check_attr :up_to_date_branches, branch_protection.dig(:required_status_checks, :strict)
      check_attr :require_linear_history, branch_protection.dig(:required_linear_history, :enabled)
      check_attr :allow_force_push_to_master, branch_protection.dig(:allow_force_pushes, :enabled)
    end

    unless dry_run
      if opts[:master_branch_protection]
        client.protect_branch(
          repo[:full_name],
          repo[:default_branch],
          enforce_admins: opts[:enforce_admins],
          required_status_checks: {
            strict: opts[:up_to_date_branches],
            contexts: opts[:required_status_checks],
          },
          allow_force_pushes: opts[:allow_force_push_to_master],
          required_linear_history: opts[:require_linear_history],
          required_pull_request_reviews: nil,
          accept: Octokit::Preview::PREVIEW_TYPES[:branch_protection],
        )
      elsif branch_protection?
        client.unprotect_branch(
          repo[:full_name],
          repo[:default_branch],
        )
      end
    end
  end

private

  def opts
    pr_rules = overrides.fetch("pull_requests", {})
    branch_rules = overrides.fetch("branch_protection", {})
    {
      # repo settings
      allow_merge_commit: pr_rules.fetch("allow_merge_commit", true),
      allow_squash_merge: pr_rules.fetch("allow_squash_merge", false),
      allow_rebase_merge: pr_rules.fetch("allow_rebase_merge", false),
      delete_branch_on_merge: pr_rules.fetch("delete_branch_on_merge", true),
      # branch protection
      master_branch_protection: branch_rules.fetch("master_branch_protection", required_status_checks?),
      enforce_admins: branch_rules.fetch("enforce_admins", true),
      up_to_date_branches: branch_rules.fetch("up_to_date_branches", false),
      required_status_checks: branch_rules.fetch("required_status_checks", required_status_checks)&.sort,
      allow_force_push_to_master: branch_rules.fetch("allow_force_push_to_master", false),
      require_linear_history: branch_rules.fetch("require_linear_history", false),
    }
  end

  def check_attr(key, actual)
    expected = opts[key]
    puts "    #{key}: '#{actual}' => '#{expected}'" unless expected == actual
  end

  def required_status_checks?
    !required_status_checks.nil?
  end

  def required_status_checks
    checks = [
      github_actions&.dig("jobs", "lint") ? "lint" : nil,
      github_actions&.dig("jobs", "test") ? "test" : nil,
    ].compact

    checks.empty? ? nil : checks
  end

  def github_actions
    @github_actions ||= begin
      encoded_content = client.contents(repo[:full_name], path: ".github/workflows/ci.yaml").content
      decoded_content = Base64.decode64(encoded_content)
      YAML.safe_load(decoded_content)
    rescue Octokit::NotFound
      nil
    end
  end

  def branch_protection?
    !branch_protection.empty?
  end

  def branch_protection
    @branch_protection ||= client.branch_protection(
      repo[:full_name],
      repo[:default_branch],
      accept: Octokit::Preview::PREVIEW_TYPES[:branch_protection],
    ).to_h
  rescue Octokit::Forbidden
    {}
  end
end
