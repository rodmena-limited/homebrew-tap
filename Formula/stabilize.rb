class Stabilize < Formula
  desc "Stabilize Workflow Orchestration - Agentic Parallel Workflows"
  homepage "https://github.com/rodmena-limited/stabilize"
  url "https://files.pythonhosted.org/packages/26/b4/b72f869b7864103cb2b8a1f19a7233dfd07e36c5ae8fe2e0b0c9ab98f8de/stabilize-0.19.1.tar.gz"
  sha256 "969327a976799ae815499f5b554327523adf33129e417b9611dc4b1d4083f668"
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
