class Scanner < Formula
  include Language::Python::Virtualenv

  desc "Efficient video analysis at scale"
  homepage "http://scanner.run"
  url "https://github.com/scanner-research/scanner/archive/v0.2.21.tar.gz"
  sha256 "540d8ad5120a46506a569127ccf85f596a99adb891b622df5b8d505d0afc3fc4"

  def caveats; <<~EOS
    Please run 'pip3 install scannerpy' to install pip dependencies.
  EOS
  end

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

    # Determine protobuf versions so we can install the correct pip packages
    protobuf_version = Formula["protobuf"].version
    grpc_version = Formula["grpc"].version
    system "sed -i '' \"s/'protobuf == [0-9.]*'/'protobuf == " + protobuf_version + "'/\" setup.py"
    system "sed -i '' \"s/'grpcio == [0-9.rc]*'/'grpcio == " + grpc_version + "'/\" setup.py"

    system "python3", "setup.py", "bdist_wheel"
    system "pip3 install --no-dependencies --prefix=" + libexec + " dist/*"

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
