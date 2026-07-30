class Stabilize < Formula
  desc "Stabilize Workflow Orchestration - Agentic Parallel Workflows"
  homepage "https://github.com/rodmena-limited/stabilize"
  url "https://files.pythonhosted.org/packages/fc/ec/345c086d9bb88e9d4a21d21d72b3ab728fb5a5cd37196f901e0f9682bacf/stabilize-0.20.0.tar.gz"
  sha256 "617fa87e85ecf908d025b438a38726e84de7a150473fe3fe73eafc9ed215089f"
  license "Apache-2.0"

  depends_on "python@3.12"

  def install
    venv_dir = var/"lib/stabilize/venv"

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", buildpath

    (bin/"stabilize").write <<~EOS
      #!/bin/bash
      exec "#{venv_dir}/bin/stabilize" "$@"
    EOS
  end

  def post_install
    venv_dir = var/"lib/stabilize/venv"
    return if (venv_dir/"bin/stabilize").exist?

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "stabilize==#{version}"
  end

  test do
    assert_match "stabilize", shell_output("#{bin}/stabilize --help")
  end
end
