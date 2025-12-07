class Scriptplan < Formula
  desc "Precise project scheduling engine with minute-level accuracy"
  homepage "https://pypi.org/project/scriptplan/"
  url "https://files.pythonhosted.org/packages/50/54/72f6d86a8167ff8d36c166f8f0686db2b3d29395990c09c3605c8e82c732/scriptplan-0.9.1.tar.gz"
  sha256 "7dd6af5113ef10a25ebf3f059b3a720cfffdbcff127942bf9087da1309425b94"
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
