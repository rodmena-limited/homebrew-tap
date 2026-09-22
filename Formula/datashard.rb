class Datashard < Formula
  desc "Safe concurrent data operations for ML/AI workloads, Python implementation of Apache Iceberg concepts with S3 support"
  homepage "https://github.com/rodmena-limited/datashard"
  url "https://files.pythonhosted.org/packages/1f/39/54cf3ce93001b1c0d06bab6f1c2358813b293da42881a13e06c61abce6d5/datashard-0.11.2.tar.gz"
  sha256 "fba3a8d9e9c2fb258041bd35845922991d222103b49784f636e0c8b96866e36e"
  license "Apache-2.0"

  depends_on "python@3.12"

  def install
    venv_dir = var/"lib/datashard/venv"

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", buildpath

    (bin/"datashard").write <<~EOS
      #!/bin/bash
      exec "#{venv_dir}/bin/datashard" "$@"
    EOS
  end

  def post_install
    venv_dir = var/"lib/datashard/venv"
    return if (venv_dir/"bin/datashard").exist?

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "datashard==#{version}"
  end

  test do
    assert_match "datashard", shell_output("#{bin}/datashard --help")
  end
end
