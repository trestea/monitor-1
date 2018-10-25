import time
import os
import requests
import datetime
from modules import base
import log


class monitor(base.monitor):
	def __init__(self, **kw):
		#super().__init__(**kw)
		self.addr = kw['addr']
		self.index_name = kw['index']

	def read(self):
		status = 0
		interval = 0
		desc = ''
		index_name = self.index_name + '-' + datetime.datetime.now().strftime('%Y%m%d%H')
		try:
			url = os.path.join(self.addr,'%s/type_blog/id_123' %index_name)
			res = requests.get(url)
			timestamp = res.json()['_source']['doc']['timestamp']
			interval = time.time() - timestamp
			status = 100
		except Exception as e:
			log.exception(e)
			status = 0
			desc = "ES ERROR %s" %e
		return base.metric('status',status,desc=desc),base.metric('interval',interval)


	def write(self):
		status = 0
		desc = ''
		index_name = self.index_name + '-' + (datetime.datetime.now() + datetime.timedelta(seconds=120)).strftime('%Y%m%d%H')
		last_index = self.index_name + '-' + (datetime.datetime.now() - datetime.timedelta(seconds=7200)).strftime('%Y%m%d%H')
		try:
			url = os.path.join(self.addr, '%s/type_blog/id_123' %index_name)
			doc = {'doc': {'timestamp': time.time()}}
			res = requests.post(url, json=doc)
			res_json = res.json()
			if res.status_code < 300 and 'result' in res_json and res_json['result'] in ('updated','created'):
				log.info('%s index:%s' %(res_json['result'],index_name))
				# 创建新index时删除旧index
				if res_json['result'] == 'created':
					# 失败重试3次
					i = 0
					while True:
						i += 1
						res = requests.delete(os.path.join(self.addr, last_index))
						if (i > 3) or (res.status_code == 200 and 'acknowledged' in res.json() and res.json()['acknowledged']):
							break
				status = 100
			else:
				log.error('write fail, header:%s, body:%s' %(str(res.headers),res.content))
		except Exception as e:
			log.exception(e)
			status = 0
			desc = "ES ERROR %s" %e
		status = float(status)
		return base.metric('status',status,desc=desc),
