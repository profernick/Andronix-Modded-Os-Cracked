RED="[31m"
GREEN="[32m"
YELLOW="[33m"
BLUE="[36m"
CLEAR="[39m"
BOLD="[1m"
ITALICS="[3m"
NORMAL="[0m"
VERSION=2
install_modded_os() {
name="Manjaro XFCE Modded OS"
distro=androjaro
folder=$distro-fs
url="$1"
maxsize=$(curl -X GET -sI "$url" | awk 'tolower($0) ~ /content-length/ {print $2}' | dos2unix)
curl https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/repo-fix.sh > repo.sh && chmod +x repo.sh && bash repo.sh && pkg install wget curl pv proot tar pulseaudio dos2unix -y
clear
echo " "
echo -e "We will be attempting to$BOLD remove any previous installation of $name$NORMAL"
echo ""
sleep 3
echo -e "$BLUE If you want to keep your old $name press$BOLD Ctrl + c within 5 seconds$NORMAL$CLEAR"
sleep 5
echo ""
echo " Removing installations of $name, if found..."
rm -rf $distro-binds $folder
echo " "
clear
echo -e "$YELLOW$BOLD Allow Storage Access permission to termux$NORMAL$CLEAR"
echo ""
echo -e "$YELLOW You might be asked to$ITALICS wipe ~/storage $NORMAL$YELLOW. Please don't worry and hit ENTER, it's completely safe and won't wipe anything off of your device.$CLEAR"
echo " "
sleep 3
termux-setup-storage
clear
echo -e "$BLUE$BOLD We are about to begin the installation of $name.$CLEAR$NORMAL"
echo ""
sleep 3
echo -e "$YELLOW$BOLD This is a resource hungry process 🏗 because we download and extract files simultaneously. Please close all other resource heavy processes and keep Termux in the foreground as long as possible.$NORMAL$CLEAR"
echo ""
echo ""
sleep 2
echo -e "If you noticed low download speeds, please understand that the speeds we are reporting denote simultaneous extraction and hence will depend on your CPU as well. Please be patient."
echo ""
mkdir -p $distro-binds $folder
echo -e "$GREEN$BOLD Downloading and Extracting $name...$NORMAL$CLEAR"
echo ""
wget -qO- --tries=0 "$url" | pv -s "$maxsize" | proot --link2symlink tar -Jxf - -C $folder || :
bin=start-$distro.sh
if [ -d $folder/var ]; then
clear
echo -e "$GREEN Enabling and configuring$BOLD audio support $NORMAL$CLEAR ."
if grep -q "anonymous" ~/../usr/etc/pulse/default.pa; then
sed -i '/anonymous/d' ~/../usr/etc/pulse/default.pa
echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >>~/../usr/etc/pulse/default.pa
else
echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >>~/../usr/etc/pulse/default.pa
fi
if grep -q "exit-idle" ~/../usr/etc/pulse/daemon.conf; then
sed -i '/exit-idle/d' ~/../usr/etc/pulse/daemon.conf
echo "exit-idle-time = -1" >>~/../usr/etc/pulse/daemon.conf
else
echo "exit-idle-time = -1" >>~/../usr/etc/pulse/daemon.conf
fi
echo "Done patching termux to enable audio playback"
echo ""
sleep 2
echo -e "$GREEN Writing$BOLD launch configuration $NORMAL$CLEAR ."
cat >$bin <<-EOM
cd \$(dirname \$0)
pulseaudio -k >>/dev/null 2>&1
pulseaudio --start >>/dev/null 2>&1
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A $distro-binds)" ]; then
for f in $distro-binds/* ;do
. \$f
done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b $folder/root:/dev/shm"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=en_US.UTF-8"
command+=" LC_ALL=C"
command+=" LANGUAGE=en_US"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
exec \$command
else
\$command -c "\$com"
fi
EOM
clear
echo ""
echo -e "$GREEN$BOLD Configuring the mirror list...$NORMAL$CLEAR ."
rm -rf $folder/etc/pacman.d/mirrorlist
wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Uninstall/mirrorlist -O $folder/etc/pacman.d/mirrorlist
echo -e "$GREEN$BOLD Patching tigervnc package...$NORMAL$CLEAR ."
sed -i '1s/^/sudo pacman-key --init \&\& sudo pacman-key --populate \&\& sudo pacman -Syu --noconfirm
/' $folder/root/.bash_profile
sed -i '2s/^/sudo pacman -S wget tar sed --noconfirm && wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Pacman/tigervnc-fix.sh && bash tigervnc-fix.sh
/' $folder/root/.bash_profile
clear
echo ""
echo -e "$GREEN$BOLD Configuring a couple of things more...$NORMAL$CLEAR ."
chmod -R 755 $folder
sed -i 's/sudo //g' $folder/usr/share/manjaro-arm-oem-install/manjaro-arm-oem-install
chmod 4755 $(find $folder -name sudo | grep bin)
chmod 4755 $(find $folder -name su | grep bin)
sed -i 's/\;/ \&\& /g' $folder/root/.bash_profile
sed -i '/switchuser/s/\& \/usr/\& exec \/usr/g' $folder/root/.bash_profile
sed -i '/vncpasswd/s/sbin/bin/g' $folder/usr/share/manjaro-arm-oem-install/manjaro-arm-oem-install
sed -i '/vncpasswd/s/sbin/bin/g' $folder/usr/local/bin/vncpasswd
echo -e "$GREEN$BOLD Completed!$NORMAL$CLEAR ."
sleep 2
clear
echo -e "$GREEN$BOLD Checking everything for the last time...$NORMAL$CLEAR ."
if test -f "$bin"; then
echo -e "$GREEN   Boot script present ✅$CLEAR ."
chmod +x $bin
echo " "
fi
FD=$folder
if [ -d "$FD" ]; then
echo -e "$GREEN   Boot container present ✅$CLEAR ."
echo " "
fi
UFD=$distro-binds
if [ -d "$UFD" ]; then
echo -e "$GREEN   Sub-Boot container present ✅$CLEAR ."
echo " "
fi
clear
echo -e "$GREEN$BOLD Download complete! $name...$NORMAL$CLEAR"
echo -e "$GREEN$BOLD Extracting complete! $name...$NORMAL$CLEAR"
echo -e "$GREEN$BOLD Installation complete! $name...$NORMAL$CLEAR"
echo ""
echo -e "$GREEN$BOLD Installation successful!$NORMAL$CLEAR ."
echo ""
echo -e "$BLUE You can start $name by running $BOLD./start-$distro.sh$NORMAL.$CLEAR "
echo ""
echo "--------------------------------------"
echo -e "$BOLD Need more help?$NORMAL"
echo ""
echo -e "$BOLD$BLUE Discord$NORMAL$CLEAR-$ITALICS https://chat.andronix.app"
echo -e "$BOLD$BLUE Documentation$NORMAL$CLEAR-$ITALICS https://docs.andronix.app"
echo "--------------------------------------"
echo ""
echo ""
else
echo ""
echo ""
echo -e "$RED$BOLD Installation unsuccessful!$NORMAL$CLEAR ."
echo -e "$YELLOW Please check your connectivity.$CLEAR ."
echo ""
echo "--------------------------------------"
echo -e "$BOLD Need more help?$NORMAL"
echo ""
echo -e "$BOLD$BLUE Discord$NORMAL$CLEAR-$ITALICS https://chat.andronix.app $NORMAL"
echo -e "$BOLD$BLUE Documentation$NORMAL$CLEAR-$ITALICS https://docs.andronix.app $NORMAL"
echo "--------------------------------------"
echo ""
echo ""
fi
}
if [[ "$VERSION" -eq 2 ]]; then
echo -e "$GREEN Using the latest$BOLD version 2 $NORMAL✅ $CLEAR"
echo -e "$GREEN Cracked version! $NORMAL✅ Rootfs downloading from not offical adronix server!"
install_modded_os "https://github.com/profernick/Andronix-Modded-Os-Cracked/releases/download/manjaro_ubuntu/manjaro.tar.xz"
fi
