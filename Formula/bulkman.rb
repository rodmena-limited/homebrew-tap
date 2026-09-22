class Bulkman < Formula
  desc "Bulkhead pattern implementation with Trio for structured concurrency and resilient circuit breaking"
  homepage "https://github.com/rodmena-limited/bulkman"
  url "https://files.pythonhosted.org/packages/ad/b4/3e80de8dd30db81e52e05878a0eeb4a02d47053b57b4bbd2a605872fb724/bulkman-2.0.4.tar.gz"
  sha256 "8961d3be768c355710ff92c4d67cdbb0dd577fd06a890b2ec29324cc06b9315d"
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
