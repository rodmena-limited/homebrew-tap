class Retunnel < Formula
  desc "Secure tunnel service to expose local servers to the internet"
  homepage "https://docs.retunnel.com"
  url "https://files.pythonhosted.org/packages/0d/31/afe59194bee921330e6abb9c7187f81c595cbb965777edf6ca3a6579b7a7/retunnel-2.5.3.tar.gz"
  sha256 "dd4256b0dbbdceb5ad28cc509af0c81e7b4bce14704d157cd818d9b557ff3dbd"
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
