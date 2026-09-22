class Retunnel < Formula
  desc "Secure tunnel service to expose local servers to the internet"
  homepage "https://docs.retunnel.com"
  url "https://files.pythonhosted.org/packages/16/55/b62f4f41459901552256b1b94ddfec4c59aebeb2ed74798bd9a9ac56ea75/retunnel-3.2.1.tar.gz"
  sha256 "1b75c255d95b9133df7b344e6d7aa8614036b7d02f75e9513191a79e7df853e5"
  license "MIT"

  depends_on "python@3.12"

  def install
    # Install to a separate directory that won't be relocated
    venv_dir = var/"lib/retunnel/venv"

    # Create virtualenv during install
    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", buildpath

    # Create wrapper script
    (bin/"retunnel").write <<~EOS
      #!/bin/bash
      exec "#{venv_dir}/bin/retunnel" "$@"
    EOS
  end

  def post_install
    # Ensure venv exists after installation
    venv_dir = var/"lib/retunnel/venv"
    return if (venv_dir/"bin/retunnel").exist?

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "retunnel==#{version}"
  end

  test do
    assert_match "retunnel", shell_output("#{bin}/retunnel --help")
  end
end
