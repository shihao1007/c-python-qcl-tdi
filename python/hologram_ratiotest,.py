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
data_dir = r'C:\Users\shihao\Desktop\ir-images\ir-holography\bead5\bead_holo'  #directory of all raw data
zstep = 1               #stage moving stepsize, delta_m, lightpath length difference in the hologram
num_frames = 100         #number of averaged frames for each image, to minimize laser fluctuation
positions = 200          #number of different positions of the stage. i.e. number of measurements
ref_pos = 20
lp = 60                 #laser power
inte = 33               #integration time of FPA

#initialize a array for storing all image data
image_seq = numpy.zeros((128, 128, positions))
image_seq_raw = numpy.zeros((128, 128, positions))
image_seq_ratio = numpy.zeros((128, 128, positions))
image_seq_sub = numpy.zeros((128, 128, positions))
ref_seq = numpy.zeros((128, 128, positions))
ref_sqrt = numpy.zeros((128, 128))
bg_seq = numpy.zeros((128, 128, positions))
bg_obj_seq = numpy.zeros((128, 128, ref_pos))
bead_obj_seq= numpy.zeros((128, 128, ref_pos))
#call .exe file to do imaging
#subprocess.call([r"qcl-holo-cap.exe", data_dir, '--zstep', str(zstep), '--positions', str(positions), '--frames', str(num_frames), '--laserpower', str(lp), '--inte', str(inte)])



#read in reference image
re_dir = r'C:\Users\shihao\Desktop\ir-images\ir-holography\bead5\ref'
re_list = os.listdir(re_dir)
number_res = len(re_list)
if( number_res != ref_pos):
    print("Error: Reference Image is missing!")
else:
    for i in range(number_res):
        ref_dir = re_dir + '\\' + re_list[i]
        ref_data = numpy.fromfile(ref_dir, dtype = numpy.uint16, count = -1, sep = '')
        ref_data = numpy.reshape(ref_data, (128, 128), order = 'C')
        ref_seq[:, :, i] = ref_data
        
    ref_intensity = sum(ref_seq, axis = 2) / positions
    ref_sqrt = numpy.sqrt(ref_intensity)
    
#read in background image
bgs_dir = r'C:\Users\shihao\Desktop\ir-images\ir-holography\bead5\bg_holo'
bgs_list = os.listdir(bgs_dir)
number_bgs = len(bgs_list)
if( number_bgs != positions):
    print("Error: Background Image is missing!")
else:
    for i in range(number_bgs):
        bg_dir = bgs_dir + '\\' + bgs_list[i]
        bg_data = numpy.fromfile(bg_dir, dtype = numpy.uint16, count = -1, sep = '')
        bg_data = numpy.reshape(bg_data, (128, 128), order = 'C')
        bg_seq[:, :, i] = bg_data
        
    bg_average = sum(bg_seq, axis = 2) / positions
    bg_normalize = bg_average 

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
        image_seq_raw[:, :, i] = image_data
        image_seq_ratio[:, :, i] = - numpy.log10(image_data / bg_seq[:, :, i])
        image_seq_sub[:, :, i] = image_data - bg_seq[:, :, i]
        
##read in background image in objective arm
#bg_oj_dir = r'C:\Users\shihao\Desktop\ir-images\ir-holography\bead4\bg_obj'
#bg_obj_list = os.listdir(bg_oj_dir)
#number_bg_obj = len(bg_obj_list)
#if( number_bg_obj != 20):
#    print("Error: Background Image is missing!")
#else:
#    for i in range(number_bg_obj):
#        bg_obj_dir = bg_oj_dir + '\\' + bg_obj_list[i]
#        bg_obj_data = numpy.fromfile(bg_obj_dir, dtype = numpy.uint16, count = -1, sep = '')
#        bg_obj_data = numpy.reshape(bg_obj_data, (128, 128), order = 'C')
#        bg_obj_seq[:, :, i] = bg_obj_data
#        
#    bg_obj_average = sum(bg_obj_seq, axis = 2) / positions
#    
##read in sample image in objective arm
#bead_oj_dir = r'C:\Users\shihao\Desktop\ir-images\ir-holography\bead4\bead_obj'
#bead_obj_list = os.listdir(bead_oj_dir)
#number_bead_obj = len(bead_obj_list)
#if( number_bead_obj != 20):
#    print("Error: Background Image is missing!")
#else:
#    for i in range(number_bead_obj):
#        bead_obj_dir = bead_oj_dir + '\\' +bead_obj_list[i]
#        bead_obj_data = numpy.fromfile(bead_obj_dir, dtype = numpy.uint16, count = -1, sep = '')
#        bead_obj_data = numpy.reshape(bead_obj_data, (128, 128), order = 'C')
#        bead_obj_seq[:, :, i] = bead_obj_data
#        
#    bead_obj_average = sum(bead_obj_seq, axis = 2) / positions



