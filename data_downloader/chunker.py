import os

pair = "USDCNH"
chunk_size = 500000 #size of chunked files in lines

input_file = open("/home/ubuntu/bot/tick_data/" + pair + "_sorted.csv", "r")
os.mkdir("/home/ubuntu/bot/tick_data/" + pair)
i = 0 #current progress in output file
l = 0 #current output chunk number
line = input_file.readline() #Read header line out of input csv
output_file = open("/home/ubuntu/bot/tick_data/" + pair + "/" + pair + "_" + str(l) + ".csv", "w+") #create and first output file
output_file.write(line) #write header line into first output file
index_file = open("/home/ubuntu/bot/tick_data/" + pair + "/index.csv", "w+") #create and index csv
index_file.write("block,start,end\n") #write header of input csv

line = input_file.readline() #read first data line out of input csv
index_file.write(str(l) + "," + line.split(",")[0] + ",")
while line:
  if(i > chunk_size): #if current output file full:
    i = 0 #reset output progress
    l += 1 #increment chunk number
    index_file.write(oldline.split(",")[0] + "\n") #finish previous index line with last line in chunk
    index_file.write(str(l) + "," + line.split(",")[0] + ",") #start next line of index with first line of new block
    output_file.close()
    output_file = open("/home/ubuntu/bot/tick_data/" + pair + "/" + pair + "_" + str(l) + ".csv", "w+") #create and open new output file after closing the old one.
    output_file.write("timestamp,ask,bid,askvol,bidvol\n") #add header line to the new output file
  output_file.write(line) #write data line into output file
  i += 1
  oldline = line #save copy of last line in case we have to index it
  line = input_file.readline() #read next line
output_file.write(oldline.split(",")[0])
