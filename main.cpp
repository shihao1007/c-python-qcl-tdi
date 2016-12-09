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

void ipsHandleError(int32_t err, const char* file, int line) {
	std::cout << "ERROR: Failed to get capture source (# " << err << ") in "<<file<< "line "<<line<<std::endl;
	exit(err);
}

#define CHECK_IPS( err ) (ipsHandleError(err, __FILE__, __LINE__))

void ipsPrintCaptureSource(uint32_t src) {
	char capture_source[IPS_MAX_CAPTURE_SOURCE_BYTES];						//allocate space for strings
	char capture_source_descr[IPS_MAX_CAPTURE_SOURCE_BYTES];

	CHECK_IPS(IPS_GetCaptureSource(
				IPS_DEVICE_TYPE_CAMERALINK,
				src,
				capture_source, sizeof(capture_source),
				capture_source_descr, sizeof(capture_source_descr));
	));
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

int main(int argc, char* argv[]) {

	A3200Handle handle = NULL;					//create a handle for the stage API

	std::string capture_source;					//stores the text-name of the available capture source
	int32_t src = GetFirstAVailableCaptureSource(capture_source);		//get the first available capture source
	
	//TODO: change the capture source if the user says to do so

	std::cout<<"Using the following capture source for imaging----------" << std::endl;
	ipsPrintCaptureSource(src);

}