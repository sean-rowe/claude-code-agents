class ClaudePipeline < Formula
  desc "AI-powered TDD workflow automation - requirements to production-ready code"
  homepage "https://github.com/anthropics/claude-code-agents"
  url "https://github.com/anthropics/claude-code-agents/archive/v1.0.0.tar.gz"
  sha256 "PLACEHOLDER_SHA256"  # Will be updated on release
  license "MIT"
  version "1.0.0"

  depends_on "bash" => :build
  depends_on "jq" => :recommended
  depends_on "git" => :recommended

  def install
    # Install main scripts
    bin.install "pipeline.sh" => "claude-pipeline"
    bin.install "pipeline-state-manager.sh"

    # Install documentation
    doc.install Dir["docs/*"]
    doc.install "README.md"

    # Make scripts executable
    chmod 0755, bin/"claude-pipeline"
    chmod 0755, bin/"pipeline-state-manager.sh"
  end

  test do
    # Test that the command exists and shows help
    system "#{bin}/claude-pipeline", "--help"
  end

  def caveats
    <<~EOS
      Claude Pipeline has been installed!

      Quick start:
        claude-pipeline --help
        claude-pipeline requirements "Your project description"

      Optional dependencies for full functionality:
        brew install jq    # For state management
        brew install acli  # For JIRA integration

      Documentation:
        #{doc}/PIPELINE_QUICK_START.md
    EOS
  end
end
