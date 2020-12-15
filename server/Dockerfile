FROM centos:8

# Update all packages
RUN dnf -y update

# Add EPEL, PowerTools, Raven, and Raven Extras repo
RUN dnf -y install epel-release 'dnf-command(config-manager)'
RUN dnf -y config-manager --set-enabled PowerTools
# RUN dnf -y install https://pkgs.dyn.su/el8/base/x86_64/raven-release-1.0-1.el8.noarch.rpm
# RUN dnf -y install raven-release
# RUN dnf -y config-manager --set-enabled raven-extras

# mesa-libGL.i686 - OpenGL software renderer
# pulseaudio, pulseaudio-libs.i686 - Civ 5 needs somewhere to output audio
# supervisor - Lets up run and monitor a bunch of processes
# xorg-x11-server-Xvfb - Give us an in-memory display server without the need for a physical monitor
# x11vnc - Let us connect to the virtual display over VNC
# openbox - Super-lightweight window manager
# glibc.i686, libstdc++.i686 - General 32 bit libs
RUN dnf -y groupinstall "Development Tools"
RUN dnf -y install \
    mesa-libGL \
    mesa-libGL.i686 \
    mesa-libGL-devel \
    mesa-dri-drivers \
    mesa-dri-drivers.i686 \
    pulseaudio \
    pulseaudio-libs.i686 \
    supervisor \
    xorg-x11-server-Xvfb \
    x11vnc \
    openbox \
    glibc.i686 \
    libstdc++.i686 \
    gcc \
    libX11-devel \
    freetype-devel \
    zlib-devel \
    libxcb-devel \
    libxslt-devel \
    libgcrypt-devel \
    libxml2-devel \
    gnutls-devel \
    libpng-devel \
    libjpeg-turbo-devel \
    libtiff-devel \
    dbus-devel \
    fontconfig-devel \
    glibc-devel.i686 \
    libgcc.i686 \
    libstdc++-devel.i686 \
    ncurses-devel.i686 \
    libX11-devel.i686 \
    freetype-devel.i686 \
    zlib-devel.i686 \
    libxcb-devel.i686 \
    libxslt-devel.i686 \
    libgcrypt-devel.i686 \
    libxml2-devel.i686 \
    gnutls-devel.i686 \
    libpng-devel.i686 \
    libjpeg-turbo-devel.i686 \
    libtiff-devel.i686 \
    dbus-devel.i686 \
    fontconfig-devel.i686 \
    pulseaudio-libs-devel \
    pulseaudio-libs-devel.i686 \
    mesa-libGLU \
    mesa-libGLU.i686 \
    mesa-libGLU-devel \
    mesa-libGLU-devel.i686 \
    mesa-libOSMesa \
    mesa-libOSMesa.i686 \
    mesa-libOSMesa-devel \
    mesa-libOSMesa-devel.i686 \
    libXrender \
    libXrender.i686 \
    libXrender-devel \
    libXrender-devel.i686 \
    libXext \
    libXext-devel \
    libXext.i686 \
    libXext-devel.i686 \
    libXi \
    libXi-devel \
    libXi.i686 \
    libXi-devel.i686 \
    libXrandr \
    libXrandr-devel \
    libXrandr.i686 \
    libXrandr-devel.i686 \
    libXxf86vm \
    libXxf86vm-devel \
    libXxf86vm.i686 \
    libXxf86vm-devel.i686 \
    libXfixes \
    libXfixes-devel \
    libXfixes.i686 \
    libXfixes-devel.i686 \
    libXcomposite \
    libXcomposite-devel \
    libXcomposite.i686 \
    libXcomposite-devel.i686 \
    libXcursor \
    libXcursor-devel \
    libXcursor.i686 \
    libXcursor-devel.i686 \
    gstreamer1 \
    gstreamer1-devel \
    gstreamer1.i686 \
    gstreamer1-devel.i686 \
    gstreamer1-plugins-base \
    gstreamer1-plugins-base-devel \
    gstreamer1-plugins-base.i686 \
    gstreamer1-plugins-base-devel.i686 \
    SDL2 \
    SDL2-devel \
    SDL2.i686 \
    SDL2-devel.i686

WORKDIR /root
RUN curl https://dl.winehq.org/wine/source/5.0/wine-5.0.3.tar.xz -o wine.tar.xz
RUN tar xvf wine.tar.xz
RUN mkdir wine-5.0.3/wine32 wine-5.0.3/wine64
ENV CFLAGS="-g -O2 -std=gnu99"

# Build wine64
WORKDIR /root/wine-5.0.3/wine64
RUN ../configure --enable-win64 CFLAGS="${CFLAGS}"
RUN make -j 4

# Build wine32
WORKDIR /root/wine-5.0.3/wine32
RUN PKG_CONFIG_PATH=/usr/lib/pkgconfig ../configure --with-wine64=../wine64 CFLAGS="${CFLAGS}"
RUN make -j 4

# Install both wine builds
WORKDIR /root/wine-5.0.3/wine64
RUN make install
WORKDIR /root/wine-5.0.3/wine32
RUN make install

# Done!
WORKDIR /

ENV WINEARCH=win32

# Install Steam for Windows
# You don't even need to be logged in to Steam, it just needs to be there for the game to not crash when hosting a game
RUN curl "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" -o /root/SteamSetup.exe
RUN wine /root/SteamSetup.exe /S
RUN rm /root/SteamSetup.exe

# Install libstrangle to limit the framerate
RUN git clone https://gitlab.com/torkel104/libstrangle.git
RUN chmod a+rw /libstrangle
RUN cd /libstrangle && make && make install
RUN rm -rf /libstrangle

# Force software rendering, and also set $DISPLAY while we're here
ENV LIBGL_ALWAYS_SOFTWARE=1 MESA_LOADER_DRIVER_OVERRIDE=llvmpipe GALLIUM_DRIVER=llvmpipe DISPLAY=:99

# Make graphics look bad (less taxing on the CPU)
COPY ["./GraphicsSettingsDX9.ini", "/root/My Games/Sid Meier\\'s Civilization 5/GraphicsSettingsDX9.ini"]

# Add our list-of-stuff-to-execute
COPY ./supervisord.conf /etc/supervisord.conf

# For testing software rendering
# RUN dnf -y install glx-utils

CMD /usr/bin/supervisord -c /etc/supervisord.conf
