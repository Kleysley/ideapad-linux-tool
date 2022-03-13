# ideapad-linux-tool

Fish function for checking and changing the battery conservation mode and the rapid charge mode on Lenovo IdeaPads. 

*Installation*

ARCH-based:

sudo pacman -S acpi_call-dkms
sudo modprobe acpi_call
git clone https://github.com/Kleysley/ideapad-linux-tool.git
cd ideapad-linux-tool
cp ideapad .config/fish/functions/ideapad.fish



DEBIAN-BASED

sudo apt install acpi-call-dkms
sudo modprobe acpi-call
git clone https://github.com/Kleysley/ideapad-linux-tool.git
cd ideapad-linux-tool
vp ideapad .config/fish/functions/ideapad.fish
