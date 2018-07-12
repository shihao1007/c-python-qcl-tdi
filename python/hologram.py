# -*- coding: utf-8 -*-
"""
Created on Wed Jul 11 14:12:59 2018

@author: shihao
"""

# -*- coding: utf-8 -*-
"""
Created on Wed Jun 20 10:20:40 2018

@author: shihao
"""

import numpy
from matplotlib import pyplot as plt
import os, os.path
from matplotlib import animation as animation
import subprocess
from pylab import *

#specify all imaging parameters
data_dir = r'C:\Users\shihao\Desktop\ir-images\ir-holography\brokencage-beads3'  #directory of all raw data
zstep = 1               #stage moving stepsize, delta_m, lightpath length difference in the hologram
num_frames = 50         #number of averaged frames for each image, to minimize laser fluctuation
positions = 20          #number of different positions of the stage. i.e. number of measurements
lp = 60                 #laser power
inte = 37               #integration time of FPA

#initialize a array for storing all image data
image_seq = numpy.zeros((128, 128, positions))
ref_seq = numpy.zeros((128, 128, positions))
ref_sqrt = numpy.zeros((128, 128))
#call .exe file to do imaging
#subprocess.call([r"qcl-holo-cap.exe", data_dir, '--zstep', str(zstep), '--positions', str(positions), '--frames', str(num_frames), '--laserpower', str(lp), '--inte', str(inte)])

#reading in all images to the data array initialized before
image_list = os.listdir(data_dir)
number_files = len(image_list)
if( number_files != positions):
    print("Error: Image is missing!")
else:
    for i in range(number_files):
        image_dir = data_dir + '\\' + image_list[i]
        image_data = numpy.fromfile(image_dir, dtype = numpy.uint16, count = -1, sep = '')
        image_data = numpy.reshape(image_data, (128, 128), order = 'C')
        image_seq[:, :, i] = image_data

#read in background image
re_dir = r'C:\Users\shihao\Desktop\ir-images\ir-holography\brokencage-beads3-bg'
re_list = os.listdir(re_dir)
number_res = len(re_list)
if( number_res != positions):
    print("Error: Reference Image is missing!")
else:
    for i in range(number_files):
        ref_dir = re_dir + '\\' + re_list[i]
        ref_data = numpy.fromfile(ref_dir, dtype = numpy.uint16, count = -1, sep = '')
        ref_data = numpy.reshape(ref_data, (128, 128), order = 'C')
        ref_seq[:, :, i] = ref_data
        
    ref_intensity = sum(ref_seq, axis = 2) / positions
    ref_sqrt = numpy.sqrt(ref_intensity)

#get the maximal and minimal values of all images to turn off auto-scaling
_min, _max = numpy.amin(image_seq), numpy.amax(image_seq)    


##plot the hologram and write out a .mp4 file
#fig = plt.figure()
##for i in range(positions):
##    plt.imshow(image_seq[:, :, i], vmin = _min, vmax = _max)
##    plt.pause(0.05)
##plt.show()
#img = []
#for i in range(positions):
#    img.append([plt.imshow(image_seq[:, :, i], vmin = _min, vmax = _max)])
#
#ani = animation.ArtistAnimation(fig,img,interval=200)
#writer = animation.writers['ffmpeg'](fps=5)
#
#ani.save(data_dir + '\\demo_' + str(num_frames) + '.mp4',writer=writer)


#specify which portion of hologram will be used to calculate field
num = 4
start = 0
end = start + num
lambdA = 8
k = 2 * numpy.pi / lambdA

D = [(image_seq[:,:,start + i + 1] - image_seq[:,:,start + i]) for i in range(num)]
P = [[numpy.exp(-1j * k * zstep * i), numpy.exp(1j * k * zstep * i)] for i in range(num)]

D = numpy.asarray(D)
P = numpy.matrix(numpy.asarray(P))
P_hermint = P.getH()
PH_P_inv = numpy.linalg.inv(P_hermint * P)

PH_P_Ph =  PH_P_inv * P_hermint

U = numpy.zeros((2,1,128,128))

PH_P_Ph = numpy.asarray(PH_P_Ph)
PH_P_Ph = numpy.repeat((numpy.repeat(numpy.reshape(PH_P_Ph,(2,4,1,1)),128,axis = 2)),128,axis = 3)
D = D.reshape(4,1,128,128)
for i in range(128):
    for j in range(128):
        U[:,:,i,j] = numpy.dot(PH_P_Ph[:,:,i,j], D[:,:,i,j])
        
f = numpy.zeros((1,1,128,128))
f[:] = U[1,:,:,:]
f = f.reshape((128,128))

expterm = numpy.exp(-1j * k * zstep) - 1
dominator = expterm * ref_sqrt

F = f / dominator

plt.figure()
plt.imshow(numpy.real(F))