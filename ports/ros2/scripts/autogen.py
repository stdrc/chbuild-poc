import sys, os, stat, json

path = os.path.split(os.path.realpath(__file__))[0]
compiler_path = "/home/ipads/musl-cross-make-0.9.9/install/bin/"
aarch64_openldap_path = "/home/ipads/"  # The available openldap repo
log_file = path + "/build.log"
install_path = os.environ["CHPM_BUILD_DIR"] + "/sysroot/"
download_path = path + "/../download/"
build_script_path = path + "/third-party-install.sh"
info_file = path + "/source-list"

arch = sys.argv[1]
source_base_path = path + "/../download/source-" + arch + "/"
progress_file = download_path + "/.progress-" + arch
autogen_path = path + "/autogen-" + arch + "/"
if arch == "x86_64":
    host_name = "x86_64-unknown-linux"
    target = "x86_64-linux-musl"
else:
    host_name = "aarch64-unknown-linux"
    target = "aarch64-linux-musleabi"

conf_var = {
    "CC": compiler_path + target + "-gcc",
    "CXX": compiler_path + target + "-g++",
    "CPP": compiler_path + target + "-g++",
    "AR": compiler_path + target + "-ar",
    "READELF": compiler_path + target + "-readelf",
    "RANLIB": compiler_path + target + "-ranlib",
    "LD": compiler_path + target + "-ld",
    "STRIP": compiler_path + target + "-strip",
    "CFLAGS": '"-I'
    + install_path
    + "include "
    + "-L"
    + install_path
    + "lib "
    + " --sysroot="
    + install_path
    + " "
    + '"',
    "LDFLAGS": '"-L' + install_path + "lib " + " --sysroot=" + install_path + " " + '"',
    "CXXFLAGS": '"-I'
    + install_path
    + "include "
    + "-L"
    + install_path
    + "lib "
    + " --sysroot="
    + install_path
    + " "
    + '"',
    "CPPFLAGS": '"-I'
    + install_path
    + "include "
    + "-L"
    + install_path
    + "lib "
    + " --sysroot="
    + install_path
    + " "
    + '"',
    "PKG_CONFIG_PATH": install_path + "lib/pkgconfig",
    "LD_LIBRARY_PATH": "$LD_LIBRARY_PATH:" + install_path + "lib",
    "INSTALL_PATH": install_path,
    "DOWNLOAD_PATH": download_path,
    "ARCH": arch,
    "HOST": host_name,
    "COMPILER": compiler_path,
    "TARGET": target,
}


def get_source_path(data):
    source_path = source_base_path + data["name"] + "/" + data["path"]
    return source_path


def user_cmd_parse(data, cmd):
    for i in conf_var:
        cmd = cmd.replace("$(%s)" % i, conf_var[i])
    source_path = get_source_path(data)
    cmd = cmd.replace("$(SOURCE_PATH)", source_path)
    return cmd


def gen_config_cmd(data, cmd):
    cmd = cmd + " --prefix=" + conf_var["INSTALL_PATH"]
    if data.has_key("host"):
        cmd = cmd + " --host=" + conf_var["HOST"]
    if data.has_key("conf_flags"):
        for i in data["conf_flags"]:
            i = user_cmd_parse(data, i)
            cmd = cmd + " " + i
    if data.has_key("conf_var"):
        for i in data["conf_var"]:
            cmd = cmd + " " + i + "=" + conf_var[i]

    return cmd


def gen_install_cmd(data):
    cmd = "make install -j`nproc`"
    if data.has_key("install_flags"):
        for i in data["install_flags"]:
            i = user_cmd_parse(data, i)
            cmd = cmd + " " + i
    return cmd


def gen_make_cmd(data):
    cmd = "make V=1 -j`nproc`"
    # cmd = "make -j`nproc`"
    if data.has_key("build_flags"):
        for i in data["build_flags"]:
            i = user_cmd_parse(data, i)
            cmd = cmd + " " + i
    return cmd


def gen_cmake_cmd(data):
    cmd = "cmake ."
    cmd = cmd + " -DCMAKE_C_COMPILER=" + conf_var["CC"]
    cmd = cmd + " -DCMAKE_CXX_COMPILER=" + conf_var["CXX"]
    cmd = cmd + " -DCMAKE_INSTALL_PREFIX=" + install_path
    cmd = cmd + " -DCMAKE_SYSROOT=" + install_path
    if data.has_key("conf_flags"):
        for i in data["conf_flags"]:
            i = user_cmd_parse(data, i)
            cmd = cmd + " " + i
    return cmd


