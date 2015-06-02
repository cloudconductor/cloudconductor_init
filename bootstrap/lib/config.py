# -*- coding: utf-8 -*-

import ConfigParser
import os

ROOT_DIR = '/opt/cloudconductor'
LOG_DIR = os.path.join(ROOT_DIR, 'logs')
PATTERNS_DIR = os.path.join(ROOT_DIR, 'patterns')
CONFIG_FILE = os.path.join(ROOT_DIR, 'config')

if not os.path.exists(LOG_DIR):
    os.mkdir(LOG_DIR)

LOG_FILE = os.path.join(LOG_DIR, 'bootstrap.log')


def env(name):
    return os.environ.get(name)


def load(path=None):
    return Config(path)


class Config:

    def __init__(self, path=None):
        self.data = None
        if path is None:
            path = CONFIG_FILE
        self.data = self.load(path)

    def load(self, path):
        fp = open(path)
        lines = fp.readlines()
        fp.close

        tmp = os.tmpfile()
        tmp.writelines(["[DEFAULT]", os.linesep])
        tmp.writelines(lines)
        tmp.seek(0)
        conf = ConfigParser.SafeConfigParser()
        conf.readfp(tmp)
        tmp.close()

        return conf

    def get(self, key):
        ret = env(key)
        if ret is None:
            if self.data is not None and self.data.has_option('DEFAULT', key):
                ret = self.data.get('DEFAULT', key)

        return ret

    def roles(self):
        ret = self.get('ROLE')
        return ret.split(',')

    def token_key(self):
        return self.get('CONSUL_SECRET_KEY')
