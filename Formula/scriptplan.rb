class Scriptplan < Formula
  desc "Precise project scheduling engine with minute-level accuracy"
  homepage "https://pypi.org/project/scriptplan/"
  url "https://files.pythonhosted.org/packages/4c/a9/39e3cb442a48c77804f1a2d3a51b5582831ef79e77cf5e6598404c95f3a8/scriptplan-0.11.0.tar.gz"
  sha256 "e7d24b8c0f11df42bbb95d7dac0dd1524fa3afc3542c218c5186ac7cf4c20c0d"
  license "Apache-2.0"

  depends_on "python@3.12"

  def install
    venv_dir = var/"lib/scriptplan/venv"

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", buildpath

    (bin/"scriptplan").write <<~EOS
      #!/bin/bash
      exec "#{venv_dir}/bin/scriptplan" "$@"
    EOS
  end

  def post_install
    venv_dir = var/"lib/scriptplan/venv"
    return if (venv_dir/"bin/scriptplan").exist?

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "scriptplan==#{version}"
  end

  test do
    assert_match "scriptplan", shell_output("#{bin}/scriptplan --help")
  end
end
