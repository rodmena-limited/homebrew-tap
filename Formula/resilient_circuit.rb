class ResilientCircuit < Formula
  desc "A resilient circuit breaker and retry library with PostgreSQL support for distributed systems"
  homepage "https://github.com/rodmena-limited/resilient-circuit"
  url "https://files.pythonhosted.org/packages/23/96/c2f48ecdc70c170a81e0d22149c0f84f5e8d5d88106804d46d6db105e14d/resilient_circuit-0.8.3.tar.gz"
  sha256 "e958193c6d1fe71a8882768d103ec981170c3ae4b20cdf1636a3ddd0a1cc0d00"
  license "Apache-2.0"

  depends_on "python@3.12"

  def install
    venv_dir = var/"lib/resilient-circuit/venv"

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", buildpath

    (bin/"resilient-circuit").write <<~EOS
      #!/bin/bash
      exec "#{venv_dir}/bin/resilient-circuit" "$@"
    EOS
  end

  def post_install
    venv_dir = var/"lib/resilient-circuit/venv"
    return if (venv_dir/"bin/resilient-circuit").exist?

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "resilient-circuit==#{version}"
  end

  test do
    assert_match "circutbreaker", shell_output("#{bin}/resilient-circuit --help")
  end
end
