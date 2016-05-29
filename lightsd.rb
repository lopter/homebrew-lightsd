require "formula"

class Lightsd < Formula
  desc "Daemon to control your LIFX wifi smart bulbs"
  homepage "https://github.com/lopter/lightsd/"
  url "https://downloads.lightsd.io/releases/lightsd-1.2.0-rc.1.tar.gz"
  sha256 "1902996841122f353360b1cdc4e632a45fc164d47c6d56ff8e3ae855c460c6e6"
  revision 1

  depends_on "cmake" => :build
  depends_on "libevent" => :build
  depends_on "python3" => :optional

  def install
    # XXX, wtf? https://github.com/Homebrew/homebrew/issues/46061
    ENV["PATH"] = "/usr/bin:#{ENV["PATH"]}"

    args = std_cmake_args
    args << "-DLGTD_RUNTIME_DIRECTORY=#{var}/run/lightsd"

    # idk what std_cmake_args is supposed to do but it appears to be missing
    # proper release flags:
    cflags = %W[
      -fstack-protector-strong
      --param=ssp-buffer-size=4
      -O3
      -DNDEBUG
    ]
    args << "-DCMAKE_BUILD_TYPE=RELEASE"
    args << "-DCMAKE_C_FLAGS_RELEASE='#{cflags * " "}'"

    system "cmake", *args
    system "make", "install"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/lightsd</string>
          <string>-v</string>
          <string>warning</string>
          <string>-s</string>
          <string>#{var}/run/lightsd/socket</string>
          <string>-c</string>
          <string>#{var}/run/lightsd/pipe</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/lightsd.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/lightsd.log</string>
      </dict>
    </plist>
    EOS
  end

  def caveats; <<-EOS.undent
    Once you've started lightsd with launchctl load (see below), you can start
    poking around with lightsc.py:

      `lightsd --prefix`/share/lightsd/examples/lightsc.py
    EOS
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
