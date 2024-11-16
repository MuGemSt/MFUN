import os
import json
import codecs
import hashlib
import traceback
import subprocess

parent_path = os.path.dirname(os.path.realpath(__file__))


def md5sum(full_path):
    with open(full_path, "rb") as rf:
        return hashlib.md5(rf.read()).hexdigest()


def get_or_create():
    conf_path = os.path.join(parent_path, "config.json")
    conf = {}
    if not os.path.isfile(conf_path):
        print("config.json not found, build.py is root path. auto write config.json")
        module_name = os.path.basename(parent_path)
        conf["module"] = module_name
        conf["version"] = "0.0.1"
        conf["home_url"] = "Module_%s.asp" % module_name
        conf["title"] = "title of " + module_name
        conf["description"] = "description of " + module_name

    else:
        with codecs.open(conf_path, "r", "utf-8") as fc:
            conf = json.loads(fc.read())

    return conf


def build_module():
    try:
        conf = get_or_create()

    except:
        print("config.json file format is incorrect")
        traceback.print_exc()

    if "module" not in conf:
        print(" module is not in config.json")
        return

    module_path = os.path.join(parent_path, conf["module"])
    if not os.path.isdir(module_path):
        print("not found %s dir, check config.json is module ?" % module_path)
        return

    install_path = os.path.join(parent_path, conf["module"], "install.sh")
    if not os.path.isfile(install_path):
        print("not found %s file, check install.sh file")
        return

    print("build...")
    open(parent_path + "/" + conf["module"] + "/" + "version", "w").write(
        conf["version"]
    )
    subprocess.run(["7z", "a", "-ttar", "./mfun.tar", "./mfun"], check=True)
    subprocess.run(["7z", "a", "-tgzip", "./mfun.tar.gz", "./mfun.tar"], check=True)
    os.remove("./mfun.tar")
    conf["md5"] = md5sum(os.path.join(parent_path, conf["module"] + ".tar.gz"))
    conf_path = os.path.join(parent_path, "config.json")
    with open(conf_path, "w", encoding="utf-8") as fw:
        json.dump(conf, fw, sort_keys=True, indent=4, ensure_ascii=False)

    print("build done", conf["module"] + ".tar.gz")


if __name__ == "__main__":
    build_module()
