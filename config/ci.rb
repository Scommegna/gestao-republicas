# Run using bin/ci

if Dir.home && !File.writable?(Dir.home)
  require "fileutils"

  ci_home = File.expand_path("../tmp/ci-home", __dir__)
  FileUtils.mkdir_p(ci_home)

  ENV["HOME"] = ci_home
  ENV["XDG_CACHE_HOME"] ||= File.join(ci_home, ".cache")
  ENV["XDG_CONFIG_HOME"] ||= File.join(ci_home, ".config")
  ENV["XDG_DATA_HOME"] ||= File.join(ci_home, ".local", "share")
  ENV["GEM_SPEC_CACHE"] ||= File.join(ci_home, ".cache", "gem", "specs")
  ENV["BUNDLE_USER_HOME"] ||= File.join(ci_home, ".bundle")
  ENV["BUNDLE_USER_CACHE"] ||= File.join(ci_home, ".bundle", "cache")
  ENV["BUNDLE_USER_CONFIG"] ||= File.join(ci_home, ".bundle", "config")
  ENV["YARN_CACHE_FOLDER"] ||= File.join(ci_home, ".cache", "yarn")
end

CI.run do
  step "Setup", "bin/setup --skip-server"

  step "Style: Ruby", "bin/rubocop"

  step "Security: Gem audit", "bin/bundler-audit"
  step "Security: Importmap vulnerability audit", "bin/importmap audit"
  step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"
  step "Tests: RSpec + SimpleCov", "env COVERAGE=true CI=true bundle exec rspec"
  step "Tests: Seeds", "env RAILS_ENV=test bin/rails db:seed:replant"

  # Optional: Run system tests
  # step "Tests: System", "bin/rails test:system"

  # Optional: set a green GitHub commit status to unblock PR merge.
  # Requires the `gh` CLI and `gh extension install basecamp/gh-signoff`.
  # if success?
  #   step "Signoff: All systems go. Ready for merge and deploy.", "gh signoff"
  # else
  #   failure "Signoff: CI failed. Do not merge or deploy.", "Fix the issues and try again."
  # end
end
