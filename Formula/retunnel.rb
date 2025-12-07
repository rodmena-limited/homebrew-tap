class Retunnel < Formula
  include Language::Python::Virtualenv

  desc "Secure tunnel service to expose local servers to the internet"
  homepage "https://docs.retunnel.com"
  url "https://files.pythonhosted.org/packages/a2/30/2152dcb99e953ca18e2596fa6bb48740060a4282dcf294100462c614f168/retunnel-2.5.2.tar.gz"
  sha256 "531a34140ec864c377fc04a9fdead62e011d8c2497cb823c99d2213be4a8304e"
  license "MIT"

  depends_on "python@3.12"

  def install
    virtualenv_create(libexec, "python3.12")
    system libexec/"bin/pip", "install", buildpath
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/retunnel --version")
  end
end
