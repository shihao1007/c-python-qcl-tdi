#include <stdint.h>			//standard C99 include file for integer types
#include <iostream>			//C++ console output
#include <string>			//C++ string class
#include <vector>			//C++ vector (array) class
#include <Windows.h>		//standard windows OS file
#include <sstream>			//string streams
#include <ShlObj.h>			//??????	
#include <Shlwapi.h>		//??????
#include <fstream>			//file stream
#include "ips.h"
#include "vmemory.h"
#include <stdio.h>			//standard input and output
#include <tchar.h>			//Windows Unicode stuff
#include "A3200.h"			//Aerotech libraries

const int fpa_size = 128;
int grabs = 500;			//number of grabs
int fpg = 1;				//number of frames per grab

const char * DEFAULT_CONFIG = "<ips_config>"
                              "   <winir_inipath>$(IPS_SDK_DATA_DIR)\\Config\\winir.ini</winir_inipath>"
	                            "   <ccf_path>$(IPS_SDK_DATA_DIR)\\Config\\sbf161_px4full_dv_1tap.ccf</ccf_path>"
                              ""
                              "   <fg_window>"
                              "     <xoffset>0</xoffset>"
                              "     <yoffset>0</yoffset>"
                              "     <xsize>128</xsize>"
                              "     <ysize>128</ysize>"
	                            "   </fg_window>"
                              " </ips_config>";

void ipsHandleError(int32_t err, const char* file, int line) {
	std::cout << "ERROR: Failed to get capture source (# " << err << ") in "<<file<< "line "<<line<<std::endl;
	exit(err);
}

#define CHECK_IPS( err ) (ipsHandleError(err, __FILE__, __LINE__))

//TODO: need an err function for stage

#define CHECK_A3200( err ) (ipsHandleError(err, __FILE__, __LINE__))

