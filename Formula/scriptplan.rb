class Scriptplan < Formula
  desc "Precise project scheduling engine with minute-level accuracy"
  homepage "https://pypi.org/project/scriptplan/"
  url "https://files.pythonhosted.org/packages/3a/be/bc8a6b00a8bf3b78d565ff9c07b3b662115ad35463c77bd82334adc0b5a8/scriptplan-0.10.2.tar.gz"
  sha256 "aeb73459e69f46ea770b3866db9f269cfc92cb0a27c0f153609452603ef73b5c"
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