def autogen():
    with open(info_file) as f:
        build_info = json.load(f)

        build_script = open(build_script_path, "w+")
        build_script.write("#!/bin/bash\n")

        conf_size = len(build_info)
        index = 1

        for data in build_info:
            lib_name = data["name"]
            autogen_name = autogen_path + lib_name + "-build.sh"
            download_link = data["download"]
            download_name = download_link[download_link.rfind("/") + 1 :]

            build_script.write("# %s\n" % (lib_name))

            build_script.write('echo "Start building %s ..."\n' % (lib_name))
            build_script.write("%s\n" % (autogen_name))
            build_script.write("res=$?\n")
            build_script.write("if [ $res -eq 1 ]; then\n")
            build_script.write(
                '\techo -e "[  \\033[33mPASS\\033[0m  ](%d/%d): %s"\n'
                % (index, conf_size, lib_name)
            )
            build_script.write("elif [ $res -eq 0 ]; then\n")
            build_script.write(
                '\techo -e "[ \\033[32mSUCCESS\\033[0m ](%d/%d): %s"\n'
                % (index, conf_size, lib_name)
            )
            build_script.write("else\n")
            build_script.write(
                '\techo -e "[  \\033[31mERROR\\033[0m  ](%d/%d): fail to build %s"\n'
                % (index, conf_size, lib_name)
            )
            build_script.write("\texit -1\n")
            build_script.write("fi\n")
            build_script.write(
                'echo "==========================================================================="\n'
            )
            index = index + 1

            gen_file = open(autogen_name, "w+")
            gen_file.write("#!/bin/bash\n")
            gen_file.write("rm -f %s\n\n" % (log_file))

            gen_file.write("\n# check whether we have built the source ... \n")
            gen_file.write("if [[ -f %s ]]; then\n" % (progress_file))
            gen_file.write(
                "\tif [[ `grep -c \"^%s$\" %s` -ne '0' ]]; then\n"
                % (lib_name, progress_file)
            )
            gen_file.write(
                '\t\techo "%s has already been built. Switch to the next ..."\n'
                % (lib_name)
            )
            gen_file.write("\t\texit 1\n")
            gen_file.write("\tfi\n")
            gen_file.write("fi\n")

            gen_file.write("\n# download begins ... \n")
            gen_file.write("if [[ ! -f %s ]]; then\n" % (download_path + download_name))
            gen_file.write("\twget -P %s %s\n" % (download_path, download_link))
            gen_file.write("\tif [ $? -ne 0 ]; then\n")
            gen_file.write('\t\techo "ERROR: fail to download %s"\n' % (download_name))
            gen_file.write("\t\texit -1\n")
            gen_file.write("\tfi\n")
            gen_file.write("fi\n")

            if data["name"] == "openldap" and arch != "x86_64":
                gen_file.write("\nmkdir -p %s\n" % (source_base_path + lib_name))
                gen_file.write(
                    "cp -r "
                    + aarch64_openldap_path
                    + "openldap-2.4.45+dfsg "
                    + source_base_path
                    + lib_name
                )
            else:
                gen_file.write("\n# extraction begins ... \n")
                gen_file.write("mkdir -p %s\n" % (source_base_path + lib_name))
                gen_file.write(
                    "tar -axf %s -C %s\n"
                    % (download_path + download_name, source_base_path + lib_name)
                )
                gen_file.write("if [ $? -ne 0 ]; then\n")
                gen_file.write(
                    '\techo "ERROR: fail to extract %s"\n'
                    % (download_path + download_name)
                )
                gen_file.write("\texit -1\n")
                gen_file.write("fi\n")

            source_path = get_source_path(data)

            gen_file.write("\n# switch to %s ... \n" % (source_path))
            gen_file.write("cd %s\n" % (source_path))
            gen_file.write("if [ $? -ne 0 ]; then\n")
            gen_file.write('\techo "ERROR: wrong path %s"\n' % (source_path))
            gen_file.write("\texit -1\n")
            gen_file.write("fi\n")

            if data.has_key("early_commands"):
                gen_file.write("\n# early commands begin ... \n")
                for cmd in data["early_commands"]:
                    cmd = user_cmd_parse(data, cmd)
                    gen_file.write("%s >> %s 2>&1\n" % (cmd, log_file))
                    if not data.has_key("early_commands_err_ignore"):
                        gen_file.write("if [ $? -ne 0 ]; then\n")
                        gen_file.write(
                            "\techo \"ERROR: early command '%s' failed.\"\n" % (cmd)
                        )
                        gen_file.write("\texit -1\n")
                        gen_file.write("fi\n\n")

            gen_file.write("\n# configure begins ... \n")
            if data["conf"] == "configure":

                cmd = "./configure"
                cmd = gen_config_cmd(data, cmd)
                gen_file.write("%s >> %s 2>&1\n" % (cmd, log_file))

            elif data["conf"] == "cmake":
                cmd = gen_cmake_cmd(data)
                gen_file.write("%s >> %s 2>&1\n" % (cmd, log_file))

            if data.has_key("conf_commands"):
                gen_file.write("\n# configure commands begin ... \n")
                for cmd in data["conf_commands"]:
                    cmd = user_cmd_parse(data, cmd)
                    gen_file.write("%s >> %s 2>&1\n" % (cmd, log_file))
                    gen_file.write("if [ $? -ne 0 ]; then\n")
                    gen_file.write(
                        "\techo \"ERROR: configure command '%s' failed.\"\n" % (cmd)
                    )
                    gen_file.write("\texit -1\n")
                    gen_file.write("fi\n\n")

            gen_file.write("\n# build begins ... \n")
            if data["build"] == "make-install":
                cmd = gen_make_cmd(data)
                gen_file.write("%s >> %s 2>&1\n" % (cmd, log_file))
                gen_file.write("if [ $? -ne 0 ]; then\n")
                gen_file.write('\techo "ERROR: make %s failed."\n' % (lib_name))
                gen_file.write("\texit -1\n")
                gen_file.write("fi\n")

                cmd = gen_install_cmd(data)
                gen_file.write("%s >> %s 2>&1\n" % (cmd, log_file))
                gen_file.write("if [ $? -ne 0 ]; then\n")
                gen_file.write('\techo "ERROR: make install %s failed."\n' % (lib_name))
                gen_file.write("\texit -1\n")
                gen_file.write("fi\n")
            elif data["build"] == "make-noinstall":
                cmd = gen_make_cmd(data)
                gen_file.write("%s >> %s 2>&1\n" % (cmd, log_file))
                if not data.has_key("build_err_ignore"):
                    gen_file.write("if [ $? -ne 0 ]; then\n")
                    gen_file.write('\techo "ERROR: make %s failed."\n' % (lib_name))
                    gen_file.write("\texit -1\n")
                    gen_file.write("fi\n")
                if data.has_key("include"):
                    gen_file.write(
                        "\n# copy headers to %s ... \n" % (install_path + "include/")
                    )
                    for i in data["include"]:
                        gen_file.write(
                            "cp -r %s %s >> %s 2>&1\n"
                            % (
                                source_path + "/" + i,
                                install_path + "include/",
                                log_file,
                            )
                        )

                if data.has_key("lib"):
                    gen_file.write(
                        "\n# copy libraries to %s ... \n" % (install_path + "lib/")
                    )
                    for i in data["lib"]:
                        gen_file.write(
                            "cp -r %s %s >> %s 2>&1\n"
                            % ("./" + i, install_path + "lib/", log_file)
                        )
                        gen_file.write("if [ $? -ne 0 ]; then\n")
                        gen_file.write(
                            '\techo "ERROR: fail to copy %s."\n' % ("./" + i)
                        )
                        gen_file.write("\texit -1\n")
                        gen_file.write("fi\n\n")

                if data.has_key("sl-lib"):
                    gen_file.write("\n# create soft links to libraries ... \n")
                    gen_file.write("cd %s\n" % (install_path + "lib"))
                    for i in data["sl-lib"]:
                        gen_file.write(
                            "ln -sf %s %s >> %s 2>&1\n" % (i[1], i[0], log_file)
                        )

            if data.has_key("late_commands"):
                gen_file.write("\n# late commands begin ... \n")
                for cmd in data["late_commands"]:
                    cmd = user_cmd_parse(data, cmd)
                    gen_file.write("%s >> %s 2>&1\n" % (cmd, log_file))
                    gen_file.write("if [ $? -ne 0 ]; then\n")
                    gen_file.write(
                        "\techo \"ERROR: late command '%s' failed.\"\n" % (cmd)
                    )
                    gen_file.write("\texit -1\n")
                    gen_file.write("fi\n\n")

            # gen_file.write("touch %s/.pass\n" % (get_source_path(data)))
            gen_file.write('echo "%s" >> %s\n' % (lib_name, progress_file))
            gen_file.write("cd %s\n" % (path))
            # gen_file.write("rm -rf %s\n" % (download_path + "../" + lib_name))
            gen_file.write("exit 0\n")
            gen_file.close()
            os.chmod(autogen_name, stat.S_IRWXU + stat.S_IRWXG + stat.S_IRWXO)

        build_script.write(
            '\techo "Libraries have been built and installed successfully. Source files are removed."\n'
        )
        build_script.write("rm -rf %s\n" % (source_base_path))
        build_script.close()
        os.chmod(build_script_path, stat.S_IRWXU + stat.S_IRWXG + stat.S_IRWXO)


autogen()
