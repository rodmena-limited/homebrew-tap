class Issuedb < Formula
  desc "Command-line issue tracking system for software development projects"
  homepage "https://pypi.org/project/issuedb/"
  url "https://files.pythonhosted.org/packages/ad/fb/dafd0e9ad727a59f474f9f2df97d1f78c921bec6c6344a2855a210e0289f/issuedb-2.38.1.tar.gz"
  sha256 "4b193c83ad2f849b6b3716195c96e03fa656b7205a71218912a7dec717cd50f2"
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
