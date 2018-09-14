class Scanner < Formula
  include Language::Python::Virtualenv

  desc "Efficient video analysis at scale"
  homepage "http://scanner.run"
  url "https://github.com/scanner-research/scanner/archive/v0.2.18.tar.gz"
  sha256 "6ba41e09bad32469a9bf00dc03a683c439573f2abb9d27ccc61f24b8f1606ec9"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "python"

  depends_on "storehouse"
  depends_on "hwang"
  depends_on "wget"
  depends_on "glog"
  depends_on "gflags"
  depends_on "ffmpeg"
  depends_on "opencv"
  depends_on "caffe"
  depends_on "libpq"
  depends_on "libpqxx"
  depends_on "pybind11"
  depends_on "protobuf"
  depends_on "grpc"

  def install
    python_version = Language::Python.major_minor_version("python3")

    system "bash", "deps.sh",
           "-a",
           "-ng",
           "--prefix", prefix,
           "--with-ffmpeg", "/usr/local",
           "--with-opencv", "/usr/local",
           "--with-protobuf", "/usr/local",
           "--with-grpc", "/usr/local",
           "--with-caffe", "/usr/local",
           "--with-hwang", "/usr/local",
           "--with-pybind", "/usr/local",
           "--with-libpqxx", "/usr/local",
           "--with-storehouse", "/usr/local",
           "--with-hwang", "/usr/local"

    FileUtils.mkdir "build"

    FileUtils.cd("build") do
      system "cmake", "..", *std_cmake_args
      system "make"
    end

    system "python3", "setup.py", "bdist_wheel"
    system "CMAKE_PREFIX_PATH="" PKG_CONFIG_PATH="" pip3 install --prefix=" + libexec + " grpcio==1.12.0"
    system "pip3 install --prefix=" + libexec + " dist/*"
    system "CMAKE_PREFIX_PATH="" PKG_CONFIG_PATH="" pip3 install --prefix=" + libexec + " grpcio==1.14.0"
    system "CMAKE_PREFIX_PATH="" PKG_CONFIG_PATH="" pip3 install --prefix=" + libexec + " protobuf==3.6.0"

    site_packages = "lib/python#{python_version}/site-packages"
    pth_contents = "import site; site.addsitedir('#{libexec/site_packages}')\n"
    (prefix/site_packages/"homebrew-scanner.pth").write pth_contents
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test scanner`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
