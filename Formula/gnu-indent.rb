class GnuIndent < Formula
  desc "C code prettifier"
  homepage "https://www.gnu.org/software/indent/"
  url "https://ftp.gnu.org/gnu/indent/indent-2.2.12.tar.gz"
  mirror "https://ftpmirror.gnu.org/indent/indent-2.2.12.tar.gz"
  sha256 "e77d68c0211515459b8812118d606812e300097cfac0b4e9fb3472664263bb8b"

  bottle do
    rebuild 2
    sha256 "50423ce5f77533f53193feab08d5286b0aff91bcfb27ab39d21f7885c526948d" => :mojave
    sha256 "e0ceb20d551e2c5942687c7740e4b5164729462c295104e363160c640f1f23ed" => :high_sierra
    sha256 "ffd5c78abc42d3b2e565e91a60deac1cf3b6f0c47eceae11994b2d07205333a6" => :sierra
    sha256 "b6354dae416ba26946da8b5a8052a7dc350937bcb5c8503846ddd23409e03a55" => :x86_64_linux
  end

  depends_on "gettext"
  # Fix WARNING: 'makeinfo' is missing on your system.
  depends_on "texinfo" => :build unless OS.mac?

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --mandir=#{man}
    ]

    args << "--program-prefix=g" if OS.mac?
    system "./configure", *args
    system "make", "install"

    if OS.mac?
      (libexec/"gnubin").install_symlink bin/"gindent" => "indent"
      (libexec/"gnuman/man1").install_symlink man1/"gindent.1" => "indent.1"
    end
  end

  def caveats
    return unless OS.mac?
    <<~EOS
      GNU "indent" has been installed as "gindent".
      If you need to use it as "indent", you can add a "gnubin" directory
      to your PATH from your bashrc like:

          PATH="#{opt_libexec}/gnubin:$PATH"

      Additionally, you can access its man page with normal name if you add
      the "gnuman" directory to your MANPATH from your bashrc as well:

          MANPATH="#{opt_libexec}/gnuman:$MANPATH"
    EOS
  end

  test do
    (testpath/"test.c").write("int main(){ return 0; }")
    system "#{bin}/gindent", "test.c" if OS.mac?
    system "#{bin}/indent", "test.c" unless OS.mac?
    assert_equal File.read("test.c"), <<~EOS
      int
      main ()
      {
        return 0;
      }
    EOS
  end
end
