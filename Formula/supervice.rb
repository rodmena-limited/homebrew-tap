class Supervice < Formula
  desc "A modern, async process supervisor for Unix-like systems. Zero dependencies."
  homepage "https://github.com/rodmena-limited/supervice"
  url "https://files.pythonhosted.org/packages/ae/f5/9a31baf17c123d3d701ab378571068aa234e594d1d5cef1691a4fe2a48a2/supervice-0.4.2.tar.gz"
  sha256 "2fe8a063f55b7721a4a3589b77e0c6f4cfd4e3444bc021663fb372f2d8da02fb"
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
