#!/bin/python

import csv
import urllib
import sys

if __name__ == "__main__":
	
	with open('payphone_set.csv', 'rb') as csvfile:
		csvreader = csv.reader(csvfile)
		for row in csvreader:
			if row[0] == 'ID':
				continue
			number = "+" + row[0]
			neighborhood = row[7]
			lat = row[5]
			lon = row[6]
			params = urllib.urlencode({'pay_phone[number]': number,
					 	   'pay_phone[neighborhood]': neighborhood,
					 	   'pay_phone[lat]': lat,
						   'pay_phone[lon]': lon})
			urllib.urlopen("http://sfpayphones.urbansmore.com/pay_phones", params)
			#sys.exit(0)
			
