function ideapad

    set helptext "ideapad OPTIONS:
    
--conservation_mode(-c): set Battery Conservation Mode (on/off)
--help (-h)            : print this help menu
--rapid_charge (r)     : set Rapid Charge Mode (on/off)
--status (-s)          : print the status"

set -l options (required=true, fish_opt -s s -l status)
set options $options (fish_opt -s h -l help)
set options $options (fish_opt -s c -l conservation_mode --required-val)
set options $options (fish_opt -s r -l rapid_charge --required-val)


argparse $options -- $argv || return

test -f /proc/acpi/call || begin;
    printf "Error: Missing dependencies. You need to install the packages 'linux-headers' and 'acpi_call-dkms'.\n"
    return
; end


if set -q _flag_help
    printf $helptext
    return
end

if set -q _flag_status
    set bool_cm 0
    echo '\_SB.PCI0.LPC0.EC0.BTSM' | sudo tee /proc/acpi/call > /dev/null
    set bool_cm (sudo cat /proc/acpi/call)
    
    test $bool_cm = "0x0" && echo "Battery Conservation Mode is OFF"
    test $bool_cm = "0x1" && echo "Battery Conservation Mode is ON"

    echo '\_SB.PCI0.LPC0.EC0.QCHO' | sudo tee /proc/acpi/call > /dev/null
    set bool_rc (sudo cat /proc/acpi/call)

    test $bool_rc = "0x0" && echo "Rapid Charge is OFF"
    test $bool_rc = "0x1" && echo "Rapid Charge is ON"
    return
end

if set -q _flag_conservation_mode
set valueToWrite 0
    echo "Changing Battery Conservation Mode..."
    begin; test $_flag_conservation_mode = "off" && echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' | sudo tee /proc/acpi/call > /dev/null; end || begin; test $_flag_conservation_mode = "on" && echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x03' | sudo tee /proc/acpi/call > /dev/null; end
    
    printf "Done!\nChecking...\n"

    set bool_cm 0
    echo '\_SB.PCI0.LPC0.EC0.BTSM' | sudo tee /proc/acpi/call > /dev/null
    set bool_cm (sudo cat /proc/acpi/call)

    test $bool_cm = "0x0" && echo "Battery Conservation Mode was changed successfully and is now OFF!"
    test $bool_cm = "0x1" && begin; echo "Battery Conservation Mode was changed successfully and is now ON!"

    echo '\_SB.PCI0.LPC0.EC0.QCHO' | sudo tee /proc/acpi/call > /dev/null
    set bool_rc (sudo cat /proc/acpi/call)
    test $bool_rc = "0x0" || begin; echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' | sudo tee /proc/acpi/call > /dev/null && printf "\nNote: As part of the Battery Conservation Mode, Rapid Charge has been disabled."; end
    end
    return

end

if set -q _flag_rapid_charge
    echo '\_SB.PCI0.LPC0.EC0.BTSM' | sudo tee /proc/acpi/call > /dev/null
    set bool_cm (sudo cat /proc/acpi/call)

    echo "Changing Rapid Charge Mode..."
    begin; test $_flag_rapid_charge = "off" && echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' | sudo tee /proc/acpi/call > /dev/null; end || begin; test $_flag_rapid_charge = "on" && echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x07' | sudo tee /proc/acpi/call > /dev/null; end
    printf "Done!\nChecking...\n"

    set bool_rc 0
    echo '\_SB.PCI0.LPC0.EC0.QCHO' | sudo tee /proc/acpi/call > /dev/null
    set bool_rc (sudo cat /proc/acpi/call)

    test $bool_rc = "0x0" && echo "Rapid Charge Mode was changed successfully and is now OFF!"
    test $bool_rc = "0x1" && begin; echo "Rapid Charge Mode was changed successfully and is now ON!"

    echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' | sudo tee /proc/acpi/call > /dev/null
    test bool_cm = "0x0" || printf "\nAs part of the Rapid Charge Mode, the Battery Conservation Mode has been disabled."
    end
    return
end


end
