#!/usr/bin/env bash
# Builds the small, self-contained ffmpeg that ships inside Inktion: only what the app uses
# (export: H.264/ProRes/VP9 video with AAC/PCM/Opus audio; import: common video formats).
# Runs on macOS and on Windows under MSYS2 (MINGW64). Sources are pinned release versions of
# the unmodified upstream projects; this script is the complete build recipe (GPL §3).
# Usage: scripts/build-ffmpeg.sh <output-dir>      → <output-dir>/ffmpeg[.exe]
set -euo pipefail

FFMPEG=7.1.1
X264=b35605ace3ddf7c1a5d67a2eb553f034aef41d55   # x264 stable branch
LIBVPX=v1.15.2
OPUS=1.5.2

OUT="$(mkdir -p "$1" && cd "$1" && pwd)"
WORK="${WORK:-$(pwd)/target/ffmpeg-build}"
PREFIX="$WORK/prefix"
mkdir -p "$WORK/src" "$PREFIX"
cd "$WORK/src"
JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

case "$(uname -s)" in
  Darwin) OS=mac; export MACOSX_DEPLOYMENT_TARGET=12.0 ;;
  MINGW*|MSYS*) OS=win ;;
  *) echo "unsupported system" >&2; exit 1 ;;
esac

fetch() { # url dir
  [[ -d "$2" ]] || { mkdir -p "$2"; curl -fsSL "$1" | tar -xz -C "$2" --strip-components=1; }
}

# x264 (GPL): H.264 for MP4.
fetch "https://code.videolan.org/videolan/x264/-/archive/$X264/x264-$X264.tar.gz" x264
if [[ ! -f "$PREFIX/lib/libx264.a" ]]; then
  (cd x264 && ./configure --prefix="$PREFIX" --enable-static --disable-cli --enable-pic --disable-opencl \
    && make -j"$JOBS" && make install)
fi

# libvpx (BSD): VP9 with transparency for WebM.
fetch "https://github.com/webmproject/libvpx/archive/refs/tags/$LIBVPX.tar.gz" libvpx
if [[ ! -f "$PREFIX/lib/libvpx.a" ]]; then
  VPX_TARGET=()
  [[ $OS == win ]] && VPX_TARGET=(--target=x86_64-win64-gcc --as=nasm)
  (cd libvpx && ./configure --prefix="$PREFIX" ${VPX_TARGET[@]+"${VPX_TARGET[@]}"} --enable-static --disable-shared \
    --disable-examples --disable-tools --disable-docs --disable-unit-tests --enable-vp9 --disable-vp8-decoder \
    --enable-pic && make -j"$JOBS" && make install)
fi

# Opus (BSD): WebM audio.
fetch "https://downloads.xiph.org/releases/opus/opus-$OPUS.tar.gz" opus
if [[ ! -f "$PREFIX/lib/libopus.a" ]]; then
  (cd opus && ./configure --prefix="$PREFIX" --enable-static --disable-shared --disable-doc --disable-extra-programs \
    && make -j"$JOBS" && make install)
fi

fetch "https://ffmpeg.org/releases/ffmpeg-$FFMPEG.tar.gz" ffmpeg
EXTRA=()
[[ $OS == win ]] && EXTRA=(--extra-ldflags=-static --pkg-config-flags=--static)
[[ $OS == mac ]] && EXTRA=(--pkg-config-flags=--static)
cd ffmpeg
./configure --prefix="$WORK/ffmpeg-out" ${EXTRA[@]+"${EXTRA[@]}"} \
  --enable-gpl --enable-version3 --enable-static --disable-shared \
  --disable-autodetect --disable-everything --disable-network --disable-doc --disable-debug \
  --disable-ffplay --disable-ffprobe --disable-avdevice --disable-postproc \
  --enable-libx264 --enable-libvpx --enable-libopus \
  --enable-protocol=file,pipe,fd \
  --enable-encoder=libx264,prores_ks,libvpx_vp9,aac,pcm_s16le,libopus,rawvideo \
  --enable-decoder=rawvideo,h264,hevc,prores,vp8,vp9,mpeg4,mpeg2video,mjpeg,png,gif,dnxhd,pcm_s16le,pcm_f32le \
  --enable-muxer=mp4,mov,webm,matroska,rawvideo \
  --enable-demuxer=rawvideo,mov,matroska,avi,mpegts,mpegps,m4v,h264,hevc,gif,wav \
  --enable-parser=h264,hevc,vp8,vp9,mpeg4video,mpegvideo,mjpeg,png,gif,opus,aac \
  --enable-bsf=vp9_superframe,vp9_superframe_split,aac_adtstoasc \
  --enable-filter=buffer,buffersink,abuffer,abuffersink,format,aformat,scale,pad,fps,null,anull,aresample,setpts,asetpts,atrim,apad
make -j"$JOBS"
EXE=""
[[ $OS == win ]] && EXE=".exe"
cp "ffmpeg$EXE" "$OUT/ffmpeg$EXE"
strip "$OUT/ffmpeg$EXE" 2>/dev/null || true
cp COPYING.GPLv3 "$OUT/FFMPEG-LICENSE.txt"
echo "Built $OUT/ffmpeg$EXE ($(du -h "$OUT/ffmpeg$EXE" | cut -f1))"
