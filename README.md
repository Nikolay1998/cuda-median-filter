# CUDA median filter
In this work, CUDA technology was used for parallel processing of the image with a median filter.
Impulse noise was previously added to image with size 2024x2024 pixels.
To compare the processing rate, an algorithm for consistent and parallel processing the image with a median filter was implemented.

В этой работе была использованна технололгия CUDA для паралельной обработки изображения медианным фильтром.
Изоражение размером 2024x2024 пикселей было предварительно зашумлено импульсным шумом.
Для сравнения скорости обработки был реализованы алгоритм последовательной и пралельной оработки изображения медианным фильтром.

![alt text](https://github.com/Nikolay1998/cuda-median-filter/blob/master/images/input.bmp?raw=true)
![alt text](https://github.com/Nikolay1998/cuda-median-filter/blob/master/images/output_gpu.bmp?raw=true)

## Экспериментальные результаты
Эксперименты производились с использованием процессора AMD Ryzen 5 2600 и графического ускорителя NVIDIA GeForce RTX 2060.
| Размер изображения | Время последовательного выполнения, ms  | Время паралелльного выполнения, ms  | Ускорение |
| :-----------: |:---------------------------------------:| :----------------------------------:| :-------: |
| 2024x2024           |    1520                                   |   27                               |      56 |

2020.
