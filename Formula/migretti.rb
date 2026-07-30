class Migretti < Formula
  desc "A database migration tool for Python applications"
  homepage "https://github.com/rodmena-limited/migretti"
  url "https://files.pythonhosted.org/packages/86/03/a4319142aff568c387893c5164a3ac4915f9fb87c94c86238e2352ff491c/migretti-0.10.0.tar.gz"
  sha256 "7051b4bec5e1c74ca40ab8698b41063f0a1563db6a71ce8014fae8c3482d0374"
  license "Apache-2.0"

  depends_on "libpq"
  depends_on "python@3.12"

  def install
    venv_dir = var/"lib/migretti/venv"
    libpq = Formula["libpq"].opt_lib

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", buildpath

    (bin/"mg").write <<~EOS
      #!/bin/bash
      export DYLD_LIBRARY_PATH="#{libpq}:${DYLD_LIBRARY_PATH:+$DYLD_LIBRARY_PATH}"
      exec "#{venv_dir}/bin/mg" "$@"
    EOS
    (bin/"migretti").write <<~EOS
      #!/bin/bash
      export DYLD_LIBRARY_PATH="#{libpq}:${DYLD_LIBRARY_PATH:+$DYLD_LIBRARY_PATH}"
      exec "#{venv_dir}/bin/migretti" "$@"
    EOS
  end

  def post_install
    venv_dir = var/"lib/migretti/venv"
    return if (venv_dir/"bin/mg").exist?

    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "--clear", venv_dir
    system venv_dir/"bin/pip", "install", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "migretti==#{version}"
  end

  test do
    assert_match "migretti", shell_output("#{bin}/migretti --help")
  end
end
