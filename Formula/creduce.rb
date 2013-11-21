require 'formula'

class Creduce < Formula
  homepage 'http://embed.cs.utah.edu/creduce/'
  head 'https://github.com/rgov/creduce.git',
    :branch => 'llvm-svn-compatible'
  
  # Additional requirements flex and indent should already be available on OS X
  
  depends_on 'astyle'
  depends_on 'rgov/etc/delta'
  depends_on 'rgov/etc/llvm'
  
  depends_on 'Benchmark::Timer' => :perl
  depends_on 'Exporter::Lite' => :perl
  depends_on 'File::Which' => :perl
  depends_on 'Getopt::Tabular' => :perl
  depends_on 'Regexp::Common' => :perl
  depends_on 'Sys::CPU' => :perl
  
  def llvm_prefix
    @llvm_prefix ||= Formula.factory('rgov/etc/llvm').prefix
  end
  
  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking",
      "--with-llvm=#{llvm_prefix}"
    system "make install"
  end
end
