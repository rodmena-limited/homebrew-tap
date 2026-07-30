class Issuedb < Formula
  desc "Command-line issue tracking system for software development projects"
  homepage "https://pypi.org/project/issuedb/"
  url "https://files.pythonhosted.org/packages/e2/62/dd400da7b6227c4c9397ffd02f9191871ac9971625a242ea0adfdc197e98/issuedb-2.12.0.tar.gz"
  sha256 "b664fe0a9abf767fc373cda5e5361c852f784b1478af6c684bf3904cf0bfccbf"
  license "Apache-2.0"

  depends_on "python@3.12"

  def install
    venv_dir = var/"lib/issuedb/venv"

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "#{buildpath}[web]"

    (bin/"issuedb").write <<~EOS
      #!/bin/bash
      exec "#{venv_dir}/bin/issuedb-cli" "$@"
    EOS
  end

  def post_install
    venv_dir = var/"lib/issuedb/venv"
    return if (venv_dir/"bin/issuedb-cli").exist?

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "issuedb[web]==#{version}"
  end

  test do
    assert_match "issuedb", shell_output("#{bin}/issuedb --help")
  end
end
