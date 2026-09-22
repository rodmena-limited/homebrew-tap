class Scriptplan < Formula
  desc "Precise project scheduling engine with minute-level accuracy"
  homepage "https://pypi.org/project/scriptplan/"
  url "https://files.pythonhosted.org/packages/94/51/29f13fbf320761d6d55260ee73a469b5b27d257903946cc29084f1d3e1eb/scriptplan-0.10.0.tar.gz"
  sha256 "d819d6146c9b4becb3bafbc3db12243f70cd180512fe441560c2f9cb0a4a1234"
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
