
import sys
import json

import consul
import config

conf = config.load()


def consul_kv_get(key):
    c = consul.Consul()
    token_key = conf.token_key()
    index, data = c.kv.get(key, token=token_key)
    obj = json.loads(data['Value'])
    return obj


def read_parameters():
    return consul_kv_get('cloudconductor/parameters')


def cc_patterns(type=None):
    params = read_parameters()
    patterns = params['cloudconductor']['patterns']
    result = []
    for key, value in patterns.items():
        value['name'] = key
        if type is None:
            result.append(value)

        else:
            if value['type'] == type:
                result.append(value)

    return result

if __name__ == '__main__':
    argvs = sys.argv
    argc = len(argvs)
    print json.dumps(cc_patterns('optional'))
