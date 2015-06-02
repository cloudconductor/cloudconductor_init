
import os
import logging
import json
import consul

import config

conf = config.load()


def hostname():
    import socket
    return socket.gethostname()


def get_platform_pattern():
    import glob
    import yaml

    for path in glob.glob(config.PATTERNS_DIR + '/**'):
        f = os.path.join(path, 'metadata.yml')
        if os.path.isfile(f):
            data = yaml.load(file(f))
            if data['type'] == 'platform':
                return os.path.basename(path), data

    return None, None


def node_address(hostname):
    c = consul.Consul()
    index, nodes = c.catalog.nodes()
    for node in nodes:
        if node['Node'] == hostname:
            return node['Address']

    return socket.gethostbyname(hostname)


def update_servers(name, info):
    key = 'cloudconductor/servers/' + name
    value = json.dumps(info, separators=(',', ':'))

    c = consul.Consul()
    c.kv.put(key, value, token=conf.token_key())


def get_host_info():
    conf = config.load()
    pattern_name, pattern_info = get_platform_pattern()
    ipaddress = node_address(hostname())

    return hostname(), {'roles': conf.roles(),
                        'pattern': pattern_name,
                        'private_ip': ipaddress}

if __name__ == '__main__':
    import sys
    import traceback

    logging.basicConfig(filename=config.LOG_FILE,
                        format='[%(asctime)s] %(levelname)s: %(message)s',
                        level=logging.DEBUG)

    try:
        host_name, host_info = get_host_info()
        update_servers(host_name, host_info)
        logging.info('updated servers successfully.: %s', host_info)
    except:
        logging.error('failed to put the host_info to Consul KVS. %s' +
                      os.linesep + '%s',
                      sys.exc_info()[1],
                      traceback.format_exc(sys.exc_info()[2]))
        raise
