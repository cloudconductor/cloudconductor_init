#!/usr/bin/env python
# -*- coding: utf-8 -*-


def patterns(dir_path):
    import glob
    import os
    import yaml

    result = []

    for path in glob.glob(dir_path + '/**'):
        f = os.path.join(path, 'metadata.yml')
        if os.path.isfile(f):
            info = yaml.load(file(f))
            if info['type'] == 'platform' or info['type'] == 'optional':
                name = os.path.basename(path)
                data = {}
                data['name'] = name
                data['path'] = path
                data['metadata'] = info
                result.append(data)

    return result


if __name__ == '__main__':
    import sys
    argvs = sys.argv
    argc = len(argvs)

    path = argvs[1]

    import json
    print json.dumps(patterns(path))