void ipsPrintCaptureSource(uint32_t src) {
	char capture_source[IPS_MAX_CAPTURE_SOURCE_BYTES];						//allocate space for strings
	char capture_source_descr[IPS_MAX_CAPTURE_SOURCE_BYTES];

	CHECK_IPS(IPS_GetCaptureSource(
				IPS_DEVICE_TYPE_CAMERALINK,
				src,
				capture_source, sizeof(capture_source),
				capture_source_descr, sizeof(capture_source_descr));
	std::cout << "capture source ID: " << src << std::endl;
	std::cout << "name: " << capture_source << std::endl;
	std::cout << "description: " << capture_source_descr << std::endl;
}

//get the string indicating the first available capture source (source 0)
uint32_t GetFirstAVailableCaptureSource(std::string & first_capture_source) {
	first_capture_source.clear();												//empty the string

	uint32_t nc = 0;																//store the number of sources
	CHECK_IPS(IPS_GetCaptureSourceCount(IPS_DEVICE_TYPE_CAMERALINK, &nc));			//get the number of sources
	
	if (nc == 0) {																//if there are no capture sources
		std::cout << "No capture sources were found." << std::endl;;			//display an error
		exit(1);																//exit
	}
}


//initialize a decommute table
void Initialize_SBF161_Decommute_Table( int grab_num_cols,
                                        int grab_num_rows,
                                        int display_num_cols,
                                        int display_num_rows,
                                        std::vector<int> & decommute_table)
{
  int num_pixels = grab_num_cols * grab_num_rows;

  for (int i = 0; i < num_pixels; i++)
  {
    int display_row = (i % 4) + 4 * (i / grab_num_cols);
    int display_col = (i / 4) % display_num_cols;
    int display_pixel = display_row * display_num_cols + display_col;
    if (display_pixel < decommute_table.size())
    {
      decommute_table[display_pixel] = i;
    }
  }
}

std::string GetModuleDirectory()
{
  char szModuleFileName[MAX_PATH+1], szDrive[_MAX_DRIVE+1], szDir[_MAX_DIR+1], szFile[_MAX_FNAME+1], szExt[_MAX_EXT+1];
  GetModuleFileName(NULL, szModuleFileName,MAX_PATH+1);
  _splitpath(szModuleFileName,szDrive,szDir,szFile,szExt);
  char szDirectoryName[MAX_PATH+1];
  _makepath(szDirectoryName, szDrive, szDir, NULL, NULL);
  return std::string(szDirectoryName);
}

std::string GetPGMFileName(const std::string &  parent_directory,
                      const std::string & base_file_name,
					  int grab_index,
                      int frame_index)
{
  std::stringstream ss;
  ss << parent_directory << base_file_name << "_" <<grab_index<<"_"<< frame_index << ".pgm";
  return ss.str();
}


// Saves a 16 bpp grayscale image to PGM encoded file.  
//  IrfanView can be used to display PGM images. http://www.irfanview.com/

void SaveGrayScalePGM(uint16_t * p_pixel_data, int width, int height, const std::string pgm_path) 
{ 
  std::ofstream ofile(pgm_path, std::ios::out|std::ios::ate);
  ofile << "P2\n" << width << " " << height << "\n16383\n";
  int num_pixels = width*height;
  for (int i = 0; i < num_pixels; i++)
  {
    ofile << p_pixel_data[i] << " ";
  }
  ofile.close();
} 

int32_t CreateDisplayImageExample(HANDLE_IPS_ACQ handle_ips, int grab_index, int fpg)
{
  uint32_t frame_width = 128;
  uint32_t frame_height = 128;
  int bytes_per_pixel = 2;
  int frame_data_size = frame_width * frame_height * bytes_per_pixel;

  // Configure the frame acquisition window size
  CHECK_IPS(IPS_SetFrameWindow( handle_ips, 
                                0,
                                0,
                                frame_width,
                                frame_height));

  // Start capturing a block of fpg frames
  VMemory<uint8_t> buffer(frame_data_size*fpg);
  CHECK_IPS(IPS_StartGrabbing( handle_ips,         
                              fpg,            // Capture Fra_Number frames then stop capturing
                              buffer.data(), // User allocated buffer
                              buffer.size(), // size of user allocated buffer
                              false));        // No wrap

  // Wait for all frames to be acquired
  uint64_t frame_number;
  uint8_t * p_frame = NULL;
  CHECK_IPS(IPS_WaitFrame(handle_ips,
           fpg,                          // Wait until the number of frame has been captured
           IPS_TIMEOUT_WAIT_FOREVER,    // Don't time out, wait for ever
           false,                       // Pause after WaitFrame returns
           &p_frame,                    // Return a pointer to the frame
           &frame_number));              // Return the frame number of the returned frame


  // *********** Decommute ********************
  //
  // The data coming from the SBF 161 must be de-commuted before it can be displayed.   
  // The first four pixels go in the first columns of the first four rows, the next 4 pixels 
  // in the second column and so on to the last column.  Then it continues to rows 5-8 and so on.

  // Create a decommute table for recording the pixels for display as an image
  vector<int> decommute_table(frame_width*frame_height);
  Initialize_SBF161_Decommute_Table(frame_width * 4,
                                    frame_height/4,
                                    frame_width,
                                    frame_height,
                                    decommute_table);

  // Decommute the images.
  vector<uint16_t> display_image(frame_width * frame_height);
  std::string module_dir = GetModuleDirectory();
  std::string image_dir = module_dir + "\Frames1800\\" ;

  for (int frame_index = 0; frame_index < frame_number; frame_index++)
  {
    // Get a pointer to the image
    uint16_t * p_image = (uint16_t* ) (buffer.data() + frame_index*frame_data_size);

    // Decommute the image
    for (int i = 0; i < display_image.size(); i++)
    {
      display_image[i] = p_image[decommute_table[i]];

      // Invert the image pixel 
	  // uncomment the following line to invert the image
      display_image[i] = display_image[i] ^ 0x3FFF;
    }

    uint16_t * p_display_image = display_image.data();

    // Save as PGM image
    SaveGrayScalePGM( p_display_image,
                      frame_width,
                      frame_height,
                      GetPGMFileName(image_dir, "sbf161_img", grab_index, frame_index+1));
  }

  // Stop acquiring frames
  CHECK_IPS(IPS_StopGrabbing(handle_ips));

}

int main(int argc, char* argv[]) {

	A3200Handle handle = NULL;					//create a handle for the stage API
	DOUBLE result_stage;

	std::string capture_source;					//stores the text-name of the available capture source
	int32_t src = GetFirstAVailableCaptureSource(capture_source);		//get the first available capture source
	
	//TODO: change the capture source if the user says to do so

	std::cout<<"Using the following capture source for imaging----------" << std::endl;
	ipsPrintCaptureSource(src);

	//initialize the first capture source (from the name above)
	HANDLE_IPS_ACQ handle_ips = NULL;			//declare a handle to the camera
	src = IPS_InitAcq(CAM_ID_SBF161,  		//Configure the SBF 161 camera
	                    capture_source.c_str(),	//name collected from the above function
	                    DEFAULT_CONFIG,
	                    "$(IPS_SDK_DATA_DIR)\\license.lcx",
	                    &handle_ips);

	// Display the camera and frame grabber diagnostic data
	vector<char> diag_buffer(IPS_MAX_DIAGNOSTIC_STRING_BYTES);		//allocate a character array
	uint32_t diag_buffer_size(0);									//initialize the buffer size to zero (0)
	//get the camera diagnostics - fill diag_buffer with a string describing the camera status								
	CHECK_IPS(src = IPS_GetCameraDiagnostics(handle_ips,
	                                diag_buffer.data(),
	                                (uint32_t) diag_buffer.size(),
	                                &diag_buffer_size));

	if (strlen(diag_buffer.data()) == diag_buffer_size-1)			//if the diagnostic string exists
		std::cout << "Camera diagnostics : " << std::string(diag_buffer.data()) << std::endl;	//print it
	//get the frame grabber diagnostics
	CHECK_IPS(src = IPS_GetFrameGrabberDiagnostics( handle_ips,
	                                          diag_buffer.data(),
	                                          (uint32_t) diag_buffer.size(),
	                                          &diag_buffer_size));

	if (strlen(diag_buffer.data()) == diag_buffer_size-1)			//if the diagnostic string exists
		std::cout << "Frame grabber diagnostics : " << std::string(diag_buffer.data()) << std::endl;	//print it

	//connect to the A3200 Aerotech stage controller
	std::cout <<"Connecting to A3200. Initializing if necessary."<< std::endl;
	CHECK_A3200(A3200Connect(&handle));								//attempt to connect to the controller
        															//if there is an error, return

	std::cout <<"Enabling Axis."<< std::endl;			    		//enable the axis
	CHECK_A3200(A3200MotionEnable(handle, TASKID_01, AXISMASK_00));

	//perform an imaging pass across the sample
	for (int i = 0; i < grabs; i++){
		A3200CommandExecute(handle, TASKID_01, "LINEAR Z0.005", &result_stage);	//move the stage
		//A3200CommandExecute(handle, TASKID_01, "MOVEDELAY Z, 1000", &result_stage);	//wait
		CHECK_IPS(src = CreateDisplayImageExample(handle_ips, i, fpg));				//capture images

		 

		std::cout << (float)(i + 1) / (float)grabs * 100 <<" %." << std::endl;		//display the number of images

		//A3200CommandExecute(handle, TASKID_01, "MOVEDELAY Z, 1000", &result_stage);	//wait again
	}
	A3200CommandExecute(handle, TASKID_01, "LINEAR Z-2.5", &result_stage);  //move stage back to origin
}