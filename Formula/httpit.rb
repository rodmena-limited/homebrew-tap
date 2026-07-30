class Httpit < Formula
  desc "Ultra-fast lightweight HTTP server"
  homepage "https://github.com/rodmena-limited/fasthttp"
  url "https://files.pythonhosted.org/packages/a4/6f/313aba777a3e78e74873a7ab917c338ef7e97e0da482daf636b11a9fad94/httpit-1.21.7.tar.gz"
  sha256 "b269860e255a82be95f5ebb225f20468b0d74fd22593befd75161c79c1b47163"
  license "GPL-2.0"

  depends_on "python@3.12"

  def install
    venv_dir = var/"lib/httpit/venv"

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", buildpath

    (bin/"httpit").write <<~EOS
      #!/bin/bash
      exec "#{venv_dir}/bin/httpit" "$@"
    EOS
  end

  def post_install
    venv_dir = var/"lib/httpit/venv"
    return if (venv_dir/"bin/httpit").exist?

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "httpit==#{version}"
  end

  test do
    assert_match "httpit", shell_output("#{bin}/httpit --help")
  end
end
