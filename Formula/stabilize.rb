class Stabilize < Formula
  desc "Stabilize Workflow Orchestration - Agentic Parallel Workflows"
  homepage "https://github.com/rodmena-limited/stabilize"
  url "https://files.pythonhosted.org/packages/35/7f/d7f59f665c64f5178cc9d5f230d1e0656b4724a5902c8089addf5fae5d13/stabilize-0.33.1.tar.gz"
  sha256 "fb1ac5419d70ef3ef6eb0fbe5ab9a2ebe43d714ab1245ec8866cc64094531dc6"
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
