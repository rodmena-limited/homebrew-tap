class Supervice < Formula
  desc "A modern, async process supervisor for Unix-like systems. Zero dependencies."
  homepage "https://github.com/rodmena-limited/supervice"
  url "https://files.pythonhosted.org/packages/13/e6/dcc1a5480ac685ef5369fc19f0ef12b7fb56c26918a9e3ad796693346785/supervice-0.2.1.tar.gz"
  sha256 "ba9eef186691e867987c22fdd55113b6ab0396ffe5d5c1a81c6aa59c358b411a"
  license "Apache-2.0"

  depends_on "python@3.12"

  def install
    venv_dir = var/"lib/supervice/venv"

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", buildpath

    (bin/"supervice").write <<~EOS
      #!/bin/bash
      exec "#{venv_dir}/bin/supervice" "$@"
    EOS
    (bin/"supervicectl").write <<~EOS
      #!/bin/bash
      exec "#{venv_dir}/bin/supervicectl" "$@"
    EOS
  end

  def post_install
    venv_dir = var/"lib/supervice/venv"
    return if (venv_dir/"bin/supervice").exist?

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "supervice==#{version}"
  end

  test do
    assert_match "supervice", shell_output("#{bin}/supervice --help")
  end
end
