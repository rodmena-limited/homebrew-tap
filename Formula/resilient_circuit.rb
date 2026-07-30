class ResilientCircuit < Formula
  desc "A resilient circuit breaker and retry library with PostgreSQL support for distributed systems"
  homepage "https://github.com/rodmena-limited/resilient-circuit"
  url "https://files.pythonhosted.org/packages/6a/23/dfb65b05bbb5b8613a8db71df638b1d5cd7a6a89032b8aa9d0831884fdfd/resilient_circuit-0.4.7.tar.gz"
  sha256 "8a47fdafdace32a3c86829c0a05acebb051dced98e62eb485a1178cddafe6c7b"
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
    assert_match "resilient-circuit", shell_output("#{bin}/resilient-circuit --help")
  end
end
