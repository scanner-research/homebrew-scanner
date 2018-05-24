class Hwang < Formula
  include Language::Python::Virtualenv

  desc "Fast sparse video decode"
  homepage "https://github.com/scanner-research/hwang"
  url "https://github.com/scanner-research/hwang/archive/v0.0.1.tar.gz"
  sha256 "944bff0726ecf65881e17ad6df465d105fb35c40c6ab748dff5407361d23ee12"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "python"

  depends_on "glog"
  depends_on "gflags"
  depends_on "ffmpeg"
  depends_on "pybind11"
  depends_on "protobuf"

  resource "numpy" do
    url "https://files.pythonhosted.org/packages/b0/2b/497c2bb7c660b2606d4a96e2035e92554429e139c6c71cdff67af66b58d2/numpy-1.14.3.zip"
    sha256 "9016692c7d390f9d378fc88b7a799dc9caa7eb938163dda5276d3f3d6f75debf"
  end
  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/64/88/d434873ba1ce02c0ed669f574afeabaeaaeec207929a41b5c1ed947270fc/setuptools-34.1.0.zip"
    sha256 "c0cc0c7d7f86e03b63fd093032890569a944f210358fbfea339252ba33fb1097"
  end

  def install
    python_version = Language::Python.major_minor_version("python3")

    system "bash", "deps.sh",
           "-a",
           "--with-pybind", "/usr/local",
           "--with-protobuf", "/usr/local/",
           "--with-ffmpeg", "/usr/local"
    FileUtils.mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end

    # resource("six").stage do
    #   system "python3", *Language::Python.setup_install_args(libexec)
    # end
    chdir "python" do
      system "python3", "setup.py", "bdist_wheel"
      system "pip3", "install", "--prefix=" + libexec,
             "dist/hwang-" + version.to_s + "-py3-none-any.whl"
    end

    site_packages = "lib/python#{python_version}/site-packages"
    pth_contents = "import site; site.addsitedir('#{libexec/site_packages}')\n"
    (prefix/site_packages/"homebrew-hwang.pth").write pth_contents
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <hwang/mp4_index_creator.h>
      #include <iostream>
      int main() {
        hwang::MP4IndexCreator c(1);
        std::cout << c.is_error() << std::endl;
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++11", "-I#{include}", "-L#{lib}", "-lhwang", "-o", "test"
    assert_equal `./test`.strip, "0"

    output = shell_output("python3 -c 'import hwang; print(\"ok\")'")
    assert_equal output, "ok\n"
  end
end
