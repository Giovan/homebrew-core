class Libxml2 < Formula
  desc "GNOME XML library"
  homepage "http://xmlsoft.org/"
  url "http://xmlsoft.org/sources/libxml2-2.9.8.tar.gz"
  mirror "https://ftp.osuosl.org/pub/blfs/conglomeration/libxml2/libxml2-2.9.8.tar.gz"
  sha256 "0b74e51595654f958148759cfef0993114ddccccbb6f31aee018f3558e8e2732"
  revision 1

  bottle do
    cellar :any
    sha256 "eca15b7e4bc1f27f5519ffaa55c1af18185e466025ba494452337ce9e9c87332" => :mojave
    sha256 "4460ecfc312b9aa9ddb2c870695c0d7aa0173ef86d8155b6f6dab4949c7d785a" => :high_sierra
    sha256 "121ad4f9b13372fcf9e1e1ce0f806545266db04151fcd1cd12179365d4430dcb" => :sierra
    sha256 "1badb0ab81f61d2bcd98433b135e72984a425449e3a6ef6ff2ff188ca6c69cd0" => :x86_64_linux
  end

  head do
    url "https://gitlab.gnome.org/GNOME/libxml2.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "pkg-config" => :build
  end

  keg_only :provided_by_macos

  depends_on "python"
  depends_on "zlib" unless OS.mac?

  def install
    system "autoreconf", "-fiv" if build.head?

    # Fix build on OS X 10.5 and 10.6 with Xcode 3.2.6
    inreplace "configure", "-Wno-array-bounds", "" if ENV.compiler == :gcc_4_2

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-python",
                          "--without-lzma"
    system "make", "install"

    cd "python" do
      ENV.prepend_path "PATH", Formula["python@2"].opt_libexec/"bin" unless OS.mac?
      # We need to insert our include dir first
      inreplace "setup.py", "includes_dir = [",
        "includes_dir = ['#{include}', '#{OS.mac? ? MacOS.sdk_path/"usr" : HOMEBREW_PREFIX}/include',"
      system "python3", "setup.py", "install", "--prefix=#{prefix}"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libxml/tree.h>

      int main()
      {
        xmlDocPtr doc = xmlNewDoc(BAD_CAST "1.0");
        xmlNodePtr root_node = xmlNewNode(NULL, BAD_CAST "root");
        xmlDocSetRootElement(doc, root_node);
        xmlFreeDoc(doc);
        return 0;
      }
    EOS
    args = %w[test.c -o test]
    args += shell_output("#{bin}/xml2-config --cflags --libs").split
    system ENV.cc, *args
    system "./test"

    xy = Language::Python.major_minor_version "python3"
    ENV.prepend_path "PYTHONPATH", lib/"python#{xy}/site-packages"
    system "python3", "-c", "import libxml2"
  end
end
