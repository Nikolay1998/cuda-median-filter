#include <cuda.h>
#include <cuda_runtime_api.h>
#include <device_launch_parameters.h>
#include <iostream>
#include "MedianFilter.h"
#include <time.h>
#define TILE_SIZE 4 

__global__ void medianFilterKernel(unsigned char *inputImageKernel, unsigned char *outputImagekernel, int imageWidth, int imageHeight)
{
	// Set row and colum for thread.
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned char filterVector[9] = { 0,0,0,0,0,0,0,0,0 };   //Take fiter window
	if ((row == 0) || (col == 0) || (row == imageHeight - 1) || (col == imageWidth - 1))
		outputImagekernel[row*imageWidth + col] = 0; //Deal with boundry conditions
	else {
		for (int x = 0; x < WINDOW_SIZE; x++) {
			for (int y = 0; y < WINDOW_SIZE; y++) {
				filterVector[x*WINDOW_SIZE + y] = inputImageKernel[(row + x - 1)*imageWidth + (col + y - 1)];   // setup the filterign window.
			}
		}
		for (int i = 0; i < 9; i++) {
			for (int j = i + 1; j < 9; j++) {
				if (filterVector[i] > filterVector[j]) {
					//Swap the variables.
					char tmp = filterVector[i];
					filterVector[i] = filterVector[j];
					filterVector[j] = tmp;
				}
			}
		}
		outputImagekernel[row*imageWidth + col] = filterVector[4];   //Set the output variables.
	}
}

bool MedianFilterGPU(Bitmap* image, Bitmap* outputImage) {
	//Cuda error and image values.
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start);
	cudaError_t status;
	int width = image->Width();
	int height = image->Height();

	int size = width * height * sizeof(char);
	//initialize images.
	unsigned char *deviceinputimage;
	cudaMalloc((void**)&deviceinputimage, size);
	status = cudaGetLastError();
	if (status != cudaSuccess) {
		std::cout << "Kernel failed for cudaMalloc : " << cudaGetErrorString(status) <<
			std::endl;
		return false;
	}
	cudaMemcpy(deviceinputimage, image->image, size, cudaMemcpyHostToDevice);
	status = cudaGetLastError();
	if (status != cudaSuccess) {
		std::cout << "Kernel failed for cudaMemcpy cudaMemcpyHostToDevice: " << cudaGetErrorString(status) <<
			std::endl;
		cudaFree(deviceinputimage);
		return false;
	}
	unsigned char *deviceOutputImage;
	cudaMalloc((void**)&deviceOutputImage, size);
	//take block and grids.
	dim3 dimBlock(TILE_SIZE, TILE_SIZE);
	dim3 dimGrid((int)ceil((float)image->Width() / (float)TILE_SIZE),
		(int)ceil((float)image->Height() / (float)TILE_SIZE));

	medianFilterKernel <<< dimGrid, dimBlock >>> (deviceinputimage, deviceOutputImage, width, height);

	// save output image to host.
	cudaMemcpy(outputImage->image, deviceOutputImage, size, cudaMemcpyDeviceToHost);
	status = cudaGetLastError();

	if (status != cudaSuccess) {
		std::cout << "Kernel failed for cudaMemcpy cudaMemcpyDeviceToHost: " << cudaGetErrorString(status) <<
			std::endl;
		cudaFree(deviceinputimage);
		cudaFree(deviceOutputImage);
		return false;
	}
	//Free the memory
	cudaFree(deviceinputimage);
	cudaFree(deviceOutputImage);
	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	float time = 0;
	cudaEventElapsedTime(&time, start, stop);
	printf("gputime %fms\n", time);
	return true;
}