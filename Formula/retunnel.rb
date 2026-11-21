class Retunnel < Formula
  desc "Secure tunnel service to expose local servers to the internet"
  homepage "https://retunnel.com"
  url "https://files.pythonhosted.org/packages/e8/ab/5e6ecea22d22eb274002e43c4c13f8093b4c7280b5d45ee020a934b2cc46/retunnel-3.3.3.tar.gz"
  sha256 "4477da7a3df6fb5f2a478e7b32c9d9dd9c73dc81bd1219f872440ad5411d52f4"
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
