class AndroidNdkAT21c < Formula
  desc "Android native-code language toolset"
  homepage "https://developer.android.com/ndk/index.html"
  url "https://dl.google.com/android/repository/android-ndk-r21c-darwin-x86_64.zip"
  version "1"
  sha256 "99b31144aaae27e8becc6bc6f880dcd9949545cf0af5cad60f1111aecb3d6721"

  bottle :unneeded

  # As of r10e, only a 64-bit version is provided
  depends_on :arch => :x86_64

  def install
    bin.mkpath

    # Now we can install both 64-bit and 32-bit targeting toolchains
    prefix.install Dir["*"]

    # Create a dummy script to launch the ndk apps
    ndk_exec = prefix+"ndk-exec.sh"
    ndk_exec.write <<~EOS
      #!/bin/sh
      BASENAME=`basename $0`
      EXEC="#{prefix}/$BASENAME"
      test -f "$EXEC" && exec "$EXEC" "$@"
    EOS
    ndk_exec.chmod 0755
    %w[ndk-build ndk-depends ndk-gdb ndk-stack ndk-which].each { |app| bin.install_symlink ndk_exec => app }
    share.install_symlink prefix => "android-ndk"
  end

  def caveats; <<~EOS
    We agreed to the Android NDK License Agreement for you by downloading the NDK.
    If this is unacceptable you should uninstall.

    License information at:
    https://developer.android.com/sdk/terms.html

    Software and System requirements at:
    https://developer.android.com/sdk/ndk/index.html#requirements

    For more documentation on Android NDK, please check:
      #{prefix}/docs
    EOS
  end

  test do
    (testpath/"test.c").write("int main() { return 0; }")
    cc = Utils.popen_read("#{bin}/ndk-which gcc").strip
    system cc, "-c", "test.c", "-o", "test"
  end
end
