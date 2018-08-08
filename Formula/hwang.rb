class Hwang < Formula
  include Language::Python::Virtualenv

  desc "Fast sparse video decode"
  homepage "https://github.com/scanner-research/hwang"
  url "https://github.com/scanner-research/hwang/archive/v0.2.0.tar.gz"
  sha256 "89d8659466cc9daa42a8bbb14007b40c7e9069f878d899c35afeca4d35d4ed49"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "python"

  depends_on "glog"
  depends_on "gflags"
  depends_on "ffmpeg"
  depends_on "pybind11"
  depends_on "protobuf"

  def install
    python_version = Language::Python.major_minor_version("python3")

    system "bash", "deps.sh",
           "-a",
           "--with-pybind", "/usr/local",
           "--with-protobuf", "/usr/local/",
           "--with-ffmpeg", "/usr/local"
    FileUtils.mkdir "build"
    FileUtils.cd("build") do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end

    # resource("six").stage do
    #   system "python3", *Language::Python.setup_install_args(libexec)
    # end
    chdir "python" do
      system "python3", "setup.py", "bdist_wheel"
      system "pip3 install --prefix=" + libexec + " dist/hwang-" + version.to_s + "*.whl"
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
