#! /usr/bin/python2.7

def print_ip(ip):
	with open('/root/list.txt', 'a') as f:
		f.write("{}\n".format(ip))

