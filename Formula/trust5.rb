class Trust5 < Formula
  desc "AI-driven autonomous code generation with correctness guarantees"
  homepage "http://trust5.net/"
  url "https://files.pythonhosted.org/packages/22/7f/397c6f39ebc1d2c9fd4a485692cc50c09868870a7cebd16525f33e40ebec/trust5-0.7.0.tar.gz"
  sha256 "0f7c3a999a81dfa997360fb0da1bd26d1473ca3210195a3eba260b0f2dab20d6"
  license "Apache-2.0"

  depends_on "python@3.12"

  def install
    venv_dir = var/"lib/trust5/venv"

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", buildpath

    (bin/"trust5").write <<~EOS
      #!/bin/bash
      exec "#{venv_dir}/bin/trust5" "$@"
    EOS
  end

  def post_install
    venv_dir = var/"lib/trust5/venv"
    return if (venv_dir/"bin/trust5").exist?

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "trust5==#{version}"
  end

  test do
    assert_match "trust5", shell_output("#{bin}/trust5 --help")
  end
end
