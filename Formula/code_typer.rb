class CodeTyper < Formula
  desc "Terminal-based code showcase tool that simulates human-like typing"
  homepage "https://github.com/rodmena-limited/code-typer"
  url "https://files.pythonhosted.org/packages/fb/26/9e73aae7f601654763556c33cd9e0b1a0ecbeb7b07ada2928f673db7c01b/code_typer-0.1.1.tar.gz"
  sha256 "65c642200c0b0d4a93863c9c2bcf55a6a1cf0bf092f6955218dd54db78907ed3"
  license "Apache-2.0"

  depends_on "python@3.12"

  def install
    venv_dir = var/"lib/code-typer/venv"

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", buildpath

    (bin/"code-typer").write <<~EOS
      #!/bin/bash
      exec "#{venv_dir}/bin/code-typer" "$@"
    EOS
    (bin/"showcase").write <<~EOS
      #!/bin/bash
      exec "#{venv_dir}/bin/showcase" "$@"
    EOS
  end

  def post_install
    venv_dir = var/"lib/code-typer/venv"
    return if (venv_dir/"bin/code-typer").exist?

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "code-typer==#{version}"
  end

  test do
    assert_match "code-typer", shell_output("#{bin}/code-typer --help")
  end
end
