class Stabilize < Formula
  desc "Stabilize Workflow Orchestration - Agentic Parallel Workflows"
  homepage "https://github.com/rodmena-limited/stabilize"
  url "https://files.pythonhosted.org/packages/27/ad/1293a5245842a5c3f1f96e958bbb2ed291480abaf452dd7aa74cec9da834/stabilize-0.32.1.tar.gz"
  sha256 "bc27125b70669843ee01711d6ddbabad5dbeb5926c65b188c9c1c06825345261"
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
