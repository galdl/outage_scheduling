
#!/usr/bin/python

import sys, getopt,os,shutil

# for dn in os.listdir('.'):
#      if os.path.isfile(dn):
#         print (dn)

def main(argv):
   dir_list = ''
   white_list = ''
   try:
      opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
   except getopt.GetoptError:
      print 'test.py -i <dir_list> -o <white_list>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'test.py -i <dir_list> -o <white_list>'
         sys.exit()
      elif opt in ("-i", "--ifile"):
         dir_list = arg
      elif opt in ("-o", "--ofile"):
         white_list = arg
   print 'Dir list is', dir_list
   print 'White list is', white_list
   with open(white_list) as f:
    white_file = f.readlines()
    white_file = map(lambda s: s.strip(), white_file)
   for dn in os.listdir(dir_list):
    if not dn in white_file:
     print ('Deleting:' + dir_list + dn)
     shutil.rmtree(dir_list + dn)

if __name__ == "__main__":
   main(sys.argv[1:])