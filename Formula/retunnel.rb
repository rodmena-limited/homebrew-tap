class Retunnel < Formula
  desc "Secure tunnel service to expose local servers to the internet"
  homepage "https://docs.retunnel.com"
  url "https://files.pythonhosted.org/packages/5a/ab/61acdb5d24ee0e31026a03b0a15ba00c35544ff1000afe4f675ac6f0a706/retunnel-3.0.3.tar.gz"
  sha256 "cd34bf904db1c2bf27b65b20edbb6a7f08d610e553fde165f9c753a3dd6cd719"
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