#raw = True
#ratio = False
#sub = False
#
#if(raw == True): image_seq = image_seq_raw
#elif(raw == False and ratio == True): image_seq == image_seq_ratio
#elif(raw == False and ratio == False and sub == True): image_seq == image_seq_sub



def plot_holo(image_seq):
#    get the maximal and minimal values of all images to turn off auto-scaling
    _min, _max = numpy.amin(image_seq), numpy.amax(image_seq)    
    
    
    #plot the hologram and write out a .mp4 file
    fig = plt.figure()
    #for i in range(positions):
    #    plt.imshow(image_seq_raw[:, :, i], vmin = _min, vmax = _max)
    #    plt.pause(0.05)
    #plt.show()
    img = []
    for i in range(positions):
        img.append([plt.imshow(image_seq[:, :, i], vmin = _min, vmax = _max)])
    
    ani = animation.ArtistAnimation(fig,img,interval=200)
    writer = animation.writers['ffmpeg'](fps=5)
    
    ani.save(data_dir + '\\demo_' + str(num_frames) + '.mp4',writer=writer)





def cal_field(num, start, image_seq):
    #D matrix denoting the difference between consecutive measuremnts
    D = [(image_seq[:,:,start + i + 1] - image_seq[:,:,start + i]) for i in range(num)]
    
    #P matrix denoting the phase shifting terms
    P = [[numpy.exp(-1j * k * zstep * i), numpy.exp(1j * k * zstep * i)] for i in range(num)]
    
    #convert D and P to matrices or numpy arrays from lists
    D = numpy.asarray(D)
    P = numpy.matrix(numpy.asarray(P))
    
    #calculate the Hermitian conjugate of P matrix and its inverse
    P_hermint = P.getH()
    PH_P_inv = numpy.linalg.inv(P_hermint * P)
    
    #linear P matrix term before D matrix when calculating interferometric cross terms u
    PH_P_Ph =  PH_P_inv * P_hermint
    
    #initialize interferometric cross terms u as a 2x1 matrix for each point on the image with itself and its conjugate
    u = numpy.zeros((2,1,128,128)) + 0j
    
    #transform P matrix term and duplicate itself into higher dimention for dot product with D matrix for the whole image
    PH_P_Ph = numpy.asarray(PH_P_Ph)
    PH_P_Ph = numpy.repeat((numpy.repeat(numpy.reshape(PH_P_Ph,(2,num,1,1)),128,axis = 2)),128,axis = 3)
    
    #for each pixel on the image, do a doc product to calculate interferometric cross terms u
    D = D.reshape(num,1,128,128)  + 0j
    for i in range(128):
        for j in range(128):
            u[:,:,i,j] = numpy.dot(PH_P_Ph[:,:,i,j], D[:,:,i,j])
    
    #initialize a field to store u from the cross terms
    f = numpy.zeros((1,1,128,128)) + 0j
    f[:] = u[0,:,:,:]
    f = f.reshape((128,128))
    
    #calculate the scattering field F from reference field and extra terms in the equation
    expterm = numpy.exp(-1j * k * zstep) - 1
    dominator = expterm * ref_sqrt
    F = f / dominator
    
    return F

def plot_fields(image_seq, F, method):
    #plot out scattering field
    plt.figure()
    
    plt.subplot(221)
    plt.imshow(image_seq[:,:,start])
    plt.title('1st Raw Image')
    plt.colorbar()
    
    plt.subplot(222)
    plt.imshow(numpy.abs(F))
    plt.title('Absolute Value')
    plt.colorbar()
    
    plt.subplot(223)
    plt.imshow(numpy.real(F))
    plt.title('Real Part')
    plt.colorbar()
    
    plt.subplot(224)
    plt.imshow(numpy.imag(F))
    plt.title('Imaginary Part')
    plt.colorbar()
    plt.suptitle(method + ' plots from ' + str(start) + 'th of the hologram with ' + str(num) + ' measurements', fontsize = 15)
    
