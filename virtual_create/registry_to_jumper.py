#!/usr/bin/env python3
# *.* coding: utf-8 *.*
#
# author: liuchao
# email: mirs_chao@163.com
# date: 2022.03.13
# usage: 向jumpserver注册主机信息, 注册完毕后销毁该脚本或移动到别的地方; 
# 该脚本需要放置在模版中的/etc/rc.local.d/中


import sys
import json
import socket
import requests


class RegistryJumpserver:

    def __init__(self):
        self.jms_url = 'https://JUMPERURL'
        self.machines_url = '/api/v1/assets/assets/'
        self.admin_user_id = 'JUMPERADMINID'
        self.__jms_token = 'JUMPERPTOKEN'
        self.__headers = {
            'Authorization': f'Token {self.__jms_token}',
            'Content-Disposition': 'code/parse',
            'Content-Type': 'application/json'
        }
    
    def check_machines_exist(self):
        response = requests.get(
            url=f"{self.jms_url}{self.machines_url}",
            headers=self.__headers
        )
        ip_list = [element["ip"] for element in json.loads(response.text)]
        if socket.gethostbyname(socket.gethostname()) in set(ip_list):
            sys.exit(4004)

    def create_machines(self):

        self.check_machines_exist()

        post_data = {
            "hostname": f"{socket.gethostname()}",
            "ip": f"{socket.gethostbyname(socket.gethostname())}",
            "platform": "Linux",
            "admin_user": f"{self.admin_user_id}"
        }
        requests.post(
            url=f"{self.jms_url}{self.machines_url}",
            data=json.dumps(post_data),headers=self.__headers
        )


if __name__ == '__main__':
    jumper = RegistryJumpserver()
    jumper.create_machines()