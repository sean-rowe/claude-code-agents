# Claude Pipeline Homebrew Formula
# Installation: brew install claude-pipeline
# From local file: brew install --build-from-source Formula/claude-pipeline.rb

class ClaudePipeline < Formula
  desc "AI-powered TDD workflow automation - converts requirements to production-ready code"
  homepage "https://github.com/anthropics/claude-code-agents"
  url "https://github.com/anthropics/claude-code-agents/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "" # Will be populated on actual release
  license "MIT"
  head "https://github.com/anthropics/claude-code-agents.git", branch: "main"

  depends_on "bash" => :build
  depends_on "jq"
  depends_on "coreutils"  # Provides timeout command on macOS

  # Optional dependencies (recommended but not required)
  uses_from_macos "git"
  uses_from_macos "python@3.9" => :optional
  uses_from_macos "node" => :optional
  uses_from_macos "go" => :optional

  def install
    # Install main scripts
    bin.install "bin/claude-pipeline"
    libexec.install "pipeline.sh"
    libexec.install "pipeline-state-manager.sh"

    # Install supporting files
    (libexec/"scripts").install Dir["scripts/*"] if Dir.exist?("scripts")
    (libexec/"docs").install Dir["docs/*"] if Dir.exist?("docs")
    (libexec/"tests").install Dir["tests/*"] if Dir.exist?("tests")

    # Install documentation
    doc.install "README.md"
    doc.install "INSTALL.md" if File.exist?("INSTALL.md")
    doc.install "LICENSE" if File.exist?("LICENSE")

    # Create wrapper script that sets PROJECT_ROOT
    (bin/"claude-pipeline").write <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail

      # Set project root for Homebrew installation
      export CLAUDE_PIPELINE_ROOT="#{libexec}"

      # Execute main pipeline script
      exec bash "#{libexec}/pipeline.sh" "$@"
    EOS

    # Make scripts executable
    chmod 0755, bin/"claude-pipeline"
    chmod 0755, libexec/"pipeline.sh"
    chmod 0755, libexec/"pipeline-state-manager.sh"
  end

  def caveats
    <<~EOS
      Claude Pipeline has been installed!

      Quick Start:
        claude-pipeline --help
        claude-pipeline requirements "Build authentication system"

      Optional dependencies for full functionality:
        brew install node     # For JavaScript/TypeScript projects
        brew install python@3.9  # For Python projects
        brew install go       # For Go projects

      JIRA Integration (optional):
        Download acli from: https://bobswift.atlassian.net/wiki/spaces/ACLI/overview
        Configure: echo "JIRA_URL=..." >> ~/.claude/config

      Documentation:
        #{doc}/README.md
        #{libexec}/docs/

      Uninstall:
        brew uninstall claude-pipeline
    EOS
  end

  test do
    # Test that the binary exists and is executable
    assert_predicate bin/"claude-pipeline", :exist?
    assert_predicate bin/"claude-pipeline", :executable?

    # Test basic execution
    output = shell_output("#{bin}/claude-pipeline --version 2>&1")
    assert_match(/Claude Pipeline v\d+\.\d+\.\d+/, output)

    # Test help command
    output = shell_output("#{bin}/claude-pipeline --help 2>&1")
    assert_match(/Pipeline Controller/, output)
    assert_match(/requirements/, output)
    assert_match(/gherkin/, output)
    assert_match(/work/, output)
  end
end
