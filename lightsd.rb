require "formula"

class Lightsd < Formula
  desc "Daemon to control your LIFX wifi smart bulbs"
  homepage "https://github.com/lopter/lightsd/"
  url "https://api.github.com/repos/lopter/lightsd/tarball/0.9.1"
  sha256 "ef4f8056bf39c8f2c440e442f047cafce1c102e565bb007791a27f77588157c2"

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

  head do
    url "https://github.com/lopter/lightsd.git"
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
