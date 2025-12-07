class Retunnel < Formula
  desc "Secure tunnel service to expose local servers to the internet"
  homepage "https://docs.retunnel.com"
  url "https://files.pythonhosted.org/packages/a2/30/2152dcb99e953ca18e2596fa6bb48740060a4282dcf294100462c614f168/retunnel-2.5.2.tar.gz"
  sha256 "531a34140ec864c377fc04a9fdead62e011d8c2497cb823c99d2213be4a8304e"
  license "MIT"

  depends_on "python@3.12"

  def install
    # Create virtualenv and install retunnel with all dependencies
    venv = libexec/"venv"
    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", venv
    system venv/"bin/pip", "install", "--upgrade", "pip"
    system venv/"bin/pip", "install", buildpath

    # Create wrapper script that uses the virtualenv
    (bin/"retunnel").write <<~EOS
      #!/bin/bash
      exec "#{venv}/bin/python" -m retunnel.client.cli "$@"
    EOS
  end

  test do
    assert_match "retunnel", shell_output("#{bin}/retunnel --help")
  end
end
