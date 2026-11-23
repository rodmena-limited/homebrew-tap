class Stabilize < Formula
  desc "Stabilize Workflow Orchestration - Agentic Parallel Workflows"
  homepage "https://github.com/rodmena-limited/stabilize"
  url "https://files.pythonhosted.org/packages/82/26/e6479206c5add956dd93b115999a8f5f40994d326754324f16f320e65dc0/stabilize-0.34.5.tar.gz"
  sha256 "4588adaf2e83e21382a8658ffe9258275e250ed021ca82051e58c2f2597d104c"
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
