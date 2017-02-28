py = require 'python'

print_ip = py.import "bl".print_ip
print_ip('1.2.1.2')

-- local status = os.execute("python /root/bl.py 1.2.3.4")
