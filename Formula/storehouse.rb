class Storehouse < Formula
  desc "File storage abstraction layer"
  homepage ""
  url "https://github.com/scanner-research/storehouse/archive/v0.6.3.tar.gz"
  sha256 "dbe87ecb2cf76de1c08a32c104dbda7c0ce9d5652fb43df387f7a141884dc26c"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "python"

  depends_on "glog"
  depends_on "gflags"
  depends_on "pybind11"
  depends_on "curl"

  def install
    python_version = Language::Python.major_minor_version("python3")

    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
    chdir "thirdparty" do
      FileUtils.mkdir "build"
      FileUtils.cd("build") do
        system "cmake", "..", *std_cmake_args
        system "make"
      end
    end

    FileUtils.mkdir "build"
    FileUtils.cd("build") do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end

    chdir "python" do
      system "python3", "setup.py", "bdist_wheel"
      system "pip3 install --prefix=" + libexec + " dist/storehouse-" + version.to_s + "*.whl"
    end

    site_packages = "lib/python#{python_version}/site-packages"
    pth_contents = "import site; site.addsitedir('#{libexec/site_packages}')\n"
    (prefix/site_packages/"homebrew-storehouse.pth").write pth_contents
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test storehouse`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
