class ResilientCircuit < Formula
  desc "A resilient circuit breaker and retry library with PostgreSQL support for distributed systems"
  homepage "https://github.com/rodmena-limited/resilient-circuit"
  url "https://files.pythonhosted.org/packages/92/d1/c370a7a13ad8e9f461206d26a63973880350084ea5622410edeee4751778/resilient_circuit-0.8.6.tar.gz"
  sha256 "f19d72b0086947a6df706702fb816892902657d897fd8c71282ebf16be2762c8"
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
