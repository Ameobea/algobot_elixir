import os
import pprint
import struct

csv = open("USDCHF.csv", "w")
for filename in os.listdir("/home/ubuntu/bot/tick_data/USDCHF"):
	#filename = "AUDUSD-2010-00-01-03h_ticks"
	start = ((int(filename[7:][:4])-1970)*31536000) + (2628000*int(filename[12:][:2])) + (86400*(int(filename[15:][:2])-1)) + (3600*(int(filename[18:][:2])-1)) + 864000
	f = open("/home/ubuntu/bot/tick_data/USDCHF/"+filename, "rb")
	#f.read(4000)
	# for i in range(40):
	# 	
	byte = f.read(1)
	i=0
	resArray = []
	curTimestamp = []
	curAsk = []
	curAskVol = []
	curBid = []
	curBidVol = []
	while byte != "":
		byte = hex(ord(byte))
		if (i%20) < 4: #timestamp
			curTimestamp.append(byte)
		if (i%20) > 3 and (i%20) < 8: #ask
			curAsk.append(byte)
		if (i%20) > 7 and (i%20) < 12: #askVol
			curAskVol.append(byte)
		if (i%20) > 11 and (i%20) < 16: #bid
			curBid.append(byte)
		if (i%20) > 15: #bidVol
			curBidVol.append(byte)
		if len(curBidVol)==4:
			#print "---------------"
			arrayList = [curTimestamp,curAsk,curAskVol,curBid,curBidVol]
			for k in range(0,len(arrayList)): #For each of the 5 data arrays
				part = ""
				for b in arrayList[k]: #For each of the 4 bytes in them
					temp = b[2:]
					if len(temp) == 1: #If the byte 00 to 0F, add in the first 0
						temp = "0"+temp
					part += temp
				if k == 3 or k == 4:
					csv.write(str(round(struct.unpack('!f',part.decode('hex'))[0], 4)))
					if k==3:
						csv.write(",")
				elif k == 0:
					csv.write(str(start + (int(part,16)/1000.))+",")
				elif k == 1 or k == 2:
					csv.write(str(int(part,16)/100000.)+",") #Convert to int and print\
			csv.write("\n")
			curTimestamp = []
			curAsk = []
			curAskVol = []
			curBid = []
			curBidVol = []
		byte = f.read(1)
		i += 1
	f.close
