class Scriptplan < Formula
  desc "Precise project scheduling engine with minute-level accuracy"
  homepage "https://pypi.org/project/scriptplan/"
  url "https://files.pythonhosted.org/packages/bd/b1/933df8580eebf3025ac084b7d670961d49873d38195f7785669e9c55bab0/scriptplan-0.9.2.tar.gz"
  sha256 "9dda2583131a050c266d5fe23d6c41f9faf60f62cc174c4e64175c217bff610a"
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
