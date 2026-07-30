class Bulkman < Formula
  desc "Bulkhead pattern implementation with Trio for structured concurrency and resilient circuit breaking"
  homepage "https://github.com/rodmena-limited/bulkman"
  url "https://files.pythonhosted.org/packages/31/34/899ccca1fa2f872df3c09cb194997239cf5cd0858747d6631e06649b8879/bulkman-1.2.2.tar.gz"
  sha256 "5b68a221a783ad8970e0ce1a4fb8bd534a64e9a396fee3f768da5c21dbc948e8"
  license "Apache-2.0"

  depends_on "python@3.12"

  def install
    venv_dir = libexec

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", buildpath
  end

  test do
    system libexec/"bin/python3.12", "-c", "import bulkman"
  end
end
