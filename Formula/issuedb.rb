class Issuedb < Formula
  desc "Command-line issue tracking system for software development projects"
  homepage "https://pypi.org/project/issuedb/"
  url "https://files.pythonhosted.org/packages/d1/76/4327cc520f3f29784231078258a693c84b24717bf5811b28212efc2a5f71/issuedb-2.6.1.tar.gz"
  sha256 "61c61d3ed5e4f7adfd9cdbaa1e8c8384d6f1cb57c96def7ebcdab89bf86f7d3b"
  license "Apache-2.0"

  depends_on "python@3.12"

  def install
    venv_dir = var/"lib/issuedb/venv"

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", buildpath

    (bin/"issuedb").write <<~EOS
      #!/bin/bash
      exec "#{venv_dir}/bin/issuedb" "$@"
    EOS
  end

  def post_install
    venv_dir = var/"lib/issuedb/venv"
    return if (venv_dir/"bin/issuedb").exist?

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "issuedb==#{version}"
  end

  test do
    assert_match "issuedb", shell_output("#{bin}/issuedb --help")
  end
end
