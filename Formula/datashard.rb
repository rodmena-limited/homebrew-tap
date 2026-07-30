class Datashard < Formula
  desc "Safe concurrent data operations for ML/AI workloads, Python implementation of Apache Iceberg concepts with S3 support"
  homepage "https://github.com/rodmena-limited/datashard"
  url "https://files.pythonhosted.org/packages/c4/0b/fe49ce5f35fc79589936369560da8259ca0bd843a3fc8745fb8d67d04947/datashard-0.7.0.tar.gz"
  sha256 "b9026b9a9cf56049ffe1cc5eb4bab5ba45e5417fed74875d42d7bab5de2e132d"
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
