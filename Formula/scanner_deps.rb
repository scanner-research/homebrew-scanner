class ScannerDeps < Formula
  include Language::Python::Virtualenv

  desc "Efficient video analysis at scale"
  homepage "http://scanner.run"
  url "https://github.com/scanner-research/scanner/archive/v0.2.0.tar.gz"
  sha256 "5fb700c7040c53ae3f422126ffb0417bb6a6e33eb406b719a54e42b7952966c3"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "python"

  depends_on "hwang"
  depends_on "storehouse"
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
           "--with-storehouse", "/usr/local"
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