def plot_nums_sub(image_seq, bg_seq):
    plt.figure()
    
    plt.subplot(241)
    plt.imshow(image_seq[:,:,start] - bg_seq[:,:,start])
    plt.title('1st Raw Image')
    plt.colorbar()
    
    for i in range(7):
        num_pri = num * (2 ** i)
        F_bead = cal_field(num_pri, start, image_seq_raw)
        F_bg = cal_field(num_pri, start, bg_seq)
        plt.subplot(2,4,i+2)
        plt.imshow(numpy.abs(F_bead-F_bg))
        plt.title(str(num_pri) + ' measurements')
        plt.colorbar()
        
    plt.suptitle('Field Sub plots from ' + str(start) + 'th of the hologram', fontsize = 15)

    
def plot_nums_ratio(image_seq, bg_seq):
    plt.figure()
    
    plt.subplot(241)
    plt.imshow(numpy.log10(image_seq[:,:,start] / bg_seq[:,:,start]))
    plt.title('1st Raw Image')
    plt.colorbar()
    
    for i in range(7):
        num_pri = num * (2 ** i)
        F_bead = cal_field(num_pri, start, image_seq_raw)
        F_bg = cal_field(num_pri, start, bg_seq)
        plt.subplot(2,4,i+2)
        plt.imshow(numpy.abs(numpy.log10(F_bead/F_bg)))
        plt.title(str(num_pri) + ' measurements')
        plt.colorbar()
        
    plt.suptitle('Field Ratio plots from ' + str(start) + 'th of the hologram', fontsize = 15)
    
def plot_b4_ratio(image_seq):
    plt.figure()
    
    plt.subplot(241)
    plt.imshow(image_seq[:,:,start])
    plt.title('1st Raw Image')
    plt.colorbar()
    
    for i in range(7):
        num_pri = num * (2 ** i)
        F_ratio = cal_field(num_pri, start, image_seq)
#        F_bg = cal_field(num_pri, start, bg_seq)
        plt.subplot(2,4,i+2)
        plt.imshow(numpy.abs(F_ratio))
        plt.title(str(num_pri) + ' measurements')
        plt.colorbar()
        
    plt.suptitle('Field Ratio Before Reconstruction plots from ' + str(start) + 'th of the hologram', fontsize = 15)
    
def plot_b4_sub(image_seq):
    plt.figure()
    
    plt.subplot(241)
    plt.imshow(image_seq[:,:,start])
    plt.title('1st Raw Image')
    plt.colorbar()
    
    for i in range(7):
        num_pri = num * (2 ** i)
        F_sub = cal_field(num_pri, start, image_seq)
#        F_bg = cal_field(num_pri, start, bg_seq)
        plt.subplot(2,4,i+2)
        plt.imshow(numpy.abs(F_sub))
        plt.title(str(num_pri) + ' measurements')
        plt.colorbar()
        
    plt.suptitle('Field Subtraction Before Reconstruction plots from ' + str(start) + 'th of the hologram', fontsize = 15)
    
    
#specify which portion of hologram will be used to calculate field
num = 3                    #number of measurements used to do phase reconstruction. theoritically more than 3 is enough
start = 0                   #the starting point of sampling from the raw dataset
end = start + num           #the end point of sampling
lambdA = 8                  #wavelength of the laser
k = 2 * numpy.pi / lambdA   #wave vector k

F_bead = cal_field(num, start, image_seq_raw)
F_bg = cal_field(num, start, bg_seq)
F_ratio = cal_field(num, start, image_seq_ratio)
F_sub = cal_field(num, start, image_seq_sub)
#plot_fields(image_seq_raw, F_bead)
#plot_fields(bg_seq,F_bg)
#plot_fields(image_seq_raw - bg_seq, F_bead-F_bg, 'Field Sub')
#plot_fields(image_seq_raw - bg_seq, F_ratio, 'Ratio')
#plot_fields(image_seq_raw - bg_seq, F_sub, 'Subtraction')
#plot_fields(numpy.log10(image_seq_raw[:,:,start] / bg_seq[:,:,start]), numpy.log10(F_bead/F_bg))
plot_nums_sub(image_seq_raw, bg_seq)
plot_nums_ratio(image_seq_raw, bg_seq)
plot_b4_ratio(image_seq_ratio)
plot_b4_sub(image_seq_sub)