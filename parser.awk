BEGIN {
    hex = ""

    system("cat header.html")
}

{
    if ($1 == "<" || $1 == ">") {

        print "<div class=\"packet\">"
        print "    <p class=\"title"
        if ($1 == ">") {
            print " to-device\">TO DEVICE: "
        } else {
            print " from-device\">FROM DEVICE: "
        }
        print "<span>"$0"</span></p>"
        print "<div class=\"packet-contents\">"

    } else if ($0 == "--") {
        
        tmp_file = "/tmp/hex.log"
        bin_file = tmp_file".bin"
        
        # copy hex contents to tmp_file
        print hex > tmp_file

        # without closing will append to file
        close(tmp_file)

        # convert hex to binary
        # to look for plists inside
        system("rm -f "bin_file)
        system("xxd -r -p "tmp_file" "bin_file)

        # look for plists
        system("/bin/bash prettify.sh "bin_file)

        # system("rm "bin_file)

        # close "packet-contents" div
        print "</div>"
        # close "packet" class dic
        print "</div>"

        hex = ""

    } else {
        # xxd has mad bug that causes curruption of binary file
        # so we have to remove right part with plain-text
        # http://www.mail-archive.com/debian-bugs-dist@lists.debian.org/msg747054.html
        split($0, splitted, "  ")
        hex = hex""splitted[1]"\n"
    }
}

END {
    system("cat footer.html")
}