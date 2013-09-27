require 'formula'

# This is a pared-down formula for LLVM, based on homebrew-versions/llvm34.rb:
#   - This formula is keg-only; it does not get linked into /usr/local.
#   - Version suffixes were removed from build product names.
#   - Several related but unneeded projects were stripped (e.g., Polly).
#   - Options were removed.

class Clang < Formula
  homepage  'http://llvm.org/'
  head      'http://llvm.org/git/clang.git'
end

class CompilerRt < Formula
  homepage  'http://llvm.org/'
  head      'http://llvm.org/git/compiler-rt.git'
end

class Libcxx < Formula
  homepage  'http://llvm.org'
  head      'http://llvm.org/git/libcxx.git'
end

class Llvm < Formula
  homepage  'http://llvm.org/'
  head      'http://llvm.org/git/llvm.git'

  depends_on :python => :recommended
  
  keg_only 'Quack.'

  def install
    Clang.new('clang').brew do
      (buildpath/'tools/clang').install Dir['*']
    end

    CompilerRt.new("compiler-rt").brew do
      (buildpath/'projects/compiler-rt').install Dir['*']
    end

    Libcxx.new('libcxx').brew do
      (buildpath/'projects/libcxx').install Dir['*']
    end

    install_prefix = lib/'llvm'

    args = [
      "--prefix=#{install_prefix}",
      "--enable-optimized",
      "--enable-targets=host"
    ]
    
    system './configure', *args
    system 'make', 'VERBOSE=1'
    system 'make', 'VERBOSE=1', 'install'

    # Putting libcxx in projects only ensures that headers are installed.
    # Manually "make install" to actually install the shared libs.
    cd buildpath/'projects/libcxx' do
      libcxx_make_args = [
        # The following flags are needed so it can be installed correctly.
        "DSTROOT=#{install_prefix}",
        "SYMROOT=#{buildpath}/projects/libcxx"
      ]
      system 'make', 'install', *libcxx_make_args
    end

    # Install scan-build
    # FIXME: This does not work on Clang 3.4svn, so it is disabled for now
    if false
      (share/"clang/tools").install buildpath/'tools/clang/tools/scan-build', buildpath/'tools/clang/tools/scan-view'
    end
    
    if python
      # Install llvm python bindings
      python.site_packages.install buildpath/'bindings/python/llvm'
      
      # Install clang bindings
      python.site_packages.install buildpath/'tools/clang/bindings/python/clang'
    end

    # Link executables to bin
    mkdir_p bin
    Dir.glob(install_prefix/'bin/*') do |exec_path|
      exec_file = File.basename(exec_path)
      ln_s exec_path, bin/"#{exec_file}"
    end

    # Also link man pages
    mkdir_p man1
    Dir.glob(install_prefix/'share/man/man1/*') do |manpage|
      manpage_base = File.basename(manpage, '.1')
      ln_s manpage, man1/"#{manpage_base}.1"
    end
  end

  def test
    system "#{bin}/llvm-config", "--version"
  end

end
