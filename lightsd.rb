require "formula"

class Lightsd < Formula
  desc "Daemon to control your LIFX wifi smart bulbs"
  homepage "https://github.com/lopter/lightsd/"
  url "https://github.com/lopter/lightsd/archive/0.9.1.tar.gz"
  sha256 "72eba6074ed18609fb0caf7b7429e1b8f6c3564ca6f81357be22c06ac00956b6"
  revision 3

  depends_on "cmake" => :build
  depends_on "libbsd" => :optional
  depends_on "libevent" => :build
  depends_on "python" => :optional

  def install
    args = %W[
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_INSTALL_PREFIX=#{prefix}
    ]

    system "cmake", *args

    system "make", "install"
  end

  devel do
    url "https://github.com/lopter/lightsd.git"
    version "1.0"
  end

  test do
    Dir.mktmpdir("lightsd-test") do |dir|
      args = %W[
        -l ::1:0
        -l 127.0.0.1:0
        -c #{dir}/lightsd.cmd
        -h
      ]

      system "#{bin}/lightsd", *args
    end
  end
end
